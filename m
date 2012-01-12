From: Bart Van Assche <bvanassche@acm.org>
Subject: NULL pointer dereference in net_rx_action
Date: Thu, 12 Jan 2012 19:05:50 +0000
Message-ID: <CAO+b5-q3DVHQTG1ZKB_tfqjrdokgOdZA4G5QrJ7LFQPhOMHu6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47427 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593Ab2ALTFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 14:05:53 -0500
Received: by werm1 with SMTP id m1so1609302wer.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 11:05:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

If I send enough data via netconsole and an Ethernet interface to a
remote system, sooner or later a NULL pointer dereference is triggered
in net_rx_action(). I can reproduce this with both 3.1.8 and 3.2.0. Is
this a known issue ?

# ethtool -i eth0
driver: skge
version: 1.14
firmware-version: N/A
bus-info: 0000:06:02.0

Thanks,

Bart.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000525
IP: [<ffffffff8130c95e>] net_rx_action+0x9e/0x290
PGD 19e4d0067 PUD 19895b067 PMD 0
Oops: 0000 [#1] SMP
CPU 0
Modules linked in: ib_srp scsi_transport_srp scsi_tgt netconsole
configfs snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device af_packet
rdma_ucm rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_sa ib_uverbs ib_umad
mlx4_ib ib_mad ib_core microcode cpufreq_conservative
cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf dm_mod
snd_hda_codec_hdmi snd_hda_codec_analog snd_hda_intel snd_hda_codec
snd_hwdep snd_pcm snd_timer intel_agp snd sr_mod mlx4_core intel_gtt
i2c_i801 sg cdrom agpgart i2c_core soundcore pcspkr snd_page_alloc
button uhci_hcd ehci_hcd sd_mod crc_t10dif usbcore edd ext3 mbcache
jbd fan ata_generic ata_piix pata_marvell ahci libahci libata scsi_mod
thermal processor thermal_sys hwmon

Pid: 3, comm: ksoftirqd/0 Not tainted 3.1.8-debug+ #1 System
manufacturer P5Q DELUXE/P5Q DELUXE
RIP: 0010:[<ffffffff8130c95e>]  [<ffffffff8130c95e>] net_rx_action+0x9e/0x290
RSP: 0018:ffff8801b50b7d60  EFLAGS: 00010246
RAX: 00000000000000d5 RBX: ffff8801bfc12750 RCX: 0000000000000000
RDX: 0000000000000046 RSI: 0000000000000000 RDI: ffff8801b50a9ec0
RBP: ffff8801b50b7dc0 R08: 0d28000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 000000000000012c R14: ffff8801bfc12740 R15: ffff8801bfc12750
FS:  0000000000000000(0000) GS:ffff8801bfc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000525 CR3: 0000000198978000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksoftirqd/0 (pid: 3, threadinfo ffff8801b50b6000, task ffff8801b50a9ec0)
Stack:
 ffff88019fbc42d0 ffffffff8104cfb1 ffff8801b50b7fd8 ffff8801b50b7fd8
 00000000ffffe238 ffff8801b50b7fd8 ffff8801b50b7db0 ffffffff81605098
 0000000000000003 0000000000000041 0000000000000101 ffff8801b50b7fd8
Call Trace:
 [<ffffffff8104cfb1>] ? __do_softirq+0x81/0x250
 [<ffffffff8104cffd>] __do_softirq+0xcd/0x250
 [<ffffffff8104d297>] run_ksoftirqd+0x117/0x1e0
 [<ffffffff8104d180>] ? __do_softirq+0x250/0x250
 [<ffffffff81069786>] kthread+0x96/0xa0
 [<ffffffff813e8534>] kernel_thread_helper+0x4/0x10
 [<ffffffff813de75d>] ? retint_restore_args+0xe/0xe
 [<ffffffff810696f0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff813e8530>] ? gs_change+0xb/0xb
Code: 48 8b 05 c6 16 39 00 48 39 45 c0 0f 88 24 01 00 00 e8 07 67 d7
ff fb 49 8b 5e 10 48 8b 43 68 48 85 c0 0f 84 05 01 00 00 45 31 e4
 83 b8 50 04 00 00 00 74 17 48 8d 7b 28 49 89 dc e8 5c 10 0d
RIP  [<ffffffff8130c95e>] net_rx_action+0x9e/0x290
 RSP <ffff8801b50b7d60>
CR2: 0000000000000525
---[ end trace 455fc5fc77d19f4a ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 3, comm: ksoftirqd/0 Tainted: G      D     3.1.8-debug+ #1
Call Trace:
 [<ffffffff813da43c>] panic+0xa0/0x1bd
 [<ffffffff813df692>] oops_end+0xe2/0xf0
 [<ffffffff810288eb>] no_context+0xfb/0x260
 [<ffffffff813ddab7>] ? _raw_spin_lock_irq+0x17/0x60
 [<ffffffff81028b85>] __bad_area_nosemaphore+0x135/0x220
 [<ffffffff81028c83>] bad_area_nosemaphore+0x13/0x20
 [<ffffffff813e1e86>] do_page_fault+0x3e6/0x520
 [<ffffffff811d436b>] ? blk_run_queue+0x4b/0x60
 [<ffffffff813deb23>] ? error_sti+0x5/0x6
 [<ffffffff811f300d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff813de93f>] page_fault+0x1f/0x30
 [<ffffffff8130c95e>] ? net_rx_action+0x9e/0x290
 [<ffffffff8104cfb1>] ? __do_softirq+0x81/0x250
 [<ffffffff8104cffd>] __do_softirq+0xcd/0x250
 [<ffffffff8104d297>] run_ksoftirqd+0x117/0x1e0
 [<ffffffff8104d180>] ? __do_softirq+0x250/0x250
 [<ffffffff81069786>] kthread+0x96/0xa0
 [<ffffffff813e8534>] kernel_thread_helper+0x4/0x10
 [<ffffffff813de75d>] ? retint_restore_args+0xe/0xe
 [<ffffffff810696f0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff813e8530>] ? gs_change+0xb/0xb
