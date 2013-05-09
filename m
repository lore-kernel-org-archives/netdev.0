From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG] 8139cp broken under KVM with 3.9
Date: Thu, 9 May 2013 09:21:43 -0700
Message-ID: <1902752B0C92F943AB7EA9EE13E2DEEC0DE5764E97@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "'dwmw2@infradead.org'" <dwmw2@infradead.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:57198 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045Ab3EIQrz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 12:47:55 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id r49GKTnA001767
	for <netdev@vger.kernel.org>; Thu, 9 May 2013 09:21:47 -0700
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1c7x1tgexb-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 09 May 2013 09:21:47 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Swapped development environment from 3.6 to 3.9.1 kernel and the emulated 8139 NIC
in KVM gets transmit timeout as soon as brought up.

I suspect BQL and other changes in driver.

[   18.467323] 8139cp 0000:00:03.0 eth0: link up, 100Mbps, full-duplex, lpa 0x05E1
[   25.000072] ------------[ cut here ]------------
[   25.000143] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x243/0x250()
[   25.000146] Hardware name: Bochs
[   25.000149] NETDEV WATCHDOG: eth0 (8139cp): transmit queue 0 timed out
[   25.000150] Modules linked in: 9p 9pnet fscache ipv6 tun mperf cpufreq_userspace cpufreq_stats virtio_uio(O) cpufreq_powersave cpufreq_ondemand freq_table cpufreq_conservative cirrus ttm hid_generic drm_kms_helper drm virtio_balloon serio_raw pcspkr microcode i2c_piix4 i2c_core sysimgblt sysfillrect psmouse syscopyarea evdev intel_agp intel_gtt agpgart processor thermal_sys button vfat fat usb_storage ohci_hcd squashfs loop overlayfs raid10 raid456 async_pq async_xor xor async_memcpy async_raid6_recov raid6_pq async_tx raid1 raid0 multipath linear md_mod igb_uio(O) pata_acpi uio usbhid hid ata_generic virtio_blk floppy e1000 8139cp virtio_pci virtio_ring virtio 8139too mii ata_piix
[   25.000216] Pid: 0, comm: swapper/2 Tainted: G           O 3.9.1-1-amd64-vyatta #1
[   25.000218] Call Trace:
[   25.000220]  <IRQ>  [<ffffffff8105574b>] ? warn_slowpath_common+0x7b/0xc0
[   25.000250]  [<ffffffff81055845>] ? warn_slowpath_fmt+0x45/0x50
[   25.000267]  [<ffffffff814e1275>] ? _raw_spin_lock+0x5/0x10
[   25.000272]  [<ffffffff8143ef73>] ? dev_watchdog+0x243/0x250
[   25.000279]  [<ffffffff81041e2f>] ? kvm_clock_read+0x1f/0x30
[   25.000284]  [<ffffffff8143ed30>] ? __netdev_watchdog_up+0x70/0x70
[   25.000287]  [<ffffffff8143ed30>] ? __netdev_watchdog_up+0x70/0x70
[   25.000295]  [<ffffffff81065723>] ? call_timer_fn+0x43/0x130
[   25.000299]  [<ffffffff81065bd7>] ? run_timer_softirq+0x237/0x280
[   25.000309]  [<ffffffff8107c680>] ? enqueue_hrtimer+0x20/0x80
[   25.000314]  [<ffffffff8105d9f1>] ? __do_softirq+0xe1/0x270
[   25.000318]  [<ffffffff8105dc85>] ? irq_exit+0xb5/0xc0
[   25.000328]  [<ffffffff81039f38>] ? smp_apic_timer_interrupt+0x68/0xa0
[   25.000338]  [<ffffffff814e2c5d>] ? apic_timer_interrupt+0x6d/0x80
[   25.000340]  <EOI>  [<ffffffff81042152>] ? native_safe_halt+0x2/0x10
[   25.000357]  [<ffffffff8101e1ef>] ? default_idle+0x3f/0xf0
[   25.000361]  [<ffffffff8101db48>] ? cpu_idle+0x88/0xd0
[   25.000365]  [<ffffffff814d660a>] ? start_secondary+0x211/0x216
[   25.000368] ---[ end trace b01ffb3f162295a6 ]---
[   25.000502] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    4 80ff
[   37.000160] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   49.000179] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   61.000161] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   73.000172] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   85.000209] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   97.000264] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[  109.000141] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[  121.000146] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[  133.000124] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[  145.000150] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[  157.000193] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
