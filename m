From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Thu, 19 Jun 2008 01:14:36 +0200
Message-ID: <20080618231436.GA12886@elte.hu>
References: <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
	<20080617092706.GB20621@elte.hu>
	<20080617.022909.173003136.davem@davemloft.net>
	<20080617093929.GA10334@elte.hu> <48595910.8000905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, David Miller <davem@davemloft.net>,
	xemul@openvz.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <48595910.8000905@intel.com>
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


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> You only complain and do not provide a single solution to your 
> problem. [...]

i have reported the problem and even provided a fix.

I have triggered an e1000/e1000e related problem that got introduced in 
the v2.6.25 merge window - one of my testboxes came up with no 
networking and it took me an hour to figure out why. (i wasnt 
particularly focusing on e1000, i just happened to hit that bug in 9 
million lines of Linux kernel code)

I have reported it here, two and a half months ago:

    http://lkml.org/lkml/2008/4/8/256

I even showed you which commit introduced the problem and gave you a 
oneliner fix that i tested (it solved the problem):

    http://bugzilla.kernel.org/attachment.cgi?id=15704&amp;action=view

You were Cc:-ed to that. (attached below again for reference) The bug 
was added to the regression list of v2.6.25. I never expected to spend 
more than 10 minutes on this problem once i found out what's happening - 
we fix dozens of bugs like this per stable kernel release.

I just checked latest -git, my fix is still not upstream (or any 
equivalent solution - i really dont mind how it's solved and i'm not 
maintaining this code).

no alternative patch was sent to me - i offered to test any solution 
back then.

FYI, since i first reported it i've been hit by that problem roughly a 
dozen times. (it happened sporadically so i forgot about it - until i 
again had a system come up with no networking.) It caused me lost time 
and lost work that could have been spent on better things.

	Ingo

------------------------>
Subject: e1000=y && e1000e=m regression fix
From: Ingo Molnar <mingo@elte.hu>
Date: Wed Apr 09 21:09:35 CEST 2008

fix a regression from v2.6.24: do not transfer the e1000e PCI IDs from 
e1000 to e1000e if e1000 is built-in and e1000e is a module.

Built-in drivers take precedence over modules in many ways - and in this 
case it's clear that the user intended the e1000 driver to be the 
primary one. "Silently change behavior and break existing configs" is 
never a good migration strategy. Most users will use distro kernels that 
are not affected by this problem at all - nor are they affected by this 
patch - but this problem can hit users and developers who build their 
kernels themselves and migrate from v2.6.24 to v2.6.25.

this fixes: http://bugzilla.kernel.org/show_bug.cgi?id=10427

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-x86.q/drivers/net/Kconfig
===================================================================
--- linux-x86.q.orig/drivers/net/Kconfig
+++ linux-x86.q/drivers/net/Kconfig
@@ -2022,7 +2022,7 @@ config E1000E
 	  will be called e1000e.
 
 config E1000E_ENABLED
-	def_bool E1000E != n
+	def_bool E1000E = y || ((E1000E != n) && (E1000 = E1000E))
 
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
