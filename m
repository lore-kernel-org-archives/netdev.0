From: Jeff Garzik <jeff@garzik.org>
Subject: Re: RFR: New e1000 driver (e1000new),
 was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sun, 08 Jul 2007 14:20:26 -0400
Message-ID: <46912AEA.3030604@garzik.org>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
	<468597F7.2050700@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468597F7.2050700@linux.intel.com>
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

Arjan van de Ven wrote:
> Kok, Auke wrote:
>> Jeff Garzik wrote:
>>> Andrew Morton wrote:
>>>> On Fri, 29 Jun 2007 14:39:20 -0700
>>>> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
>>>>
>>>>> That's why we want to introduce a second e1000 driver (named 
>>>>> differently, pick any name) that contains the new code base, 
>>>>> side-by-side into the kernel with the current e1000.
>>>> Sounds like a reasonable approach to me (it has plenty of 
>>>> precedent).  But
>>>> I forget what all the other issues were, so ignore me.
>>>
>>> Given past history with duplicate drivers and the problems that they 
>>> cause -- I know, I've caused some of those problems :( -- I strongly 
>>> recommend against when it can be avoided.
>>>
>>> Leaving e1000 with current hardware, and a new e1001 for newer 
>>> hardware should be easier to manage for all involved, without the 
>>> headaches that duplicate drivers cause.
>>>
> 
> Jeff,
> 
> ok first you hate the old e1000 and now you don't want to get rid of it ;)

No -- e1000 is big and bloated but also stable and working and a key 
popular NIC driver for a lot of people.

That means the transition has a wide impact, and thus should be 
considered a lot more carefully than (say) rewriting 8139cp.

I reject the notion that a "flag day" switchover for a huge mass of 
e1000 users is the correct path.  I do not think that best serves Linux 
users.

It is better to get a new driver out in the field and working for a 
small population, let time pass, then consider if we really want to 
transition the entire e1000 population to the new driver.  That leaves 
the mass of e1000 users with a working driver while the new driver 
proves itself.  Since a small population of users is required to use the 
new driver, by virtue of new/old PCI ID split, you are guaranteed a 
population of test users immediately for the new driver.

When the new driver proves itself stable, you will have plenty of 
knowledge from which to decide whether to transition 8257x users, all 
e1000 users, or whatever.


> I appreciate the pain a temporary dual driver situation gives; it comes 
> down to a few things that I can think of right now, if you see more 
> please add to the list.
> 
> 1) users who find a bug in the new one silently use the old one rather 
> than reporting the bug; and only scream when the old one eventually goes 
> away (see ALSA/OSS duplication)
> 
> 2) users who enable both in KConfig may get a "random" one
> 
> 3) distros really prefer only 1 driver per PCI ID for their 
> infrastructure tools
> 
> 4) there will be resistance against deleting the old one meaning it 
> might not happen

You are missing the largest source of pain and headache:  Users will use 
the default driver, which means no field testing at all until flag day, 
with obvious results.

Furthermore, Linux kernel history demonstrates that "temporary dual 
driver situations" are rarely temporary.  Thus, selling it as such in 
the face of all contrary experience is pure hyperbole.

	Jeff




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
