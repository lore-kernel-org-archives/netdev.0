From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 30 Jun 2007 22:24:53 +0100
Message-ID: <1183238694.9055.10.camel@blaa>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org>  <468562A6.8060901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jason Lunz <lunz@reflexsecurity.com>, Jeff Garzik <jeff@garzik.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468562A6.8060901@intel.com>
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

Hi Auke,

On Fri, 2007-06-29 at 12:51 -0700, Kok, Auke wrote:
> Jason Lunz wrote:
> > On Fri, Jun 29, 2007 at 06:29:18PM +0100, Mark McLoughlin wrote:
> >> 	I understand there is some delay in getting e1000-7.5.5 into the
> >> upstream kernel given the major re-working of the chipset specific
> >> parts.
> >>
> >> 	I wonder would it be feasible in the meantime to backport the ich9
> >> support and push it upstream?
> > 
> > seconded - this driver reorg has been holding back support for the
> > newest e1000 hardware since at least 2.6.20, and I haven't seen any
> > indication that the 7.5.5 e1000 driver will even be added to 2.6.23.
> 
> I disagree, we should not break the current e1000 driver in the kernel while 
> there is a new driver coming up that introduces ich9 support without breaking 
> (the old e1000) support for all other devices. This is why we want to drop a new 
> version of the e1000 driver upstream instead, and put all newer devices in that 
> driver.

	Clearly some major changes are happening around e1000, but the point
I'm making is that ich9 support, in particular, doesn't need to be held
hostage to these longer term changes. I think the backport shows that:

  - ich9 differs only very slightly from ich8, which is already 
    supported upstream. The patch largely consists of:

-    if (hw->mac_type == e1000_ich8lan)
+    if (hw->mac_type == e1000_ich8lan || hw->mac_type == e1000_ich9lan)

  - adding ich9 support is very unlikely to affect support for any
    other chipsets

Thanks,
Mark.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
