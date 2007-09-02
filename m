From: slavon@bigtelecom.ru
Subject: Re: potentially kernel panic on lib/rbtree.c
Date: Mon, 03 Sep 2007 00:18:11 +0400
Message-ID: <20070903001811.xy2tpaphws0s0w8s@mail.himki.net>
References: <20070902230126.bvcrzuiw1wogk40c@mail.himki.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:39015 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbXIBUSP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 16:18:15 -0400
In-Reply-To: <20070902230126.bvcrzuiw1wogk40c@mail.himki.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hm...
Not good.

After patch NETCONSOLE log:

---- THERE MANY MESSAGES LIKE DOWN ----
[16038.677029] WARNING: at net/sched/sch_htb.c:362 htb_safe_rb_erase()
[16038.677031]  [<f8862a45>] htb_dequeue+0x13d/0x6d2 [sch_htb]
[16038.677038]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[16038.677043]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[16038.677048]  [<c02b94e3>] ip_output+0x281/0x2ba
[16038.677054]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677059]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[16038.677064]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677070]  [<c02b4729>] ip_rcv+0x484/0x4bd
[16038.677075]  [<c029750b>] __netdev_alloc_skb+0x1c/0x35
[16038.677081]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[16038.677086]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[16038.677092]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[16038.677097]  [<c0233f8f>] e1000_clean+0x7a/0x249
[16038.677103]  [<c029ccad>] net_rx_action+0x91/0x17f
[16038.677108]  [<c01225e2>] __do_softirq+0x5d/0xc1
[16038.677114]  [<c0122678>] do_softirq+0x32/0x36
[16038.677118]  [<c010488a>] do_IRQ+0x7e/0x90
[16038.677123]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[16038.677128]  [<c02ea9d5>] __sched_text_start+0x54d/0x5ba
[16038.677134]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677139]  [<c01032eb>] common_interrupt+0x23/0x28
[16038.677144]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[16038.677149]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677154]  [<c0100ea4>] cpu_idle+0x91/0xaa
[16038.677159]  =======================
[16038.677161] WARNING: at net/sched/sch_htb.c:362 htb_safe_rb_erase()
[16038.677163]  [<f8862a45>] htb_dequeue+0x13d/0x6d2 [sch_htb]
[16038.677170]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[16038.677175]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[16038.677180]  [<c02b94e3>] ip_output+0x281/0x2ba
[16038.677185]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677191]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[16038.677196]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677202]  [<c02b4729>] ip_rcv+0x484/0x4bd
[16038.677207]  [<c029750b>] __netdev_alloc_skb+0x1c/0x35
[16038.677212]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[16038.677218]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[16038.677224]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[16038.677229]  [<c0233f8f>] e1000_clean+0x7a/0x249
[16038.677234]  [<c029ccad>] net_rx_action+0x91/0x17f
[16038.677240]  [<c01225e2>] __do_softirq+0x5d/0xc1
[16038.677245]  [<c0122678>] do_softirq+0x32/0x36
[16038.677250]  [<c010488a>] do_IRQ+0x7e/0x90
[16038.677255]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[16038.677260]  [<c02ea9d5>] __sched_text_start+0x54d/0x5ba
[16038.677266]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677270]  [<c01032eb>] common_interrupt+0x23/0x28
[16038.677276]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[16038.677281]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677285]  [<c0100ea4>] cpu_idle+0x91/0xaa
[16038.677290]  =======================
[16038.677293] WARNING: at net/sched/sch_htb.c:362 htb_safe_rb_erase()
[16038.677295]  [<f8862a45>] htb_dequeue+0x13d/0x6d2 [sch_htb]
[16038.677301]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[16038.677306]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[16038.677312]  [<c02b94e3>] ip_output+0x281/0x2ba
[16038.677317]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677323]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[16038.677328]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677333]  [<c02b4729>] ip_rcv+0x484/0x4bd
[16038.677339]  [<c029750b>] __netdev_alloc_skb+0x1c/0x35
[16038.677344]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[16038.677350]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[16038.677356]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[16038.677361]  [<c0233f8f>] e1000_clean+0x7a/0x249
[16038.677366]  [<c029ccad>] net_rx_action+0x91/0x17f
[16038.677372]  [<c01225e2>] __do_softirq+0x5d/0xc1
[16038.677377]  [<c0122678>] do_softirq+0x32/0x36
[16038.677382]  [<c010488a>] do_IRQ+0x7e/0x90
[16038.677387]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[16038.677393]  [<c02ea9d5>] __sched_text_start+0x54d/0x5ba
[16038.677398]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677403]  [<c01032eb>] common_interrupt+0x23/0x28
[16038.677408]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[16038.677413]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677417]  [<c0100ea4>] cpu_idle+0x91/0xaa
[16038.677422]  =======================
[16038.677425] WARNING: at net/sched/sch_htb.c:362 htb_safe_rb_erase()
[16038.677427]  [<f8862a45>] htb_dequeue+0x13d/0x6d2 [sch_htb]
[16038.677433]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[16038.677439]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[16038.677444]  [<c02b94e3>] ip_output+0x281/0x2ba
[16038.677450]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677455]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[16038.677460]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677466]  [<c02b4729>] ip_rcv+0x484/0x4bd
[16038.677471]  [<c029750b>] __netdev_alloc_skb+0x1c/0x35
[16038.677476]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
[16038.677482]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
[16038.677488]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
[16038.677493]  [<c0233f8f>] e1000_clean+0x7a/0x249
[16038.677498]  [<c029ccad>] net_rx_action+0x91/0x17f
[16038.677504]  [<c01225e2>] __do_softirq+0x5d/0xc1
[16038.677509]  [<c0122678>] do_softirq+0x32/0x36
[16038.677514]  [<c010488a>] do_IRQ+0x7e/0x90
[16038.677519]  [<c0111619>] smp_apic_timer_interrupt+0x74/0x80
[16038.677524]  [<c02ea9d5>] __sched_text_start+0x54d/0x5ba
[16038.677530]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677534]  [<c01032eb>] common_interrupt+0x23/0x28
[16038.677540]  [<c0100d61>] mwait_idle_with_hints+0x3b/0x3f
[16038.677545]  [<c0100d65>] mwait_idle+0x0/0xa
[16038.677551]  [<c0100ea4>] cpu_idle+0x91/0xaa
[16038.677556]  =======================
[16038.677558] WARNING: at net/sched/sch_htb.c:362 htb_safe_rb_erase()
[16038.677560]  [<f8862a45>] htb_dequeue+0x13d/0x6d2 [sch_htb]
[16038.677567]  [<c02a71af>] __qdisc_run+0x2a/0x16b
[16038.677573]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
[16038.677578]  [<c02b94e3>] ip_output+0x281/0x2ba
[16038.677583]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677589]  [<c02b59b5>] ip_forward+0x26b/0x2c6
[16038.677594]  [<c02b571c>] ip_forward_finish+0x0/0x2e
[16038.677599]  [<c02b4729>] ip_rcv+0x484/0x4bd
--- SYSTEM IS REBOOT ---

now i try "return"
lib/rbtree.c:80

+if (gparent == NULL){
+         WARN_ON(1);
+         return;
+}

maybe "continue" not good idea....



> Sorry for prev. send =(
>
> Hi all. Have some time panic from sch_htb.c
>
> I see to gdb and see that panic at lib/rbtree.c:80
> gparent == NULL
>
> maybe add lines like this before IF
>
> if (gparent == NULL){
>     WARN_ON(1);
> // MAYBE need remove parrent that not have gparent at this place? But i
> think that maybe its not  have gparent becouse its lock? No so deep
> look code.
>     continue;
> }
>
> Thanks
>
>
> ----------------------------------------------------------------
> This message was sent using IMP, the Internet Messaging Program.
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

