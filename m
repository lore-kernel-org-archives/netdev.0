From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 14:50:27 +0400
Message-ID: <46D7F273.5010401@bigtelecom.ru>
References: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:36772 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760935AbXHaKua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 06:50:30 -0400
In-Reply-To: <20070831101733.GA3108@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get kernel panic on 2.6.23-rc4-git2
This is netconsole log!

[ 3931.002707] BUG: unable to handle kernel NULL pointer dereference at 
virtual address 00000008
[ 3931.002846]  printing eip:
[ 3931.002906] c01c8973
[ 3931.002967] *pde = 00000000
[ 3931.003031] Oops: 0000 [#1]
[ 3931.003093] SMP
[ 3931.003160] Modules linked in: cls_u32 sch_sfq sch_htb netconsole 
xt_tcpudp iptable_filter ip_tables x_tables i2c_i801 i2c_core
[ 3931.003327] CPU:    2
[ 3931.003327] EIP:    0060:[<c01c8973>]    Not tainted VLI
[ 3931.003328] EFLAGS: 00010246   (2.6.23-rc4-testing #1)
[ 3931.003526] EIP is at rb_insert_color+0x13/0xad
[ 3931.003594] eax: 00000000   ebx: e9570324   ecx: e9570324   edx: f6deac48
[ 3931.003663] esi: 00000000   edi: ef5c4124   ebp: f6dea8a0   esp: e25f5d6c
[ 3931.003731] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[ 3931.003796] Process sh (pid: 6146, ti=e25f4000 task=c268b290 
task.ti=e25f4000)
[ 3931.003866] Stack: f6deac48 00000569 00000000 ef5c4000 f6dea8a0 
f8862a9d f881c5db e1fda780
[ 3931.004016]        00000003 f6db6dc0 f6deac48 f6dea800 00000000 
00000000 dfc3e9b2 00000000
[ 3931.004161]        e25f5dd8 00000000 c02a774b 00000002 e25f5e70 
f6dea930 f6dea930 00000000
[ 3931.004307] Call Trace:
[ 3931.004434]  [<f8862a9d>] htb_dequeue+0x195/0x6d2 [sch_htb]
[ 3931.004510]  [<f881c5db>] ipt_do_table+0x41f/0x47c [ip_tables]
[ 3931.004584]  [<c02a774b>] tc_classify+0x17/0x7c
[ 3931.004658]  [<f8861925>] htb_activate_prios+0x9b/0xa5 [sch_htb]
[ 3931.004730]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[ 3931.004798]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[ 3931.004874]  [<c02b94e3>] ip_output+0x281/0x2ba
[ 3931.004947]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[ 3931.005012]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[ 3931.005081]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[ 3931.005150]  [<c02b4729>] ip_rcv+0x484/0x4bd
[ 3931.005216]  [<c013dcc5>] file_read_actor+0x0/0xdb
[ 3931.005293]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[ 3931.005362]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[ 3931.005437]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[ 3931.005506]  [<c0233f8f>] e1000_clean+0x7a/0x249
[ 3931.005574]  [<c029ccad>] net_rx_action+0x91/0x17f
[ 3931.005642]  [<c01225e2>] __do_softirq+0x5d/0xc1
[ 3931.005714]  [<c0122678>] do_softirq+0x32/0x36
[ 3931.005779]  [<c010488a>] do_IRQ+0x7e/0x90
[ 3931.005849]  [<c01032eb>] common_interrupt+0x23/0x28
[ 3931.005923]  =======================
[ 3931.005986] Code: 56 04 eb 07 89 56 08 eb 02 89 17 8b 03 83 e0 03 09 
d0 89 03 5b 5e 5f c3 55 57 89 c7 56 53 83 ec 04 89 14 24 eb 7e 89 c6 83 
e6 fc <8b> 56 08 39 d3 75 34 8b 56 04 85 d2 74 06 8b 02 a8 01 74 31 8b
[ 3931.006386] EIP: [<c01c8973>] rb_insert_color+0x13/0xad SS:ESP 
0068:e25f5d6c
[ 3931.006757] Kernel panic - not syncing: Fatal exception in interrupt
[ 3931.006863] Rebooting in 3 seconds..

> BTW, -git versions are usually more risky than -rc. And, maybe, let
> this 2.6.18 better stay away from this testing...
>
> Thanks,
> Jarek P.
>
>   

