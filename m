From: Ferenc Wagner <wferi@niif.hu>
Subject: two warns on slowpath
Date: Thu, 06 Nov 2008 18:40:47 +0100
Message-ID: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:36668 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbYKFRku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 12:40:50 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.63)
	(envelope-from <wferi@niif.hu>)
	id 1Ky8qd-0000rL-Fp
	for netdev@vger.kernel.org; Thu, 06 Nov 2008 18:40:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=

Hi,

Since loading netconsole a couple of days ago on the two machines of a
heartbeat cluster hosting Xen virtual machines, I got the attached
warn_on_slowpath messages, one on each.  It never happened before, so
I thought I could as well report them in case it's interesting for
you.  The netconsole module parameter is like

netconsole=@10.253.2.8/eth-gb1,6666@10.253.2.1/00:09:6b:8c:88:6b

with different port numbers on the two hosts.  The eth-gb[12] physical
interfaces are bonded, but I couldn't run netconsole on bond0, as it
has no netpoll support.  The source IP is on bond0.  There are also
several 802.1q subinterfaces over bond0, which are bridge ports.

The kernel is basically 2.6.26.6 with the SuSE Xen patch for dom0
support (the Debian Lenny kernel).
---8<---

--=-=-=
Content-Disposition: inline; filename=slow1b.txt

Firewall heartbeat: IN=lo OUT= MAC=00:00:00:00:00:00:00:00:<4>------------[ cut here ]------------
WARNING: at kernel/softirq.c:141 local_bh_enable+0x2e/0x78()
Modules linked in: pl2303 usbserial xt_physdev netconsole configfs video output ac battery bridge 8021q bonding ip6t_REJECT ip6t_LOG nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 ipt_recent ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack xt_tcpudp ipt_LOG xt_limit xt_multiport iptable_filter ip_tables x_tables ext2 mbcache loop dm_round_robin dm_emc dm_multipath evdev psmouse serio_raw shpchp pci_hotplug pcspkr button i2c_piix4 i2c_core sworks_agp agpgart dcdbas xfs dm_mirror dm_log dm_snapshot dm_mod raid1 md_mod sg ide_cd_mod cdrom sd_mod ata_generic libata dock aic7xxx scsi_transport_spi ohci_hcd tg3 serverworks floppy usbcore qla2xxx firmware_class scsi_transport_fc scsi_tgt ide_pci_generic ide_core scsi_mod thermal processor fan thermal_sys
Pid: 22191, comm: heartbeat Not tainted 2.6.26-1-xen-686 #1
 [<c011e631>] warn_on_slowpath+0x40/0x64
 [<c01e5b44>] _swiotlb_map_single+0xab/0x18b
 [<d1127932>] tg3_start_xmit_dma_bug+0x3a7/0x7d3 [tg3]
 [<d1127c97>] tg3_start_xmit_dma_bug+0x70c/0x7d3 [tg3]
 [<c0169551>] dma_pool_alloc+0x191/0x19b
 [<d10d861f>] ohci_urb_enqueue+0x4eb/0x6c2 [ohci_hcd]
 [<c0122eda>] local_bh_enable+0x2e/0x78
 [<d19e7753>] __nf_conntrack_find+0xd5/0xdc [nf_conntrack]
 [<d19e7761>] nf_conntrack_find_get+0x7/0x3d [nf_conntrack]
 [<d19e821c>] nf_conntrack_in+0x14c/0x404 [nf_conntrack]
 [<c01162a7>] enqueue_task_fair+0x16/0x24
 [<c0114f8e>] enqueue_task+0x52/0x5d
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<d1a946fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<d1a946fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<d1a952d6>] br_nf_pre_routing+0x51c/0x542 [bridge]
 [<d1a946fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<d1a91436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<d1a91436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<d1a9169f>] br_handle_frame+0x165/0x186 [bridge]
 [<d1a91436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<c0269ae9>] netif_receive_skb+0x2a5/0x391
 [<d112bf23>] tg3_poll+0x696/0x9bc [tg3]
 [<c01e55fc>] swiotlb_unmap_single+0x0/0x13
 [<c0274a2b>] netpoll_poll+0x74/0x348
 [<c0274df7>] netpoll_send_skb+0xf8/0x1b6
 [<d1a120b2>] write_msg+0x6d/0xa9 [netconsole]
 [<d1a12045>] write_msg+0x0/0xa9 [netconsole]
 [<c011e6aa>] __call_console_drivers+0x4f/0x5b
 [<c011eabb>] release_console_sem+0x15e/0x1e5
 [<c011ef89>] vprintk+0x2bb/0x317
 [<c011efaf>] vprintk+0x2e1/0x317
 [<c01dce4e>] __next_cpu+0x12/0x21
 [<c011eff9>] printk+0x14/0x18
 [<d180f8a6>] ipt_log_packet+0xf1/0x135 [ipt_LOG]
 [<d180f921>] log_tg+0x37/0x42 [ipt_LOG]
 [<d19b4001>] user2credits+0x1/0x2e [xt_limit]
 [<d19b0004>] ipt_local_out_hook+0x4/0x5c [iptable_filter]
 [<d180f8ea>] log_tg+0x0/0x42 [ipt_LOG]
 [<d19b7439>] ipt_do_table+0x38f/0x422 [ip_tables]
 [<c0126789>] lock_timer_base+0x19/0x35
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<c0284a93>] ip_local_deliver_finish+0x0/0x183
 [<c0284f3b>] ip_local_deliver+0x4d/0x66
 [<c0284a93>] ip_local_deliver_finish+0x0/0x183
 [<c0284a76>] ip_rcv_finish+0x286/0x2a3
 [<c0269b68>] netif_receive_skb+0x324/0x391
 [<c026c030>] process_backlog+0xe4/0x10a
 [<c026b9cd>] net_rx_action+0xb9/0x1cf
 [<c0122bf8>] __do_softirq+0x79/0xf4
 [<c0122cc4>] do_softirq+0x51/0x76
 [<c0122f19>] local_bh_enable+0x6d/0x78
 [<c026c72c>] dev_queue_xmit+0x3a2/0x3da
 [<c0287fb5>] ip_finish_output+0x1c5/0x1fc
 [<c0287b43>] ip_local_out+0x15/0x17
 [<c0287d96>] ip_push_pending_frames+0x251/0x2ab
 [<c029f210>] udp_push_pending_frames+0x2b0/0x315
 [<c02a021f>] udp_sendmsg+0x436/0x519
 [<c02a5071>] inet_sendmsg+0x35/0x3f
 [<c02609aa>] sock_sendmsg+0xc7/0xe1
 [<c012ec48>] autoremove_wake_function+0x0/0x2d
 [<c0263e8e>] sock_wfree+0x1f/0x35
 [<c01e55fc>] swiotlb_unmap_single+0x0/0x13
 [<c0261285>] sys_sendto+0xfc/0x127
 [<c0122cc4>] do_softirq+0x51/0x76
 [<c01e55fc>] swiotlb_unmap_single+0x0/0x13
 [<c01dfccc>] rb_insert_color+0x4c/0xad
 [<c01310aa>] enqueue_hrtimer+0x5a/0x62
 [<c0131548>] hrtimer_start+0x111/0x11d
 [<c0261b70>] sys_socketcall+0x106/0x19e
 [<c0103f76>] syscall_call+0x7/0xb
 =======================
---[ end trace 6aa9bbc52691d91c ]---

--=-=-=

---8<---

--=-=-=
Content-Disposition: inline; filename=slow2b.txt

Firewall heartbeat: IN=lo OUT= MAC=00:00:00:00:00:00:00:00:00:00:00:00:08:00 SRC=10.253.2.8 DST=10.253.2.8 LEN=238 TOS=0x10 PREC=0x00 TTL=64 ID=0 DF <4>------------[ cut here ]------------
WARNING: at kernel/softirq.c:141 local_bh_enable+0x2e/0x78()
Modules linked in: xt_physdev netconsole configfs video output ac battery bridge 8021q bonding ip6t_REJECT ip6t_LOG nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 ipt_recent ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack xt_tcpudp ipt_LOG xt_limit xt_multiport iptable_filter ip_tables x_tables ext2 mbcache dm_round_robin dm_emc dm_multipath loop evdev psmouse serio_raw shpchp pci_hotplug pcspkr button i2c_piix4 i2c_core sworks_agp agpgart dcdbas xfs dm_mirror dm_log dm_snapshot dm_mod raid1 md_mod sg ide_cd_mod cdrom sd_mod ata_generic libata dock aic7xxx scsi_transport_spi floppy qla2xxx firmware_class scsi_transport_fc scsi_tgt scsi_mod ohci_hcd tg3 serverworks ide_pci_generic ide_core usbcore thermal processor fan thermal_sys
Pid: 4871, comm: heartbeat Not tainted 2.6.26-1-xen-686 #1
 [<c011e631>] warn_on_slowpath+0x40/0x64
 [<d10c9932>] tg3_start_xmit_dma_bug+0x3a7/0x7d3 [tg3]
 [<d10c9c97>] tg3_start_xmit_dma_bug+0x70c/0x7d3 [tg3]
 [<d154986e>] __nf_ct_refresh_acct+0xd7/0x112 [nf_conntrack]
 [<d154cd15>] tcp_packet+0x911/0x97c [nf_conntrack]
 [<c01e5b44>] _swiotlb_map_single+0xab/0x18b
 [<c0122eda>] local_bh_enable+0x2e/0x78
 [<d1549753>] __nf_conntrack_find+0xd5/0xdc [nf_conntrack]
 [<d1549761>] nf_conntrack_find_get+0x7/0x3d [nf_conntrack]
 [<d154a21c>] nf_conntrack_in+0x14c/0x404 [nf_conntrack]
 [<d159067f>] bond_xmit_activebackup+0x43/0x5b [bonding]
 [<c026a287>] dev_hard_start_xmit+0x1eb/0x24f
 [<c026c72c>] dev_queue_xmit+0x3a2/0x3da
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<d15f66fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<d15f66fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<d15f72d6>] br_nf_pre_routing+0x51c/0x542 [bridge]
 [<d15f66fc>] br_nf_pre_routing_finish+0x0/0x239 [bridge]
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<d15f3436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<d15f3436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<d15f369f>] br_handle_frame+0x165/0x186 [bridge]
 [<d15f3436>] br_handle_frame_finish+0x0/0x104 [bridge]
 [<c0269ae9>] netif_receive_skb+0x2a5/0x391
 [<d10cdf23>] tg3_poll+0x696/0x9bc [tg3]
 [<c01e55fc>] swiotlb_unmap_single+0x0/0x13
 [<c0274a2b>] netpoll_poll+0x74/0x348
 [<c0274df7>] netpoll_send_skb+0xf8/0x1b6
 [<d15740b2>] write_msg+0x6d/0xa9 [netconsole]
 [<d1574045>] write_msg+0x0/0xa9 [netconsole]
 [<c011e6aa>] __call_console_drivers+0x4f/0x5b
 [<c011eabb>] release_console_sem+0x15e/0x1e5
 [<c011ef89>] vprintk+0x2bb/0x317
 [<c0131f11>] atomic_notifier_call_chain+0x9/0xc
 [<c022cbdb>] notify_update+0x1f/0x22
 [<c011eff9>] printk+0x14/0x18
 [<c011eff9>] printk+0x14/0x18
 [<d1371115>] dump_packet+0x100/0x7a0 [ipt_LOG]
 [<c011ef89>] vprintk+0x2bb/0x317
 [<c01061e9>] sched_clock+0x15/0x47
 [<c011eff9>] printk+0x14/0x18
 [<d13718d0>] ipt_log_packet+0x11b/0x135 [ipt_LOG]
 [<d1371921>] log_tg+0x37/0x42 [ipt_LOG]
 [<d1516001>] user2credits+0x1/0x2e [xt_limit]
 [<d13718ea>] log_tg+0x0/0x42 [ipt_LOG]
 [<d1519439>] ipt_do_table+0x38f/0x422 [ip_tables]
 [<c0126789>] lock_timer_base+0x19/0x35
 [<c027fb6c>] nf_iterate+0x30/0x61
 [<c027fbfb>] nf_hook_slow+0x3a/0x90
 [<c0284a93>] ip_local_deliver_finish+0x0/0x183
 [<c0284f3b>] ip_local_deliver+0x4d/0x66
 [<c0284a93>] ip_local_deliver_finish+0x0/0x183
 [<c0284a76>] ip_rcv_finish+0x286/0x2a3
 [<c0269b68>] netif_receive_skb+0x324/0x391
 [<c026c030>] process_backlog+0xe4/0x10a
 [<c026b9cd>] net_rx_action+0xb9/0x1cf
 [<c0122bf8>] __do_softirq+0x79/0xf4
 [<c0122cc4>] do_softirq+0x51/0x76
 [<c0122f19>] local_bh_enable+0x6d/0x78
 [<c026c72c>] dev_queue_xmit+0x3a2/0x3da
 [<c0287fb5>] ip_finish_output+0x1c5/0x1fc
 [<c0287b43>] ip_local_out+0x15/0x17
 [<c0287d96>] ip_push_pending_frames+0x251/0x2ab
 [<c029f210>] udp_push_pending_frames+0x2b0/0x315
 [<c02a021f>] udp_sendmsg+0x436/0x519
 [<c02a5071>] inet_sendmsg+0x35/0x3f
 [<c02609aa>] sock_sendmsg+0xc7/0xe1
 [<c012ec48>] autoremove_wake_function+0x0/0x2d
 [<c0263cc1>] sock_def_write_space+0xf/0x6c
 [<c0234388>] transmit_chars+0x5f/0xc5
 [<c0105f7c>] get_nsec_offset+0xe/0x6a
 [<c0261285>] sys_sendto+0xfc/0x127
 [<c01dfccc>] rb_insert_color+0x4c/0xad
 [<c01310aa>] enqueue_hrtimer+0x5a/0x62
 [<c0131548>] hrtimer_start+0x111/0x11d
 [<c0261b70>] sys_socketcall+0x106/0x19e
 [<c0103f76>] syscall_call+0x7/0xb
 =======================
---[ end trace 63fab894a4128708 ]---

--=-=-=

---8<---
-- 
Regards,
Feri.

--=-=-=--
