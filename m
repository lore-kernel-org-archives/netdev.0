From: punnaiah choudary kalluri <punnaia@xilinx.com>
Subject: Re: Kernel BUG while sending data on 10mbps halfduplex link
Date: Tue, 8 Jul 2014 09:57:53 +0530
Message-ID: <CAGnW=Bbhzj9peNEvC4Tem-hFp3K4Sq1TT9f3V6=NwjqAF=OgOw@mail.gmail.com>
References: <CAGnW=BZb_DHb7JHc0h_4mWH0q8K9mONnwW554jwnsaxFAW25WA@mail.gmail.com>
	<1404370448.23797.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, anirudh@xilinx.com,
	svemula@xilinx.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33714 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaGHE1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:27:55 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so3583056lbj.27
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 21:27:53 -0700 (PDT)
In-Reply-To: <1404370448.23797.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

    Here is the stack trace dump.

skb_over_panic: text:c0312914 len:11520 put:11520 head:ee349c00
data:ee349c40 tail:0xee34c940 end:0xee34a240 dev:eth0
------------[ cut here ]------------
kernel BUG at /opt/Xilinx/petalinux-v2014.2-final/components/linux-kernel/xlnx-3.14/net/core/skbuff.c:99!
Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
Modules linked in: ipv6
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.2-xilinx #2
task: c0a1b6b0 ti: c0a10000 task.ti: c0a10000
PC is at skb_panic+0x50/0x5c
LR is at skb_panic+0x50/0x5c
pc : [<c0490d0c>]    lr : [<c0490d0c>]    psr: 600f0113
sp : c0a11dd0  ip : c0b220e8  fp : 2e349c40
r10: 00000001  r9 : ee91d810  r8 : c0a1b384
r7 : c05d82a2  r6 : ee349c00  r5 : ee349c40  r4 : ee34c940
r3 : 600f0113  r2 : 00000000  r1 : 00000110  r0 : 0000007d
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 18c5387d  Table: 2e19404a  DAC: 00000015
Process swapper/0 (pid: 0, stack limit = 0xc0a10240)
Stack: (0xc0a11dd0 to 0xc0a12000)
1dc0:                                     00002d00 ee349c00 ee349c40 ee34c940
1de0: ee34a240 ee8ff000 00000000 ee34c940 00002d00 00000000 00000000 c03cfa74
1e00: ee8ff71c f01a50b0 ee1f0b40 c0312914 00000001 2e3db840 00000001 c005f7d0
1e20: 2e3db840 ee1f0c00 00000000 ee8ff69c 00002d00 00000600 00000040 00000040
1e40: c0a556ec ee8ff71c eefd58c0 0000012c 00000040 eefd58c8 c0a556ec ffff95ea
1e60: c0a120c0 c03de320 c0a1208c ffff95ea c03de268 c0a10000 00000008 c0a12080
1e80: c0a10018 00000101 c0a1208c 00000001 c0a5e340 c0026cc0 00000000 c00696a0
1ea0: 00000000 00000003 40000003 0000000a 00200000 ffff95e9 00000000 00000004
1ec0: 9c7c1fe7 c0a10028 c0a0e1b4 00000000 c0a11f4c 9c7c1fe7 00000006 c0f84aa8
1ee0: 00000000 c0027104 c0a10000 00000036 c0a0e1b4 c000efa8 f8f00100 c0a11f18
1f00: c0a19238 c0008530 c0398008 200f0013 ffffffff c0012444 00000001 00000004
1f20: 00000000 c0a1b6b0 9c2ebc89 00000006 00000000 eefd4448 9c7c1fe7 00000006
1f40: c0f84aa8 00000000 00000008 c0a11f60 c005ec48 c0398008 200f0013 ffffffff
1f60: 9c7c1fe7 00000006 00000000 eefd4448 c0a10038 eefd4448 00000000 00000000
1f80: 00000000 c0a4c2b8 00000000 c0398180 c0a10000 c0a10038 c0a5d8c0 ffffffff
1fa0: c06a39d8 c0a183c0 ef7fce00 c000f2b0 c0a1b6b0 c0068cec c049b77c c067cab4
1fc0: ffffffff ffffffff c067c570 00000000 00000000 c06a39d8 18c5387d c0a1840c
1fe0: c06a39d4 c0a1cdbc 0000406a 413fc090 00000000 00008074 00000000 00000000
[<c0490d0c>] (skb_panic) from [<c03cfa74>] (skb_put+0x44/0x50)
[<c03cfa74>] (skb_put) from [<c0312914>] (xemacps_rx_poll+0x23c/0x3f0)
[<c0312914>] (xemacps_rx_poll) from [<c03de320>] (net_rx_action+0xb8/0x180)
[<c03de320>] (net_rx_action) from [<c0026cc0>] (__do_softirq+0x120/0x278)
[<c0026cc0>] (__do_softirq) from [<c0027104>] (irq_exit+0x84/0xf4)
[<c0027104>] (irq_exit) from [<c000efa8>] (handle_IRQ+0x6c/0x90)
[<c000efa8>] (handle_IRQ) from [<c0008530>] (gic_handle_irq+0x3c/0x60)
[<c0008530>] (gic_handle_irq) from [<c0012444>] (__irq_svc+0x44/0x78)
Exception stack(0xc0a11f18 to 0xc0a11f60)
1f00:                                                       00000001 00000004
1f20: 00000000 c0a1b6b0 9c2ebc89 00000006 00000000 eefd4448 9c7c1fe7 00000006
1f40: c0f84aa8 00000000 00000008 c0a11f60 c005ec48 c0398008 200f0013 ffffffff
[<c0012444>] (__irq_svc) from [<c0398008>] (cpuidle_enter_state+0x54/0xe4)
[<c0398008>] (cpuidle_enter_state) from [<c0398180>]
(cpuidle_idle_call+0xe8/0x140)
[<c0398180>] (cpuidle_idle_call) from [<c000f2b0>] (arch_cpu_idle+0x8/0x3c)
[<c000f2b0>] (arch_cpu_idle) from [<c0068cec>] (cpu_startup_entry+0xc4/0x12c)
[<c0068cec>] (cpu_startup_entry) from [<c067cab4>] (start_kernel+0x324/0x380)
Code: e1a0300c e58de010 e59f0008 ebfff908 (e7f001f2)
---[ end trace 53dd86e60cb384f9 ]---
Kernel panic - not syncing: Fatal exception in interrupt
CPU1: stopping
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D      3.14.2-xilinx #2
[<c0015658>] (unwind_backtrace) from [<c00119b4>] (show_stack+0x10/0x14)
[<c00119b4>] (show_stack) from [<c0490688>] (dump_stack+0x8c/0xd0)
[<c0490688>] (dump_stack) from [<c0013e64>] (ipi_cpu_stop+0x3c/0x70)
[<c0013e64>] (ipi_cpu_stop) from [<c00144ec>] (handle_IPI+0x68/0xac)
[<c00144ec>] (handle_IPI) from [<c000854c>] (gic_handle_irq+0x58/0x60)
[<c000854c>] (gic_handle_irq) from [<c0012444>] (__irq_svc+0x44/0x78)
Exception stack(0xee89bf50 to 0xee89bf98)
bf40:                                     c0398004 00000006 00000018 00000000
bf60: a3ed630c 00000006 00000001 eefdc448 b02eba89 00000006 c0f84aa8 00000000
bf80: 00000008 ee89bf98 c0398004 c0398008 600f0013 ffffffff
[<c0012444>] (__irq_svc) from [<c0398008>] (cpuidle_enter_state+0x54/0xe4)
[<c0398008>] (cpuidle_enter_state) from [<c0398180>]
(cpuidle_idle_call+0xe8/0x140)
[<c0398180>] (cpuidle_idle_call) from [<c000f2b0>] (arch_cpu_idle+0x8/0x3c)
[<c000f2b0>] (arch_cpu_idle) from [<c0068cec>] (cpu_startup_entry+0xc4/0x12c)
[<c0068cec>] (cpu_startup_entry) from [<000085e4>] (0x85e4)
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at
/opt/Xilinx/petalinux-v2014.2-final/components/linux-kernel/xlnx-3.14/kernel/time/tick-broadcast.c:617
tick_handle_oneshot_broadcast+0x144/0x1cc()
Modules linked in: ipv6
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D      3.14.2-xilinx #2
[<c0015658>] (unwind_backtrace) from [<c00119b4>] (show_stack+0x10/0x14)
[<c00119b4>] (show_stack) from [<c0490688>] (dump_stack+0x8c/0xd0)
[<c0490688>] (dump_stack) from [<c002295c>] (warn_slowpath_common+0x60/0x84)
[<c002295c>] (warn_slowpath_common) from [<c0022a10>]
(warn_slowpath_null+0x18/0x20)
[<c0022a10>] (warn_slowpath_null) from [<c007bc74>]
(tick_handle_oneshot_broadcast+0x144/0x1cc)
[<c007bc74>] (tick_handle_oneshot_broadcast) from [<c03af8cc>]
(ttc_clock_event_interrupt+0x18/0x20)
[<c03af8cc>] (ttc_clock_event_interrupt) from [<c0069514>]
(handle_irq_event_percpu+0x2c/0x170)
[<c0069514>] (handle_irq_event_percpu) from [<c0069694>]
(handle_irq_event+0x3c/0x5c)
[<c0069694>] (handle_irq_event) from [<c006c340>] (handle_fasteoi_irq+0xb4/0xfc)
[<c006c340>] (handle_fasteoi_irq) from [<c0068d84>]
(generic_handle_irq+0x20/0x30)
[<c0068d84>] (generic_handle_irq) from [<c000efa4>] (handle_IRQ+0x68/0x90)
[<c000efa4>] (handle_IRQ) from [<c0008530>] (gic_handle_irq+0x3c/0x60)
[<c0008530>] (gic_handle_irq) from [<c0012444>] (__irq_svc+0x44/0x78)
Exception stack(0xc0a11bf0 to 0xc0a11c38)
1be0:                                     c048e054 00000000 00000103 00000000
1c00: 00000000 0000000b 00000000 c0a5dec8 c0a1cd8c c0490d0c 00000000 00000001
1c20: c00673bc c0a11c38 c048e054 c048e058 600f0113 ffffffff
[<c0012444>] (__irq_svc) from [<c048e058>] (panic+0x164/0x1dc)
[<c048e058>] (panic) from [<c0011c38>] (die+0x280/0x39c)
[<c0011c38>] (die) from [<c00082cc>] (do_undefinstr+0x88/0x17c)
[<c00082cc>] (do_undefinstr) from [<c00124f0>] (__und_svc_finish+0x0/0x30)
Exception stack(0xc0a11d88 to 0xc0a11dd0)
1d80:                   0000007d 00000110 00000000 600f0113 ee34c940 ee349c40
1da0: ee349c00 c05d82a2 c0a1b384 ee91d810 00000001 2e349c40 c0b220e8 c0a11dd0
1dc0: c0490d0c c0490d0c 600f0113 ffffffff
[<c00124f0>] (__und_svc_finish) from [<c0490d0c>] (skb_panic+0x50/0x5c)
[<c0490d0c>] (skb_panic) from [<c03cfa74>] (skb_put+0x44/0x50)
[<c03cfa74>] (skb_put) from [<c0312914>] (xemacps_rx_poll+0x23c/0x3f0)
[<c0312914>] (xemacps_rx_poll) from [<c03de320>] (net_rx_action+0xb8/0x180)
[<c03de320>] (net_rx_action) from [<c0026cc0>] (__do_softirq+0x120/0x278)
[<c0026cc0>] (__do_softirq) from [<c0027104>] (irq_exit+0x84/0xf4)
[<c0027104>] (irq_exit) from [<c000efa8>] (handle_IRQ+0x6c/0x90)
[<c000efa8>] (handle_IRQ) from [<c0008530>] (gic_handle_irq+0x3c/0x60)
[<c0008530>] (gic_handle_irq) from [<c0012444>] (__irq_svc+0x44/0x78)
Exception stack(0xc0a11f18 to 0xc0a11f60)
1f00:                                                       00000001 00000004
1f20: 00000000 c0a1b6b0 9c2ebc89 00000006 00000000 eefd4448 9c7c1fe7 00000006
1f40: c0f84aa8 00000000 00000008 c0a11f60 c005ec48 c0398008 200f0013 ffffffff
[<c0012444>] (__irq_svc) from [<c0398008>] (cpuidle_enter_state+0x54/0xe4)
[<c0398008>] (cpuidle_enter_state) from [<c0398180>]
(cpuidle_idle_call+0xe8/0x140)
[<c0398180>] (cpuidle_idle_call) from [<c000f2b0>] (arch_cpu_idle+0x8/0x3c)
[<c000f2b0>] (arch_cpu_idle) from [<c0068cec>] (cpu_startup_entry+0xc4/0x12c)
[<c0068cec>] (cpu_startup_entry) from [<c067cab4>] (start_kernel+0x324/0x380)
---[ end trace 53dd86e60cb384fa ]---
random: nonblocking pool is initialized

Regards,
Punnaiah

On Thu, Jul 3, 2014 at 12:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-07-03 at 09:07 +0530, punnaiah choudary kalluri wrote:
>> Hi,
>>
>>   While sending the data traffic on zynq development board using 10 mbps
>>  half-duplex link, observed the kernel BUG in skbuff handling.
>>
>> Zynq setup:
>> ifconfig eth0 192.186.1.2
>>
>> Host machine setup:
>> ifconfig eth0 192.186.1.3
>> ethtool -s eth0 speed 10 duplex half
>> tcpreplay -i eth0 kernelpaniccapturejune24.pcap
>>
>>  Any pointers/directions for finding the root cause for this issue ?
>>
>> root@zynq:~# [  128.841470] random: nonblocking pool is initialized
>> [  141.726352] skbuff: skb_over_panic: text:c031b890 len:16383
>> put:16383 head:eea80000 data:eea80040 tail:0xeea8403f end:0xeea80640
>> dev:eth0
>> [  141.726354] ------------[ cut here ]------------
>> [  141.726354] kernel BUG at net/core/skbuff.c:126!
>> [  141.726355] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>> [  141.726356] Modules linked in: ipv6
>> [  141.726357] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-xilinx #1
>> [  141.726358] task: c06af670 ti: c06a4000 task.ti: c06a4000
>> [  141.726358] PC is at skb_panic+0x50/0x5c
>> [  141.726359] LR is at skb_panic+0x50/0x5c
>> [  141.726360] pc : [<c0494d68>]    lr : [<c0494d68>]    psr: 60070113
>> [  141.726360] sp : c06a5de8  ip : c07b8da8  fp : 2ea80040
>> [  141.726362] r10: ef10b810  r9 : c06af344  r8 : 00000000
>> [  141.726362] r7 : c05d39c4  r6 : eea80000  r5 : eea80040  r4 : eea8403f
>> [  141.726364] r3 : c06af670  r2 : 00000000  r1 : 60070113  r0 : 0000007d
>> [  141.726365] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
>> Segment kernel
>> [  141.726366] Control: 18c5387d  Table: 2e9c404a  DAC: 00000015
>> [  141.726367] Process swapper/0 (pid: 0, stack limit = 0xc06a4240)
>> [  141.726368] Stack: (0xc06a5de8 to 0xc06a6000)
>>
>> Regards,
>
> Kernel stack trace would be useful.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
