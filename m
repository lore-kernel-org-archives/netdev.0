From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Tc bug (kernel crash) more info
Date: Wed, 29 Aug 2007 13:34:20 +0400
Message-ID: <46D53D9C.5070204@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:52228 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362AbXH2JeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 05:34:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 4F731A6C35C
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 13:34:22 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pQfos1i-O0+m for <netdev@vger.kernel.org>;
	Wed, 29 Aug 2007 13:34:21 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 298D4A6C015
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 13:34:21 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again crash.  Need more posts of panic or this message have full info 
that needed to fix bug?

BUG: unable to handle kernel NULL pointer dereference at virtual address 
00000008
 printing eip:
c01bf041
*pde = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: cls_u32 sch_sfq sch_htb netconsole xt_tcpudp 
iptable_filter ip_tables x_tables e752x_edac edac_mc i2c_i801
CPU:    2
EIP:    0060:[<c01bf041>]    Not tainted VLI
EFLAGS: 00010282   (2.6.22-gentoo-r5-fw #6)
EIP is at rb_erase+0x110/0x22f
eax: e40fa334   ebx: 00000000   ecx: 00000000   edx: e40fa334
esi: e6add334   edi: e5a86134   ebp: f6840428   esp: c21c5d20
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Process swapper (pid: 0, ti=c21c4000 task=c21b8a90 task.ti=c21c4000)
Stack: 00000001 e5a86134 00000000 e5a86000 00000055 f88391a7 f6840080 
00057857
       00000000 f0ac4600 f6840080 f883aa3d f6e53ec0 e6b18380 f6e53ec0 
00000008
       f6840428 f6840000 00000000 f6840080 00000000 61cf32bc 00000001 
e6b18380
Call Trace:
 [<f88391a7>] htb_safe_rb_erase+0x43/0x51 [sch_htb]
 [<f883aa3d>] htb_dequeue+0x145/0x6d4 [sch_htb]
 [<f88618fe>] sfq_enqueue+0x1c/0x18a [sch_sfq]
 [<c02b7592>] __qdisc_run+0x1e/0x188
 [<c02adcce>] dev_queue_xmit+0x152/0x25c
 [<c02c8f77>] ip_output+0x280/0x2b9
 [<c02c51cc>] ip_forward_finish+0x0/0x2e
 [<c02c5465>] ip_forward+0x26b/0x2c6
 [<c02c51cc>] ip_forward_finish+0x0/0x2e
 [<c02c41fb>] ip_rcv+0x484/0x4bd
 [<c02a8a0d>] __netdev_alloc_skb+0x1c/0x35
 [<c02abd54>] netif_receive_skb+0x2b8/0x319
 [<c0238034>] e1000_clean_rx_irq+0x375/0x441
 [<c0237cbf>] e1000_clean_rx_irq+0x0/0x441
 [<c02370ea>] e1000_clean+0x71/0x237
 [<c02ada90>] net_rx_action+0x91/0x17d
 [<c011c39a>] __do_softirq+0x5d/0xc1
 [<c011c430>] do_softirq+0x32/0x36
 [<c010439a>] do_IRQ+0x7e/0x90
 [<c010d461>] smp_apic_timer_interrupt+0x74/0x80
 [<c010439a>] do_IRQ+0x7e/0x90
 [<c0102ed3>] common_interrupt+0x23/0x28
 [<c0100ab2>] mwait_idle_with_hints+0x3c/0x40
 [<c0100bbe>] cpu_idle+0x5a/0x6f
 =======================
Code: 01 00 00 8b 4e 08 39 d9 0f 85 85 00 00 00 8b 4e 04 8b 01 a8 01 75 
14 83 c8 01 89 ea 89 01 89 f0 83 26 fe e8 1e fd ff ff 8b 4e 04 <8b> 59 
08 85 db 74 06 8b 03 a8 01 74 15 8b 41 04 85 c0 0f 84 c6
EIP: [<c01bf041>] rb_erase+0x110/0x22f SS:ESP 0068:c21c5d20
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 3 seconds..
