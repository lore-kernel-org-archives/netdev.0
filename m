From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Mon, 2 Jul 2007 16:52:52 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
References: <1183238694.9055.10.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jason Lunz <lunz@reflexsecurity.com>, Jeff Garzik <jeff@garzik.org>
To: "Mark McLoughlin" <markmc@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <1183238694.9055.10.camel@blaa>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

 

Mark McLoughlin wrote:

>> I disagree, we should not break the current e1000 driver in 
>the kernel while 
>> there is a new driver coming up that introduces ich9 support 
>without breaking 
>> (the old e1000) support for all other devices. This is why 
>we want to drop a new 
>> version of the e1000 driver upstream instead, and put all 
>newer devices in that 
>> driver.
>
>	Clearly some major changes are happening around e1000, 
>but the point
>I'm making is that ich9 support, in particular, doesn't need to be held
>hostage to these longer term changes. I think the backport shows that:
>

There seems to be a lot of concern over obsoleting the e1000 driver
too quickly, and with confusing users (and startup scripts) about which
driver to load.

Obviously, we at Intel want to get e1000new into the kernel as quickly
as possible, and to obsolete e1000 also as quickly as possible.  The
point of this exercise is to reduce our support and maintenance burden,
and e1000new has shown itself internally to be much easier to work on.

So how about this:
- We include e1000new in 2.6.23, along side e1000.  We expose ICH9
  device IDs in e1000new, and gate the rest of the IDs inside
  #ifndef CONFIG_E1000.  This gives distis ICH9 support, along
  with a guarantee of the known e1000 driver.  It also lets the more
  bleeding-edge people turn off e1000 and run with just e1000new to
  work out any kinks.
- For 2.6.24, we reverse the situation:  Gate all device IDs in e1000
  behind #ifndef CONFIG_E1000NEW, and expose all of them in e1000new.
  At this point we (i.e. the community, not just Intel) should be 
  confident in e1000new, and we can mark e1000 as obsolete.  It's still
  a fallback option for those with old/funky/misconfigured hardware.
- After a year (or whatever), we remove e1000.

Seems to me that this plan should appease either everybody or nobody.
We get ICH9 support out there, e1000new gets in the kernel and
exercised,
and we get to set a definite date for obsoleting e1000.

-Mitch

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
