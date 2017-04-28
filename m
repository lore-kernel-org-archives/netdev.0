From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: arm64: next-20170428 hangs on boot
Date: Fri, 28 Apr 2017 15:52:34 +0100
Message-ID: <20170428145233.GB5292@leverpostej>
References: <20170428132429.c3dlxbmt7iqs2isl@yury-N73SV>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net
To: Yury Norov <ynorov@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170428132429.c3dlxbmt7iqs2isl@yury-N73SV>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 04:24:29PM +0300, Yury Norov wrote:
> Hi all,

Hi,

[adding Dave Miller, netdev, lkml]

> On QEMU the next-20170428 hangs on boot for me due to kernel panic in 
> rtnetlink_init():
> 
> void __init rtnetlink_init(void)
> {
>         if (register_pernet_subsys(&rtnetlink_net_ops))
>                 panic("rtnetlink_init: cannot initialize rtnetlink\n");
> 
>         ...
> }

I see the same thing with a next-20170428 arm64 defconfig, on a Juno R1
system:

[    0.531949] Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
[    0.531949] 
[    0.541271] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc8-next-20170428-00002-g6ee3799 #10
[    0.550307] Hardware name: ARM Juno development board (r1) (DT)
[    0.556332] Call trace:
[    0.558833] [<ffff000008088538>] dump_backtrace+0x0/0x238
[    0.564332] [<ffff000008088834>] show_stack+0x14/0x20
[    0.569477] [<ffff00000839dd54>] dump_stack+0x9c/0xc0
[    0.574622] [<ffff000008175344>] panic+0x11c/0x28c
[    0.579505] [<ffff000008d80034>] rtnetlink_init+0x2c/0x1d0
[    0.585092] [<ffff000008d8047c>] netlink_proto_init+0x14c/0x17c
[    0.591119] [<ffff000008083150>] do_one_initcall+0x38/0x120
[    0.596796] [<ffff000008d30d00>] kernel_init_freeable+0x1a0/0x240
[    0.603003] [<ffff00000892a790>] kernel_init+0x10/0x100
[    0.608324] [<ffff000008082ec0>] ret_from_fork+0x10/0x50
[    0.613736] SMP: stopping secondary CPUs
[    0.617738] ---[ end Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink

If this isn't a known issue, it would be worth trying to bisect this.

Thanks,
Mark.

> The backtrace is:
> #0  arch_counter_get_cntvct () at ./arch/arm64/include/asm/arch_timer.h:160
> #1  __delay (cycles=62500) at arch/arm64/lib/delay.c:31
> #2  0xffff00000838a430 in __const_udelay (xloops=<optimized out>) at arch/arm64/lib/delay.c:41
> #3  0xffff000008165eac in panic (fmt=<optimized out>) at kernel/panic.c:297
> #4  0xffff000008b5b9c8 in rtnetlink_init () at net/core/rtnetlink.c:4196
> #5  0xffff000008b5be08 in netlink_proto_init () at net/netlink/af_netlink.c:2730
> #6  0xffff000008083158 in do_one_initcall (fn=0xffff000008b5bcc4 <netlink_proto_init>) at init/main.c:795
> #7  0xffff000008b20d04 in do_initcall_level (level=<optimized out>) at init/main.c:861
> #8  do_initcalls () at init/main.c:869
> #9  do_basic_setup () at init/main.c:887
> #10 kernel_init_freeable () at init/main.c:1039
> #11 0xffff000008817bb0 in kernel_init (unused=<optimized out>) at init/main.c:962
> #12 0xffff000008082ec0 in ret_from_fork () at arch/arm64/kernel/entry.S:789
> Backtrace stopped: previous frame identical to this frame (corrupt stack?) 
> 
> next-20170426 is OK though.
> 
> Yury
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
