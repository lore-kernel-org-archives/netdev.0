From: Dave Young <hidave.darkstar@gmail.com>
Subject: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Mon, 21 Jan 2008 15:55:48 +0800
Message-ID: <20080121075548.GA22177@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:55983 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757417AbYAUHzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 02:55:10 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1715714fga.17
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:55:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please see the kernel messages following,(trigged while using some qemu session)
BTW, seems there's some e100 error message as well.

PCI: Setting latency timer of device 0000:00:1b.0 to 64
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
ACPI: PCI Interrupt 0000:03:08.0[A] -> GSI 20 (level, low) -> IRQ 20
modprobe:2331 conflicting cache attribute efaff000-efb00000 uncached<->default
e100: 0000:03:08.0: e100_probe: Cannot map device registers, aborting.
ACPI: PCI interrupt for device 0000:03:08.0 disabled
e100: probe of 0000:03:08.0 failed with error -12
eth0:  setting full-duplex.
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x150()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c03e8df8>] ? ip_finish_output+0x128/0x2e0
 [<c03e9527>] ? ip_output+0xe7/0x100
 [<c03e8a88>] ? ip_local_out+0x18/0x20
 [<c03e991c>] ? ip_queue_xmit+0x3dc/0x470
 [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
 [<c0186be1>] ? check_pad_bytes+0x61/0x80
 [<c03f6031>] tcp_mark_head_lost+0x121/0x150
 [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
 [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2528 tcp_fastretrans_alert+0x675/0x6b0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c03f6ff5>] tcp_fastretrans_alert+0x675/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x150()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0153241>] ? put_lock_stats+0x21/0x30
 [<c01532b0>] ? lock_release_holdtime+0x60/0x80
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c03f6031>] tcp_mark_head_lost+0x121/0x150
 [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
 [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2528 tcp_fastretrans_alert+0x675/0x6b0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0186ae4>] ? check_bytes_and_report+0x24/0xc0
 [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
 [<c0186be1>] ? check_pad_bytes+0x61/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c03f6ff5>] tcp_fastretrans_alert+0x675/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x150()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c0153241>] ? put_lock_stats+0x21/0x30
 [<c01532b0>] ? lock_release_holdtime+0x60/0x80
 [<c0187918>] ? add_partial+0x48/0x90
 [<c03f6031>] tcp_mark_head_lost+0x121/0x150
 [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
 [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2528 tcp_fastretrans_alert+0x675/0x6b0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0186ae4>] ? check_bytes_and_report+0x24/0xc0
 [<c0186be1>] ? check_pad_bytes+0x61/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c03f6ff5>] tcp_fastretrans_alert+0x675/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0151d2c>] ? tick_nohz_stop_sched_tick+0x25c/0x350
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x150()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 2754, comm: X Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c015322d>] ? put_lock_stats+0xd/0x30
 [<c01532b0>] ? lock_release_holdtime+0x60/0x80
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c04363f9>] ? _spin_unlock_irqrestore+0x39/0x70
 [<c013dbb4>] ? group_send_sig_info+0x74/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c03f6031>] tcp_mark_head_lost+0x121/0x150
 [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
 [<c03f5ed1>] ? tcp_time_to_recover+0xe1/0xf0
 [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
 [<c03f7d93>] tcp_ack+0x1b3/0x3a0
 [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
 [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
 [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
 [<c0401967>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b87>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01c8>] ? sock_def_readable+0x48/0xa0
 [<c03be051>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be097>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042f4d0>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8d96>] netif_receive_skb+0x2b6/0x330
 [<c03c8c07>] ? netif_receive_skb+0x127/0x330
 [<c03c8e93>] ? process_backlog+0x83/0x100
 [<c03c8e9e>] process_backlog+0x8e/0x100
 [<c03c90ac>] net_rx_action+0x13c/0x230
 [<c03c8fc9>] ? net_rx_action+0x59/0x230
 [<c0136f2e>] ? __do_softirq+0x6e/0x120
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155649>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 =======================
---[ end trace 97302d8bf57718dd ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:1767 tcp_enter_frto+0x27c/0x2a0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
 [<c0132100>] ? printk+0x0/0x20
 [<c0131834>] warn_on_slowpath+0x54/0x80
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0154972>] ? validate_chain+0x1d2/0x320
 [<c0156234>] ? __lock_acquire+0x1e4/0x730
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c03f58ac>] tcp_enter_frto+0x27c/0x2a0
 [<c03ff3c2>] tcp_retransmit_timer+0x102/0x400
 [<c043611b>] ? _spin_lock+0x4b/0x80
 [<c03ff6d4>] ? tcp_write_timer+0x14/0x110
 [<c03ff7b3>] tcp_write_timer+0xf3/0x110
 [<c013b94b>] run_timer_softirq+0xbb/0x190
 [<c03ff6c0>] ? tcp_write_timer+0x0/0x110
 [<c0136f53>] __do_softirq+0x93/0x120
 [<c013705a>] do_softirq+0x7a/0x80
 [<c0137125>] irq_exit+0x65/0x90
 [<c011a91d>] smp_apic_timer_interrupt+0x2d/0x40
 [<c0105aab>] apic_timer_interrupt+0x33/0x38
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04333bd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =======================
---[ end trace 97302d8bf57718dd ]---
