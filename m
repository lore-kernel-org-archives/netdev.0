From: Dave Jones <davej@redhat.com>
Subject: (3.2.9) WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x21d0/0x2260()
Date: Mon, 12 Mar 2012 14:47:33 -0400
Message-ID: <20120312184733.GB1946@redhat.com>
References: <bug-801599-176318@bugzilla.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627Ab2CLSrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 14:47:36 -0400
Content-Disposition: inline
In-Reply-To: <bug-801599-176318@bugzilla.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a report of this WARN being hit since we pushed out 3.2.9 as an update.

	 WARN_ON((int)tp->sacked_out < 0);

	Dave

 > backtrace:
 > :WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x21d0/0x2260()
 > :Hardware name: HP Compaq 8000 Elite SFF PC
 > :Modules linked in: vfat fat usb_storage tcp_lp fuse ebtable_nat ebtables
 > ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge stp llc
 > be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3
 > lockd mdio ib_iser rdma_cm nf_conntrack_ipv4 nf_defrag_ipv4 ib_cm
 > nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ftp iw_cm
 > ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ib_sa ib_mad ib_core xt_state
 > ib_addr ip6table_filter nf_conntrack iscsi_tcp libiscsi_tcp libiscsi ip6_tables
 > scsi_transport_iscsi snd_usb_audio snd_usbmidi_lib snd_rawmidi gspca_sn9c20x
 > gspca_main videodev media v4l2_compat_ioctl32 joydev tpm_infineon
 > snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq
 > snd_seq_device vhost_net macvtap macvlan snd_pcm tun snd_timer virtio_net snd
 > hp_wmi tpm_tis e1000e iTCO_wdt kvm_intel tpm tpm_bios kvm iTCO_vendor_support
 > soundcore snd_page_alloc microcode sparse_keymap rfkill serio_raw binfmt_misc
 > sunrpc uinput btrfs 
 > :pata_acpi zlib_deflate libcrc32c wmi ata_generic i915 drm_kms_helper drm
 > i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
 > :Pid: 0, comm: swapper/0 Tainted: G        W    3.2.9-1.fc16.x86_64 #1
 > :Call Trace:
 > : <IRQ>  [<ffffffff8106e53f>] warn_slowpath_common+0x7f/0xc0
 > : [<ffffffff8106e59a>] warn_slowpath_null+0x1a/0x20
 > : [<ffffffff81522680>] tcp_ack+0x21d0/0x2260
 > : [<ffffffff8151e3f5>] ? tcp_validate_incoming+0x255/0x370
 > : [<ffffffff815234ea>] tcp_rcv_established+0x1ca/0x8b0
 > : [<ffffffff8152b6bf>] tcp_v4_do_rcv+0x27f/0x430
 > : [<ffffffff8152d490>] tcp_v4_rcv+0x610/0x8e0
 > : [<ffffffff81509310>] ? ip_rcv_finish+0x380/0x380
 > : [<ffffffff81509310>] ? ip_rcv_finish+0x380/0x380
 > : [<ffffffff815093ed>] ip_local_deliver_finish+0xdd/0x280
 > : [<ffffffff81509758>] ip_local_deliver+0x88/0x90
 > : [<ffffffff815090c1>] ip_rcv_finish+0x131/0x380
 > : [<ffffffff81509995>] ip_rcv+0x235/0x300
 > : [<ffffffff81074252>] ? ns_to_timeval+0x12/0x40
 > : [<ffffffff814d3463>] __netif_receive_skb+0x523/0x5c0
 > : [<ffffffff814d4060>] netif_receive_skb+0x80/0x90
 > : [<ffffffff814d4429>] ? dev_gro_receive+0x1b9/0x2c0
 > : [<ffffffff814d4170>] napi_skb_finish+0x50/0x70
 > : [<ffffffff814d4775>] napi_gro_receive+0xf5/0x140
 > : [<ffffffffa02d8fcb>] e1000_receive_skb+0x5b/0x70 [e1000e]
 > : [<ffffffffa02dab51>] e1000_clean_rx_irq+0x2f1/0x400 [e1000e]
 > : [<ffffffffa02da278>] e1000_clean+0x78/0x2c0 [e1000e]
 > : [<ffffffff81093fa9>] ? enqueue_hrtimer+0x39/0xc0
 > : [<ffffffff814d49bb>] net_rx_action+0x12b/0x270
 > : [<ffffffff81075b68>] __do_softirq+0xb8/0x230
 > : [<ffffffff8109aa96>] ? do_timer+0x2d6/0x500
 > : [<ffffffff815ecd2c>] call_softirq+0x1c/0x30
 > : [<ffffffff810162f5>] do_softirq+0x65/0xa0
 > : [<ffffffff81075f7e>] irq_exit+0x9e/0xc0
 > : [<ffffffff815ed5e3>] do_IRQ+0x63/0xe0
 > : [<ffffffff815e2f2e>] common_interrupt+0x6e/0x6e
 > : <EOI>  [<ffffffff81338e8b>] ? arch_local_irq_enable+0x8/0xd
 > : [<ffffffff81096e7a>] ? sched_clock_idle_wakeup_event+0x1a/0x20
 > : [<ffffffff81339abb>] acpi_idle_enter_bm+0x225/0x269
 > : [<ffffffff81493671>] cpuidle_idle_call+0xc1/0x280
 > : [<ffffffff8101322a>] cpu_idle+0xca/0x120
 > : [<ffffffff815bffce>] rest_init+0x72/0x74
 > : [<ffffffff81aebbfe>] start_kernel+0x3ba/0x3c5
 > : [<ffffffff81aeb347>] x86_64_start_reservations+0x132/0x136
 > : [<ffffffff81aeb140>] ? early_idt_handlers+0x140/0x140
 > : [<ffffffff81aeb44d>] x86_64_start_kernel+0x102/0x111
