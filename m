From: punnaiah choudary kalluri <punnaia@xilinx.com>
Subject: Re: Kernel BUG while sending data on 10mbps halfduplex link
Date: Tue, 8 Jul 2014 12:25:54 +0530
Message-ID: <CAGnW=BbtrqHhUuvSAyuCBVR91bKFnRicSH4JSZj=iS2yWafNAg@mail.gmail.com>
References: <CAGnW=BZb_DHb7JHc0h_4mWH0q8K9mONnwW554jwnsaxFAW25WA@mail.gmail.com>
	<1404370448.23797.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAGnW=Bbhzj9peNEvC4Tem-hFp3K4Sq1TT9f3V6=NwjqAF=OgOw@mail.gmail.com>
	<1404801680.3515.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, anirudh@xilinx.com,
	svemula@xilinx.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:32920 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaGHGz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 02:55:56 -0400
Received: by mail-la0-f45.google.com with SMTP id hr17so3683120lab.32
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 23:55:55 -0700 (PDT)
In-Reply-To: <1404801680.3515.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2014 at 12:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-07-08 at 09:57 +0530, punnaiah choudary kalluri wrote:
>> Hi Eric,
>>
>>     Here is the stack trace dump.
>>
>> skb_over_panic: text:c0312914 len:11520 put:11520 head:ee349c00
>> data:ee349c40 tail:0xee34c940 end:0xee34a240 dev:eth0
>> ------------[ cut here ]------------
>> kernel BUG at /opt/Xilinx/petalinux-v2014.2-final/components/linux-kernel/xlnx-3.14/net/core/skbuff.c:99!
>> Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>> Modules linked in: ipv6
>> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.2-xilinx #2
>> task: c0a1b6b0 ti: c0a10000 task.ti: c0a10000
>> PC is at skb_panic+0x50/0x5c
>> LR is at skb_panic+0x50/0x5c
>> pc : [<c0490d0c>]    lr : [<c0490d0c>]    psr: 600f0113
>> sp : c0a11dd0  ip : c0b220e8  fp : 2e349c40
>> r10: 00000001  r9 : ee91d810  r8 : c0a1b384
>> r7 : c05d82a2  r6 : ee349c00  r5 : ee349c40  r4 : ee34c940
>> r3 : 600f0113  r2 : 00000000  r1 : 00000110  r0 : 0000007d
>> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
>> Control: 18c5387d  Table: 2e19404a  DAC: 00000015
>> Process swapper/0 (pid: 0, stack limit = 0xc0a10240)
>> Stack: (0xc0a11dd0 to 0xc0a12000)
>> 1dc0:                                     00002d00 ee349c00 ee349c40 ee34c940
>> 1de0: ee34a240 ee8ff000 00000000 ee34c940 00002d00 00000000 00000000 c03cfa74
>> 1e00: ee8ff71c f01a50b0 ee1f0b40 c0312914 00000001 2e3db840 00000001 c005f7d0
>> 1e20: 2e3db840 ee1f0c00 00000000 ee8ff69c 00002d00 00000600 00000040 00000040
>> 1e40: c0a556ec ee8ff71c eefd58c0 0000012c 00000040 eefd58c8 c0a556ec ffff95ea
>> 1e60: c0a120c0 c03de320 c0a1208c ffff95ea c03de268 c0a10000 00000008 c0a12080
>> 1e80: c0a10018 00000101 c0a1208c 00000001 c0a5e340 c0026cc0 00000000 c00696a0
>> 1ea0: 00000000 00000003 40000003 0000000a 00200000 ffff95e9 00000000 00000004
>> 1ec0: 9c7c1fe7 c0a10028 c0a0e1b4 00000000 c0a11f4c 9c7c1fe7 00000006 c0f84aa8
>> 1ee0: 00000000 c0027104 c0a10000 00000036 c0a0e1b4 c000efa8 f8f00100 c0a11f18
>> 1f00: c0a19238 c0008530 c0398008 200f0013 ffffffff c0012444 00000001 00000004
>> 1f20: 00000000 c0a1b6b0 9c2ebc89 00000006 00000000 eefd4448 9c7c1fe7 00000006
>> 1f40: c0f84aa8 00000000 00000008 c0a11f60 c005ec48 c0398008 200f0013 ffffffff
>> 1f60: 9c7c1fe7 00000006 00000000 eefd4448 c0a10038 eefd4448 00000000 00000000
>> 1f80: 00000000 c0a4c2b8 00000000 c0398180 c0a10000 c0a10038 c0a5d8c0 ffffffff
>> 1fa0: c06a39d8 c0a183c0 ef7fce00 c000f2b0 c0a1b6b0 c0068cec c049b77c c067cab4
>> 1fc0: ffffffff ffffffff c067c570 00000000 00000000 c06a39d8 18c5387d c0a1840c
>> 1fe0: c06a39d4 c0a1cdbc 0000406a 413fc090 00000000 00008074 00000000 00000000
>> [<c0490d0c>] (skb_panic) from [<c03cfa74>] (skb_put+0x44/0x50)
>> [<c03cfa74>] (skb_put) from [<c0312914>] (xemacps_rx_poll+0x23c/0x3f0)
>> [<c0312914>] (xemacps_rx_poll) from [<c03de320>] (net_rx_action+0xb8/0x180)
>> [<c03de320>] (net_rx_action) from [<c0026cc0>] (__do_softirq+0x120/0x278)
>> [<c0026cc0>] (__do_softirq) from [<c0027104>] (irq_exit+0x84/0xf4)
>> [<c0027104>] (irq_exit) from [<c000efa8>] (handle_IRQ+0x6c/0x90)
>> [<c000efa8>] (handle_IRQ) from [<c0008530>] (gic_handle_irq+0x3c/0x60)
>> [<c0008530>] (gic_handle_irq) from [<c0012444>] (__irq_svc+0x44/0x78)
>> Exception stack(0xc0a11f18 to 0xc0a11f60)
>
> This is an out of tree driver.
>
> You should add a pointer to the source code if you want some help from
> us.

Here is the link for source code

https://github.com/Xilinx/linux-xlnx/blob/master-next/drivers/net/ethernet/xilinx/xilinx_emacps.c

>
> Hint: before trusting frame length given by the hardware, add a check to
> make sure its not bigger than allocated skb.

Thanks for the hit. I will add this check to the driver and see if
hardware reports invalid length

Regards,
Punnaiah
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
