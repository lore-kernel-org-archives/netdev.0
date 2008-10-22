From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Wed, 22 Oct 2008 10:06:58 +0400
Message-ID: <48FEC302.5090707@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:59864 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbYJVGHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 02:07:01 -0400
In-Reply-To: <20081016084027.GA17632@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!
I get more information.

Statistics of PC:
1. 2.6.26.6 Dunamic Timer, HiResTimer, 1000HZ, htb_hysteresis=0 -
crashed 1d 18h ago
2. 2.6.26.5 HZ300, NO Dunamic Timer, No HiResTimer, htb_hysteresis=0 -
uptime 5d 17h (no crashes for now, but it crashed some time ago with
htb_hysteresis=1)
3. 2.6.27, 1000HZ, NO Dunamic Timer, No HiResTimer, htb_hysteresis=0 +
PATCH - uptime 5d 17h (no crashes for now, but it crashed some time ago
without patch)

Also attach crash log of lash crash PC 1:

[10610.110729] BUG: NMI Watchdog detected LOCKUP on CPU1, ip c01fd939,
registers:
[10610.110729] Modules linked in: netconsole e1000e i2c_i801 i2c_core e1000
[10610.110729]
[10610.110729] Pid: 0, comm: swapper Not tainted (2.6.26.6-fw #1)
[10610.110729] EIP: 0060:[<c01fd939>] EFLAGS: 00000082 CPU: 1
[10610.110729] EIP is at rb_insert_color+0x19/0xc0
[10610.110729] EAX: f6c23ca4 EBX: f6c23ca4 ECX: 00000000 EDX: f6c23ca4
[10610.110729] ESI: f6c23ca4 EDI: f6c23ca4 EBP: c20190e0 ESP: f7c4dc98
[10610.110729]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[10610.110729] Process swapper (pid: 0, ti=f7c4c000 task=f7c314a0
task.ti=f7c4c000)
[10610.110729] Stack: f6c23ca8 f6c23ca4 f6c23ca4 00000000 c013b672
c20190e0 00000001 c20190d8
[10610.110729]        c20190d8 f6c23ca4 c202d0d8 c04470a0 c013bd4d
00000000 f7c4dcf4 7c491000
[10610.110729]        000009a5 00000001 00000286 f6c23800 ffffffff
00000000 00000000 c02d407e
[10610.110729] Call Trace:
[10610.110729]  [<c013b672>] enqueue_hrtimer+0x72/0xf0
[10610.110729]  [<c013bd4d>] hrtimer_start+0xad/0x150
[10610.110729]  [<c02d407e>] qdisc_watchdog_schedule+0x1e/0x30
[10610.110729]  [<c02d9826>] htb_dequeue+0x6a6/0x810
[10610.110729]  [<c02d3f72>] tc_classify+0x42/0x90
[10610.110729]  [<c02dab22>] sfq_enqueue+0x22/0x230
[10610.110729]  [<c02d9c40>] htb_enqueue+0x0/0x1e0
[10610.110729]  [<c02d2efc>] __qdisc_run+0x19c/0x1d0
[10610.110729]  [<c02d9c40>] htb_enqueue+0x0/0x1e0
[10610.110729]  [<c02c7737>] dev_queue_xmit+0x267/0x380
[10610.110729]  [<c02e8ab0>] ip_forward_finish+0x0/0x40
[10610.110729]  [<c02eb65f>] ip_finish_output+0x11f/0x280
[10610.110729]  [<c02e8d7f>] ip_forward+0x28f/0x2d0
[10610.110729]  [<c02e8ad5>] ip_forward_finish+0x25/0x40
[10610.110729]  [<c02e7612>] ip_rcv_finish+0x122/0x360
[10610.110729]  [<c02bfa87>] __alloc_skb+0x57/0x120
[10610.110729]  [<c0109c8a>] nommu_map_single+0x2a/0x60
[10610.110729]  [<c02e7a90>] ip_rcv+0x0/0x290
[10610.110729]  [<c02c45cb>] netif_receive_skb+0x26b/0x470
[10610.110729]  [<f886c75d>] e1000_receive_skb+0x4d/0x1b0 [e1000e]
[10610.110729]  [<f886f9cc>] e1000_clean_rx_irq+0x23c/0x300 [e1000e]
[10610.110729]  [<f886bf69>] e1000_clean+0x49/0x1f0 [e1000e]
[10610.110729]  [<c02c69d8>] net_rx_action+0xf8/0x1b0
[10610.110729]  [<c012a922>] __do_softirq+0x82/0x100
[10610.110729]  [<c012a9d7>] do_softirq+0x37/0x40
[10610.110729]  [<c012ad27>] irq_exit+0x57/0x80
[10610.110729]  [<c0107120>] do_IRQ+0x40/0x80
[10610.110729]  [<c0114097>] smp_apic_timer_interrupt+0x57/0x90
[10610.110729]  [<c01055a3>] common_interrupt+0x23/0x28
[10610.110729]  [<c010a602>] mwait_idle+0x32/0x40
[10610.110729]  [<c010a5d0>] mwait_idle+0x0/0x40
[10610.110729]  [<c01036f3>] cpu_idle+0x53/0xc0
[10610.110729]  =======================
[10610.110729] Code: c4 0c c3 89 56 04 eb e3 8d 76 00 8d bc 27 00 00 00
00 55 89 d5 57 89 c7 56 53 90 8d b4 26 00 00 00 00 8b 1f 83 e3 fc 74 32
8b 03 <89> d9 a8 01 75 2a 89 c6 83 e6 fc 8b 56 08 39 d3 74 45 85 d2 74

Thanks!
Best regals, Badalian Vyacheslav

> On Thu, Oct 16, 2008 at 12:28:46PM +0400, Badalian Vyacheslav wrote:
> ...
>   
>> Sorry for long answer.
>>
>> We have troubles with power in our server place. Now its gone and i will
>> test again all this.
>>
>> With patch +  htb_hysteresis=0 and htb_hysteresis=1 without patch all PC
>> work done 2 days and 18 hours. After this we have power crash.... =(
>>     
>
> No need to hurry: you've written it's not everyday. Better try to make
> sure there is really a diffrence after any of these changes.
>
> Thanks,
> Jarek P.
>
>   

