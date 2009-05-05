From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Tue, 5 May 2009 22:29:56 +0200
Message-ID: <F661DCE3-7DDC-42BE-AE0F-937C3478A33C@it-loops.com>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com> <20090505122735.b87dd129.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756005AbZEEUaW@vger.kernel.org>
In-Reply-To: <20090505122735.b87dd129.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 5, 2009, at 21:27, Andrew Morton wrote:

> skb_over_panic().  There should have been some additional information
> printed before the "cut here" text.  That might be useful in fixing
> this regression.
>

Here is a full dump from the console again including the line before  
the "cut here" text.
Wan is the device going to the ADSL-modem.

[  172.251007] skb_over_panic: text:c0187650 len:1514 put:1514  
head:c79a8800 data:c79a8880 tail:0xc79a8e6a end:0xc79a8e60 dev:wan
[  172.262613] ------------[ cut here ]------------
[  172.267250] kernel BUG at net/core/skbuff.c:126!
[  172.271884] Oops: Exception in kernel mode, sig: 5 [#1]
[  172.277121] MikroTik RouterBOARD 600 series
[  172.281312] Modules linked in: nf_nat_rtsp nf_conntrack_rtsp
[  172.287006] NIP: c01abc68 LR: c01abc68 CTR: c015559c
[  172.291986] REGS: c782bdd0 TRAP: 0700   Not tainted  (2.6.30-rc4)
[  172.298094] MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002024  XER:  
20000000
[  172.304776] TASK = c7820940[3] 'ksoftirqd/0' THREAD: c782a000
[  172.310361] GPR00: c01abc68 c782be80 c7820940 00000085 0000295e  
ffffffff c0152b68 00000030
[  172.318788] GPR08: c03848d4 c0350000 0000295e c0380398 84002022  
efffdbdf 007d66c0 00000008
[  172.327215] GPR16: 00000000 00000040 c02f6260 c02f628c c7846380  
c782a000 c7954800 00000000
[  172.335641] GPR24: 00000001 0000003f c7951780 c7954e38 c7846000  
000005ea c79e4480 c79a8880
[  172.344263] NIP [c01abc68] skb_over_panic+0x48/0x5c
[  172.349156] LR [c01abc68] skb_over_panic+0x48/0x5c
[  172.353956] Call Trace:
[  172.356412] [c782be80] [c01abc68] skb_over_panic+0x48/0x5c  
(unreliable)
[  172.363060] [c782be90] [c01ad468] skb_put+0x5c/0x60
[  172.367969] [c782bea0] [c0187650] gfar_clean_rx_ring+0x204/0x42c
[  172.374003] [c782bef0] [c0189074] gfar_poll+0x258/0x338
[  172.379264] [c782bf40] [c01b8b8c] net_rx_action+0x9c/0x190
[  172.384787] [c782bf70] [c002ddac] __do_softirq+0x84/0x100
[  172.390218] [c782bfa0] [c0006474] do_softirq+0x58/0x5c
[  172.395382] [c782bfb0] [c002d934] ksoftirqd+0x60/0x114
[  172.400549] [c782bfd0] [c003f050] kthread+0x4c/0x88
[  172.405450] [c782bff0] [c0013b10] kernel_thread+0x4c/0x68
[  172.410866] Instruction dump:
[  172.413843] 80a30054 2f800000 80e300a8 810300ac 816300a0 814300a4  
419e0020 3c60c030
[  172.421656] 7d695b78 90010008 3863901c 4be7d091 <0fe00000> 48000000  
3d20c02d 380968b8
[  172.429651] Kernel panic - not syncing: Fatal exception in interrupt
[  172.436019] Call Trace:
[  172.438479] [c782bc20] [c0008274] show_stack+0x4c/0x16c (unreliable)
[  172.444866] [c782bc60] [c0027d1c] panic+0x90/0x170
[  172.449689] [c782bcb0] [c00118ac] die+0x19c/0x1d4
[  172.454417] [c782bcd0] [c0011b80] _exception+0x138/0x15c
[  172.459754] [c782bdc0] [c00143fc] ret_from_except_full+0x0/0x4c
[  172.465703] --- Exception: 700 at skb_over_panic+0x48/0x5c
[  172.465713]     LR = skb_over_panic+0x48/0x5c
[  172.475570] [c782be90] [c01ad468] skb_put+0x5c/0x60
[  172.480471] [c782bea0] [c0187650] gfar_clean_rx_ring+0x204/0x42c
[  172.486505] [c782bef0] [c0189074] gfar_poll+0x258/0x338
[  172.491757] [c782bf40] [c01b8b8c] net_rx_action+0x9c/0x190
[  172.497270] [c782bf70] [c002ddac] __do_softirq+0x84/0x100
[  172.502694] [c782bfa0] [c0006474] do_softirq+0x58/0x5c
[  172.507858] [c782bfb0] [c002d934] ksoftirqd+0x60/0x114
[  172.513021] [c782bfd0] [c003f050] kthread+0x4c/0x88
[  172.517920] [c782bff0] [c0013b10] kernel_thread+0x4c/0x68


Kind regards,
Michael
