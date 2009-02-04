From: Chris Wright <chrisw@sous-sol.org>
Subject: GSO checksum warning debug info
Date: Tue, 3 Feb 2009 16:23:45 -0800
Message-ID: <20090204002345.GF5220@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:55511 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751088AbZBDAyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 19:54:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm able to trigger the GSO checksum warning, and after 67fd1a73 "net: Add
debug info to track down GSO checksum bug" here's the more verbose output:

e1000e: caps=(0x1119a9, 0x0) len=2960 data_len=0 ip_summed=0

What info would be helpful for you (couple full backtraces below)?

thanks,
-chris


[ 2172.557466] WARNING: at /home/chrisw/git/linux/linus-2.6/net/core/dev.c:1548 skb_gso_segment+0x103/0x23a()
[ 2172.557468] Hardware name: To Be Filled By O.E.M.
[ 2172.557470] e1000e: caps=(0x1119a9, 0x0) len=2960 data_len=0 ip_summed=0Modules linked in: kvm_intel kvm [last unloaded: scsi_wait_scan]
[ 2172.557476] Pid: 4750, comm: qemu-kvm Not tainted 2.6.29-rc3 #13
[ 2172.557478] Call Trace:
[ 2172.557480]  <IRQ>  [<ffffffff8103acbd>] warn_slowpath+0xb1/0xed
[ 2172.557489]  [<ffffffff811b75ba>] ? alloc_iova+0x1e6/0x218
[ 2172.557492]  [<ffffffff811a29bd>] ? sprintf+0x40/0x42
[ 2172.557496]  [<ffffffff81290217>] ? tun_chr_aio_write+0x0/0x44d
[ 2172.557501]  [<ffffffff81267aa5>] ? e1000_get_drvinfo+0xa6/0xcd
[ 2172.557503]  [<ffffffff813a38aa>] skb_gso_segment+0x103/0x23a
[ 2172.557505]  [<ffffffff813a3b8d>] dev_hard_start_xmit+0x1ac/0x26d
[ 2172.557510]  [<ffffffff813b5759>] __qdisc_run+0xe7/0x1ea
[ 2172.557513]  [<ffffffff8102e81b>] ? enqueue_task+0x50/0x5b
[ 2172.557516]  [<ffffffff813a40b0>] dev_queue_xmit+0x350/0x44d
[ 2172.557520]  [<ffffffff8144fe98>] br_dev_queue_push_xmit+0x5c/0x62
[ 2172.557522]  [<ffffffff81035264>] ? default_wake_function+0xd/0xf
[ 2172.557524]  [<ffffffff8144feed>] br_forward_finish+0x4f/0x53
[ 2172.557526]  [<ffffffff8144ff5b>] __br_forward+0x6a/0x6e
[ 2172.557529]  [<ffffffff8144ffa8>] br_forward+0x49/0x57
[ 2172.557531]  [<ffffffff81450a97>] br_handle_frame_finish+0x12b/0x14f
[ 2172.557534]  [<ffffffff81450c73>] br_handle_frame+0x1b8/0x1d5
[ 2172.557536]  [<ffffffff813a3195>] netif_receive_skb+0x2ea/0x3bb
[ 2172.557538]  [<ffffffff813a3682>] napi_gro_receive+0x47/0x57
[ 2172.557541]  [<ffffffff8101bd8f>] ? lapic_next_event+0x15/0x19
[ 2172.557543]  [<ffffffff813a370f>] process_backlog+0x7d/0xb2
[ 2172.557545]  [<ffffffff813a17e9>] net_rx_action+0xa7/0x17a
[ 2172.557548]  [<ffffffff8103fcc3>] __do_softirq+0x83/0x144
[ 2172.557551]  [<ffffffff8100d33c>] call_softirq+0x1c/0x28
[ 2172.557552]  <EOI>  [<ffffffff8100e258>] do_softirq+0x34/0x76
[ 2172.557556]  [<ffffffff813a3765>] netif_rx_ni+0x21/0x28
[ 2172.557558]  [<ffffffff8129060d>] tun_chr_aio_write+0x3f6/0x44d
[ 2172.557561]  [<ffffffff810a0000>] ? sys_swapon+0x2bb/0xa58
[ 2172.557563]  [<ffffffff81290217>] ? tun_chr_aio_write+0x0/0x44d
[ 2172.557566]  [<ffffffff810b0153>] do_sync_readv_writev+0xe3/0x12b
[ 2172.557569]  [<ffffffff8104db04>] ? autoremove_wake_function+0x0/0x38
[ 2172.557574]  [<ffffffff8116e3ba>] ? selinux_file_permission+0xbd/0xc6
[ 2172.557578]  [<ffffffff811673b0>] ? security_file_permission+0x11/0x13
[ 2172.557580]  [<ffffffff810b089d>] do_readv_writev+0xba/0x121
[ 2172.557583]  [<ffffffff8116e3ba>] ? selinux_file_permission+0xbd/0xc6
[ 2172.557585]  [<ffffffff81035257>] ? default_wake_function+0x0/0xf
[ 2172.557587]  [<ffffffff811673b0>] ? security_file_permission+0x11/0x13
[ 2172.557589]  [<ffffffff810b0942>] vfs_writev+0x3e/0x49
[ 2172.557591]  [<ffffffff810b0994>] sys_writev+0x47/0x94
[ 2172.557593]  [<ffffffff8100c25b>] system_call_fastpath+0x16/0x1b
[ 2172.557595] ---[ end trace bbdce316762c5c8a ]---
[ 2172.558366] ------------[ cut here ]------------
[ 2172.558368] WARNING: at /home/chrisw/git/linux/linus-2.6/net/core/dev.c:1548 skb_gso_segment+0x103/0x23a()
[ 2172.558370] Hardware name: To Be Filled By O.E.M.
[ 2172.558371] e1000e: caps=(0x1119a9, 0x0) len=5880 data_len=0 ip_summed=0Modules linked in: kvm_intel kvm [last unloaded: scsi_wait_scan]
[ 2172.558375] Pid: 4750, comm: qemu-kvm Tainted: G        W  2.6.29-rc3 #13
[ 2172.558376] Call Trace:
[ 2172.558377]  <IRQ>  [<ffffffff8103acbd>] warn_slowpath+0xb1/0xed
[ 2172.558382]  [<ffffffff810be05c>] ? pollwake+0x47/0x4f
[ 2172.558384]  [<ffffffff81035257>] ? default_wake_function+0x0/0xf
[ 2172.558386]  [<ffffffff811a29bd>] ? sprintf+0x40/0x42
[ 2172.558389]  [<ffffffff81267aa5>] ? e1000_get_drvinfo+0xa6/0xcd
[ 2172.558391]  [<ffffffff813a38aa>] skb_gso_segment+0x103/0x23a
[ 2172.558393]  [<ffffffff813a3b8d>] dev_hard_start_xmit+0x1ac/0x26d
[ 2172.558396]  [<ffffffff813b5759>] __qdisc_run+0xe7/0x1ea
[ 2172.558398]  [<ffffffff81030158>] ? check_preempt_wakeup+0x13d/0x18e
[ 2172.558400]  [<ffffffff813a40b0>] dev_queue_xmit+0x350/0x44d
[ 2172.558402]  [<ffffffff81031850>] ? enqueue_task_fair+0x25/0x92
[ 2172.558405]  [<ffffffff8144fe98>] br_dev_queue_push_xmit+0x5c/0x62
[ 2172.558407]  [<ffffffff81035264>] ? default_wake_function+0xd/0xf
[ 2172.558409]  [<ffffffff8144feed>] br_forward_finish+0x4f/0x53
[ 2172.558411]  [<ffffffff8144ff5b>] __br_forward+0x6a/0x6e
[ 2172.558413]  [<ffffffff8144ffa8>] br_forward+0x49/0x57
[ 2172.558415]  [<ffffffff81450a97>] br_handle_frame_finish+0x12b/0x14f
[ 2172.558418]  [<ffffffff81450c73>] br_handle_frame+0x1b8/0x1d5
[ 2172.558420]  [<ffffffff813a3195>] netif_receive_skb+0x2ea/0x3bb
[ 2172.558422]  [<ffffffff813a3682>] napi_gro_receive+0x47/0x57
[ 2172.558424]  [<ffffffff8101bd8f>] ? lapic_next_event+0x15/0x19
[ 2172.558426]  [<ffffffff813a370f>] process_backlog+0x7d/0xb2
[ 2172.558427]  [<ffffffff813a17e9>] net_rx_action+0xa7/0x17a
[ 2172.558430]  [<ffffffff8103fcc3>] __do_softirq+0x83/0x144
[ 2172.558432]  [<ffffffff8100d33c>] call_softirq+0x1c/0x28
[ 2172.558433]  <EOI>  [<ffffffff8100e258>] do_softirq+0x34/0x76
[ 2172.558436]  [<ffffffff813a3765>] netif_rx_ni+0x21/0x28
[ 2172.558438]  [<ffffffff8129060d>] tun_chr_aio_write+0x3f6/0x44d
[ 2172.558440]  [<ffffffff810a0000>] ? sys_swapon+0x2bb/0xa58
[ 2172.558442]  [<ffffffff81290217>] ? tun_chr_aio_write+0x0/0x44d
[ 2172.558444]  [<ffffffff810b0153>] do_sync_readv_writev+0xe3/0x12b
[ 2172.558447]  [<ffffffff8104db04>] ? autoremove_wake_function+0x0/0x38
[ 2172.558449]  [<ffffffff8116e3ba>] ? selinux_file_permission+0xbd/0xc6
[ 2172.558451]  [<ffffffff811673b0>] ? security_file_permission+0x11/0x13
[ 2172.558454]  [<ffffffff810b089d>] do_readv_writev+0xba/0x121
[ 2172.558457]  [<ffffffff810bc2fc>] ? do_vfs_ioctl+0x462/0x4a2
[ 2172.558459]  [<ffffffff810b0942>] vfs_writev+0x3e/0x49
[ 2172.558461]  [<ffffffff810b0994>] sys_writev+0x47/0x94
[ 2172.558463]  [<ffffffff8100c25b>] system_call_fastpath+0x16/0x1b
[ 2172.558464] ---[ end trace bbdce316762c5c8b ]---
[ 2172.559059] ------------[ cut here ]------------
