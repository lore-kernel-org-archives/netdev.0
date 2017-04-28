From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: arm64: next-20170428 hangs on boot
Date: Fri, 28 Apr 2017 19:10:56 +0300
Message-ID: <20170428161056.vvzkj6lxhvixy33v@yury-N73SV>
References: <20170428132429.c3dlxbmt7iqs2isl@yury-N73SV>
 <20170428145233.GB5292@leverpostej>
 <20170428150931.iyoewmc5qs55aw3t@yury-N73SV>
 <e65b3ec3-790d-da96-9e1f-3d344f65517b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0085.outbound.protection.outlook.com ([104.47.34.85]:43552
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756797AbdD1QLL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:11:11 -0400
Content-Disposition: inline
In-Reply-To: <e65b3ec3-790d-da96-9e1f-3d344f65517b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 08:40:54AM -0700, Florian Fainelli wrote:
> On 04/28/2017 08:09 AM, Yury Norov wrote:
> > On Fri, Apr 28, 2017 at 03:52:34PM +0100, Mark Rutland wrote:
> >> On Fri, Apr 28, 2017 at 04:24:29PM +0300, Yury Norov wrote:
> >>> Hi all,
> >>
> >> Hi,
> >>
> >> [adding Dave Miller, netdev, lkml]
> > 
> > thanks
> > 
> >>> On QEMU the next-20170428 hangs on boot for me due to kernel panic in 
> >>> rtnetlink_init():
> >>>
> >>> void __init rtnetlink_init(void)
> >>> {
> >>>         if (register_pernet_subsys(&rtnetlink_net_ops))
> >>>                 panic("rtnetlink_init: cannot initialize rtnetlink\n");
> >>>
> >>>         ...
> >>> }
> >>
> >> I see the same thing with a next-20170428 arm64 defconfig, on a Juno R1
> >> system:
> >>
> >> [    0.531949] Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
> >> [    0.531949] 
> >> [    0.541271] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc8-next-20170428-00002-g6ee3799 #10
> >> [    0.550307] Hardware name: ARM Juno development board (r1) (DT)
> >> [    0.556332] Call trace:
> >> [    0.558833] [<ffff000008088538>] dump_backtrace+0x0/0x238
> >> [    0.564332] [<ffff000008088834>] show_stack+0x14/0x20
> >> [    0.569477] [<ffff00000839dd54>] dump_stack+0x9c/0xc0
> >> [    0.574622] [<ffff000008175344>] panic+0x11c/0x28c
> >> [    0.579505] [<ffff000008d80034>] rtnetlink_init+0x2c/0x1d0
> >> [    0.585092] [<ffff000008d8047c>] netlink_proto_init+0x14c/0x17c
> >> [    0.591119] [<ffff000008083150>] do_one_initcall+0x38/0x120
> >> [    0.596796] [<ffff000008d30d00>] kernel_init_freeable+0x1a0/0x240
> >> [    0.603003] [<ffff00000892a790>] kernel_init+0x10/0x100
> >> [    0.608324] [<ffff000008082ec0>] ret_from_fork+0x10/0x50
> >> [    0.613736] SMP: stopping secondary CPUs
> >> [    0.617738] ---[ end Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
> >>
> >> If this isn't a known issue, it would be worth trying to bisect this.
> 
> It's fixed already by this commit in net-next:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=2d2ab658d2debcb4c0e29c9e6f18e5683f3077bf

Works for me, thank you.
