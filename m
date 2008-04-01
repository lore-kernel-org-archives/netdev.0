From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: 2.6.25-rc6-git2: warn_on_slowpath for tcp_simple_retransmit
Date: Wed, 2 Apr 2008 00:28:36 +0200
Message-ID: <5a4c581d0804011528g786550c5sfd6bf90c0c37706@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Linux Kernel" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:63092 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759713AbYDAW2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 18:28:40 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1003025nfb.21
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 15:28:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found this in my FC6-based bittorrent box (K7-800 running
 a 2.6.25-rc6-git2 kernel) this evening.

The kernel was upgraded two weeks ago to fix the bug
 in which an USB VIA driver hammered the PCI bus
 causing ATA disk performance to drop, and has been
 running since then (it still is).

So it's actually 2.6.25-rc6-git2 plus patch as in here
http://www.gossamer-threads.com/lists/linux/kernel/895506#895506

If there's anything useful I can do, just ask. Thanks !

[1164423.381894] WARNING: at net/ipv4/tcp_output.c:1811
tcp_simple_retransmit+0xde/0x167()
[1164423.382797] Modules linked in: iptable_filter ip_tables x_tables
ipv6 sd_mod floppy usb_storage scsi_mod parport_pc parport ehci_hcd
uhci_hcd
[1164423.384115] Pid: 11864, comm: peerguardnf Not tainted 2.6.25-rc6-git2 #2
[1164423.384734]  [<c0114964>] warn_on_slowpath+0x41/0x51
[1164423.385262]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164423.385803]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164423.386235]  [<c02d6dfc>] ? __inet_lookup_established+0x171/0x17b
[1164423.386837]  [<c02e7235>] ? tcp_v4_err+0xf4/0x353
[1164423.387338]  [<c02e3f71>] tcp_simple_retransmit+0xde/0x167
[1164423.387883]  [<c02e733b>] tcp_v4_err+0x1fa/0x353
[1164423.388369]  [<c02eec6f>] ? icmp_unreach+0x1e7/0x280
[1164423.388893]  [<c02eecc6>] icmp_unreach+0x23e/0x280
[1164423.389392]  [<c02ee1ea>] icmp_rcv+0x1c9/0x1f1
[1164423.389893]  [<c02d08b2>] ip_local_deliver_finish+0xf6/0x1a1
[1164423.390453]  [<c02cc3c1>] nf_reinject+0xc3/0x136
[1164423.390940]  [<c02fb3d0>] ipq_rcv_skb+0x359/0x3b5
[1164423.391441]  [<c02c8d5c>] netlink_unicast+0x1b8/0x21c
[1164423.391968]  [<c02c98f9>] netlink_sendmsg+0x241/0x24e
[1164423.392487]  [<c02b166b>] sock_sendmsg+0xc9/0xe0
[1164423.392981]  [<c012455d>] ? autoremove_wake_function+0x0/0x33
[1164423.393560]  [<c020c81c>] ? copy_from_user+0x3b/0x5e
[1164423.394226]  [<c02b7d58>] ? verify_iovec+0x40/0x70
[1164423.394733]  [<c02b17cf>] sys_sendmsg+0x14d/0x1a8
[1164423.395228]  [<c020ca54>] ? copy_to_user+0x3d/0x49
[1164423.395733]  [<c02b1f57>] ? move_addr_to_user+0x3b/0x52
[1164423.396268]  [<c02b21a5>] ? sys_recvfrom+0xb8/0xc3
[1164423.396774]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164423.397305]  [<c010463e>] ? do_softirq+0x9a/0xa8
[1164423.397893]  [<c0102c8b>] ? restore_nocheck+0x12/0x15
[1164423.398417]  [<c012d209>] ? trace_hardirqs_on+0xe6/0x10d
[1164423.398957]  [<c0102c8b>] ? restore_nocheck+0x12/0x15
[1164423.399483]  [<c02b2577>] sys_socketcall+0x14e/0x166
[1164423.399995]  [<c0102bdd>] ? sysenter_past_esp+0x9a/0xa5
[1164423.400528]  [<c0102ba2>] sysenter_past_esp+0x5f/0xa5
[1164423.401047]  [<c0172824>] ? bio_fs_destructor+0x0/0x10
[1164423.401580]  =======================
[1164423.401892] ---[ end trace ec1e34ea2cdbd7ae ]---
[1164425.080514] ------------[ cut here ]------------
[1164425.081052] WARNING: at net/ipv4/tcp_input.c:1771
tcp_enter_frto+0x150/0x1ec()
[1164425.081910] Modules linked in: iptable_filter ip_tables x_tables
ipv6 sd_mod floppy usb_storage scsi_mod parport_pc parport ehci_hcd
uhci_hcd
[1164425.083225] Pid: 0, comm: swapper Not tainted 2.6.25-rc6-git2 #2
[1164425.083797]  [<c0114964>] warn_on_slowpath+0x41/0x51
[1164425.084323]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164425.084844]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164425.085374]  [<c012e0ab>] ? __lock_acquire+0xac8/0xb10
[1164425.085904]  [<c02e4eed>] ? tcp_write_timer+0x16/0x575
[1164425.086434]  [<c02e0644>] tcp_enter_frto+0x150/0x1ec
[1164425.086943]  [<c02e524c>] tcp_write_timer+0x375/0x575
[1164425.087458]  [<c011bb23>] run_timer_softirq+0x112/0x16d
[1164425.087985]  [<c02e4ed7>] ? tcp_write_timer+0x0/0x575
[1164425.088490]  [<c02e4ed7>] ? tcp_write_timer+0x0/0x575
[1164425.089012]  [<c0118c8e>] __do_softirq+0x51/0xa8
[1164425.089505]  [<c01045fc>] do_softirq+0x58/0xa8
[1164425.089986]  [<c013647d>] ? handle_level_irq+0x0/0xbf
[1164425.090511]  [<c0118bee>] irq_exit+0x3b/0x47
[1164425.090975]  [<c01046e4>] do_IRQ+0x98/0xad
[1164425.091428]  [<c0102e3a>] common_interrupt+0x2e/0x34
[1164425.091939]  [<c01017e5>] ? default_idle+0x45/0x72
[1164425.092490]  [<c01017a0>] ? default_idle+0x0/0x72
[1164425.092989]  [<c0101778>] cpu_idle+0x60/0x88
[1164425.093451]  [<c031b6f4>] rest_init+0x5c/0x5e
[1164425.093927]  =======================
[1164425.094334] ---[ end trace ec1e34ea2cdbd7ae ]---

--alessandro

 "Hold back the years, hold back the hours
  I want to live to see the sun break through these days"

   (Patrick Wolf, 'This Weather')
