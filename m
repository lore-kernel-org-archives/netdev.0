From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH 1/3] ixgbe,
 ixgbevf: Add new mbox API to enable MC promiscuous mode
Date: Mon, 16 Feb 2015 04:54:11 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E322FD@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
	<1423054641.2589.59.camel@jtkirshe-mobl>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E26E45@BPXM14GP.gisp.nec.co.jp>
	<1423470046.27854.7.camel@jtkirshe-mobl>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E29F43@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF22286646912A1339@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E2E9CE@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF22286646912A1A50@ORSMSX110.amr.corp.intel.com>
	<54DE358B.90502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <54DE358B.90502@redhat.com>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> >>>>>>>>> Can you please fix up your patches based on my tree:
> >>>>>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/que
> >>>>>>>>> ue.git
> >>>>>>>>
> >>>>>>>> Yes. I haven't noticed your tree.
> >>>>>>>> Will resend patches against it.
> >>>>>>>>
> >>>>>>>
> >>>>>>> I encountered an issue with your tree, the commit id is below.
> >>>>>>>
> >>>>>>> $ git log | head
> >>>>>>> commit e6f1649780f8f5a87299bf6af04453f93d1e3d5e
> >>>>>>> Author: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> >>>>>>> Date:   Fri Jan 23 20:43:14 2015 -0800
> >>>>>>>
> >>>>>>>     ethernet: fm10k: Actually drop 4 bits
> >>>>>>>
> >>>>>>>     The comment explains the intention, but vid has type u16. Before
> >> the
> >>>>>>>     inner shift, it is promoted to int, which has plenty of space for all
> >>>>>>>     vid's bits, so nothing is dropped. Use a simple mask instead.
> >>>>>>>
> >>>>>>>
> >>>>>>> I use the kernel from your tree in both host and guest.
> >>>>>>>
> >>>>>>> Assign an IPv6 for VF in guest.
> >>>>>>> # ip -6 addr add 2001:db8::18:1/64 dev ens0
> >>>>>>>
> >>>>>>> Send ping packet from other server to the VM.
> >>>>>>> # ping6  2001:db8::18:1 -I eth0
> >>>>>>>
> >>>>>>> The following message was shown.
> >>>>>>> ixgbevf 0000:00:08.0: partial checksum but l4 proto=3a!
> >>>>>>>
> >>>>>>> If I did the same operation in the host, I saw the same error
> >>>>>>> message in
> >>>>> host too.
> >>>>>>> ixgbe 0000:2d:00.0: partial checksum but l4 proto=3a!
> >>>>>>>
> >>>>>>> Do you have any idea about that?
> >>>>>>
> >>>>>> Ah, sorry about that, try this tree again:
> >>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git
> >>>>>>
> >>>>>> That patch was dropped for favor of a patch that Matthew Vick
> >>>>>> put together (and recently got pushed upstream).  So my queue no
> >>>>>> longer has that patch in the queue, since it got dropped.
> >>>>>
> >>>>> I still see the same error, the head id is the below
> >>>>>
> >>>>> $ git log | head
> >>>>> commit a072afb0b45904022b76deef3b770ee9a93cb13a
> >>>>> Author: Nicholas Krause <xerofoify@gmail.com>
> >>>>> Date:   Mon Feb 9 00:27:00 2015 -0800
> >>>>>
> >>>>>     igb: Remove outdated fix me comment in the
> >>>>> function,gb_acquire_swfw_sync_i210
> >>>>>
> >>>>>
> >>>>> thanks,
> >>>>> Hiroshi
> >>>>
> >>>> I'm having our validation see if they can recreate the same issue
> >>>> internally.  When they get back to me I'll let you
> >>> know
> >>>> what we found.
> >>>
> >>> We did bisect, and the below looks the culprit;
> >>>
> >>> 32dce968dd987adfb0c00946d78dad9154f64759 is the first bad commit
> >>> commit 32dce968dd987adfb0c00946d78dad9154f64759
> >>> Author: Vlad Yasevich <vyasevich@gmail.com>
> >>> Date:   Sat Jan 31 10:40:18 2015 -0500
> >>>
> >>>     ipv6: Allow for partial checksums on non-ufo packets
> >>>
> >>>     Currntly, if we are not doing UFO on the packet, all UDP
> >>>     packets will start with CHECKSUM_NONE and thus perform full
> >>>     checksum computations in software even if device support
> >>>     IPv6 checksum offloading.
> >>>
> >>>     Let's start start with CHECKSUM_PARTIAL if the device
> >>>     supports it and we are sending only a single packet at
> >>>     or below mtu size.
> >>>
> >>>     Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> >>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>
> >>> :040000 040000 4437eaf7e944f5a6136ebf668a256fee688fda3d
> >> fade8da998d35c8da97a15f0556949ad371e5347 M      net
> >>
> >> When I reverted the commit, the issue was solved.
> >>
> >> thanks,
> >> Hiroshi
> >
> > I believe the issue is that this patch (32dce968dd98 - ipv6: Allow for partial checksums on non-ufo packets) is that
> it now sets CHECKSUM_PARTIAL on all IPv6 packets including ICMPv6 ones.  Our HW (82599) only supports checksum offload
> on TCP/UDP (NETIF_F_IPV6_CSUM) so we get hung up on the skb's protocol and the fact that it is CHECKSUM_PARTIAL.
> >
> > Another thing that confuses me is the feature test in this patch.  It checks (rt->dst.dev->features & NETIF_F_V6_CSUM)
> but NETIF_F_V6_CSUM is a two bit field?
> >
> > #define NETIF_F_V6_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
> >
> > So the test would succeed if either bit was high, that doesn't seem right.  I cc'd the author so maybe he could clue
> us in.
> 
> This has been addressed by:
> commit bf250a1fa769f2eb8fc7a4e28b3b523e9cb67eef
> Author: Vlad Yasevich <vyasevich@gmail.com>
> Date:   Tue Feb 10 11:37:29 2015 -0500
> 
>     ipv6: Partial checksum only UDP packets
> 
> 
> As far the 2 bit issue, GEN_CSUM (HW_SUM) and IPV6_CSUM can not coexist at the same time.
> See netdev_fix_features().
> 

thanks for pointing it. I will test with that commit.

Jeff's tree hasn't included that commit yet, right?
Which branch has the commit?

thanks,
Hiroshi
------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=190641631&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
