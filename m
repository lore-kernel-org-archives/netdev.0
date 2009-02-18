From: Ernst Herzberg <earny@net4u.de>
Subject: SKB BUG: Invalid truesize
Date: Wed, 18 Feb 2009 04:15:42 +0100
Message-ID: <200902180415.42497.earny@net4u.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moci.net4u.de ([217.7.64.195]:32944 "EHLO moci.net4u.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752251AbZBRD0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 22:26:16 -0500
Received: from localhost (localhost [127.0.0.1])
	by moci.net4u.de (Postfix) with ESMTP id DC14E138B452
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 03:15:48 +0000 (UTC)
Received: from moci.net4u.de ([127.0.0.1])
	by localhost (moci.net4u.de [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id XxG3gid09Zv8 for <netdev@vger.kernel.org>;
	Wed, 18 Feb 2009 03:15:44 +0000 (UTC)
Received: from seaborg.net4u.de (seaborg.net4u.de [192.168.55.3])
	by moci.net4u.de (Postfix) with ESMTPSA id 9E3971334E38
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 03:15:43 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


moin,

this BUG fills my syslogs since 2.6.25 (or .24? can't remeber),
but since 2.6.28.? it gives a nice calltrace .. and fills it even more;-)

Machine is used as a adsl router, pppoe with a traffic shaper, messages
are only written if 'iftop' http://www.ex-parrot.com/~pdw/iftop/ is running.

------------[ cut here ]------------
WARNING: at net/core/skbuff.c:150 sock_rfree+0x63/0x70()
SKB BUG: Invalid truesize (1632) len=1422, sizeof(sk_buff)=224
Modules linked in: cls_fw sch_sfq sch_htb xt_connbytes xt_mark xt_length xt_dscp xt_multiport xt_MARK xt_TCPMSS xt_tcpudp iptable_filter iptable_mangle iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables pppoe pppox ppp_generic slhc tun it87 hwmon_vid ppdev ehci_hcd pcspkr k8temp firewire_ohci firewire_core 
crc_itu_t ohci_hcd usbcore i2c_nforce2 parport_pc parport evdev
Pid: 9718, comm: iftop Not tainted 2.6.28.6 #1
Call Trace:
 [<ffffffff8022e6ed>] warn_slowpath+0xcd/0x110
 [<ffffffff8025c2fb>] get_page_from_freelist+0x2db/0x460
 [<ffffffff802295f5>] update_curr+0x55/0xb0
 [<ffffffff8022988d>] dequeue_entity+0x1d/0xb0
 [<ffffffff80229805>] set_next_entity+0x25/0x50
 [<ffffffff804aceb4>] thread_return+0x30/0x1bc
 [<ffffffff804ad1e5>] schedule_timeout+0x95/0xd0
 [<ffffffff8043f023>] sock_rfree+0x63/0x70
 [<ffffffff804423e7>] skb_release_head_state+0x37/0xb0
 [<ffffffff80442c29>] skb_release_all+0x9/0x20
 [<ffffffff804422e9>] __kfree_skb+0x9/0x80
 [<ffffffff8044536c>] skb_free_datagram+0xc/0x40
 [<ffffffff804a1223>] packet_recvmsg+0x1b3/0x1e0
 [<ffffffff802295f5>] update_curr+0x55/0xb0
 [<ffffffff8043bf75>] sock_recvmsg+0xd5/0x100
 [<ffffffff8022a5c1>] enqueue_task_fair+0x21/0x40
 [<ffffffff802414b0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80228f50>] __wake_up_common+0x50/0x80
 [<ffffffff80232869>] ns_to_timeval+0x9/0x40
 [<ffffffff8043b781>] sockfd_lookup_light+0x41/0x80
 [<ffffffff8043d172>] sys_recvfrom+0xe2/0x190
 [<ffffffff8043d9e4>] sock_ioctl+0x54/0x240
 [<ffffffff8028ad7b>] vfs_ioctl+0x1b/0x70
 [<ffffffff8028ae6c>] do_vfs_ioctl+0x7c/0x430
 [<ffffffff8020b45b>] system_call_fastpath+0x16/0x1b
---[ end trace 855e82560af6b46f ]---
------------[ cut here ]------------
WARNING: at net/core/skbuff.c:150 sock_rfree+0x63/0x70()
SKB BUG: Invalid truesize (416) len=198, sizeof(sk_buff)=224
Modules linked in: cls_fw sch_sfq sch_htb xt_connbytes xt_mark xt_length xt_dscp xt_multiport xt_MARK xt_TCPMSS xt_tcpudp iptable_filter iptable_mangle iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables pppoe pppox ppp_generic slhc tun it87 hwmon_vid ppdev ehci_hcd pcspkr k8temp firewire_ohci firewire_core 
crc_itu_t ohci_hcd usbcore i2c_nforce2 parport_pc parport evdev
Pid: 9718, comm: iftop Tainted: G        W  2.6.28.6 #1
Call Trace:
 [<ffffffff8022e6ed>] warn_slowpath+0xcd/0x110
 [<ffffffff8025c2fb>] get_page_from_freelist+0x2db/0x460
 [<ffffffff802295f5>] update_curr+0x55/0xb0
 [<ffffffff8022988d>] dequeue_entity+0x1d/0xb0
 [<ffffffff80229805>] set_next_entity+0x25/0x50
 [<ffffffff804aceb4>] thread_return+0x30/0x1bc
 [<ffffffff804ad1e5>] schedule_timeout+0x95/0xd0
 [<ffffffff8043f023>] sock_rfree+0x63/0x70
 [<ffffffff804423e7>] skb_release_head_state+0x37/0xb0
 [<ffffffff80442c29>] skb_release_all+0x9/0x20
 [<ffffffff804422e9>] __kfree_skb+0x9/0x80
 [<ffffffff8044536c>] skb_free_datagram+0xc/0x40
 [<ffffffff804a1223>] packet_recvmsg+0x1b3/0x1e0
 [<ffffffff802295f5>] update_curr+0x55/0xb0
 [<ffffffff8043bf75>] sock_recvmsg+0xd5/0x100
 [<ffffffff8022a5c1>] enqueue_task_fair+0x21/0x40
 [<ffffffff802414b0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80228f50>] __wake_up_common+0x50/0x80
 [<ffffffff80232869>] ns_to_timeval+0x9/0x40
 [<ffffffff8043b781>] sockfd_lookup_light+0x41/0x80
 [<ffffffff8043d172>] sys_recvfrom+0xe2/0x190
 [<ffffffff8043d9e4>] sock_ioctl+0x54/0x240
 [<ffffffff8028ad7b>] vfs_ioctl+0x1b/0x70
 [<ffffffff8028ae6c>] do_vfs_ioctl+0x7c/0x430
 [<ffffffff8020b45b>] system_call_fastpath+0x16/0x1b
---[ end trace 855e82560af6b46f ]---

earny
