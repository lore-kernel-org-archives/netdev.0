From: Dave Jones <davej@codemonkey.org.uk>
Subject: mac80211:ieee80211_associate oops.
Date: Sat, 17 May 2008 19:31:05 -0400
Message-ID: <20080517233105.GC31440@codemonkey.org.uk>
References: <bug-447105-263030@bugzilla.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:46725 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbYEQXaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 19:30:22 -0400
Received: from davej by testure.choralone.org with local (Exim 4.69)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1JxVrl-000318-Qn
	for netdev@vger.kernel.org; Sun, 18 May 2008 00:31:05 +0100
Content-Disposition: inline
In-Reply-To: <bug-447105-263030@bugzilla.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just received this report:
 
 > https://bugzilla.redhat.com/show_bug.cgi?id=447105
 > 
 > Description of problem:
 > Get this from kernel-2.6.26-0.13.rc2.git5.fc10.i686, trying to associate with WLAN.
 > 
 > May 17 15:49:40 localhost NetworkManager: <info>  (wlan0): supplicant connection
 > state change: 0 -> 2
 > May 17 15:49:44 localhost NetworkManager: <info>  (wlan0): supplicant connection
 > state change: 2 -> 3
 > May 17 15:49:44 localhost kernel: BUG: unable to handle kernel NULL pointer
 > dereference at 0000009c
 > May 17 15:49:44 localhost kernel: IP: [<f8de32bb>]
 > :mac80211:ieee80211_associate+0x289/0x524
 > May 17 15:49:44 localhost kernel: *pde = 7e8f2067 
 > May 17 15:49:44 localhost kernel: Oops: 0000 [#1] SMP 
 > May 17 15:49:44 localhost kernel: Modules linked in: ext4dev jbd2 crc16 i915 drm
 > ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi
 > scsi_transport_iscsi coretemp nf_conntrack_ipv4 ipt_REJECT iptable_filter
 > ip_tables nf_conntrack_netbios_ns nf_conntrack_ipv6 xt_state nf_conntrack
 > xt_tcpudp ip6t_ipv6header ip6t_REJECT ip6table_filter ip6_tables x_tables ipv6
 > cpufreq_ondemand acpi_cpufreq fuse loop kvm_intel kvm sr_mod cdrom ppdev
 > snd_hda_intel ata_piix thinkpad_acpi snd_seq_dummy ata_generic nsc_ircc
 > snd_seq_oss arc4 hwmon parport_pc irda crc_ccitt iTCO_wdt parport i2c_i801
 > snd_seq_midi_event ecb iTCO_vendor_support crypto_blkcipher sg snd_seq
 > firewire_ohci i2c_core sdhci firewire_core mmc_core pata_acpi snd_seq_device
 > snd_pcm_oss snd_mixer_oss crc_itu_t ac snd_pcm video snd_timer battery bay
 > output snd_page_alloc snd_hwdep iwl3945 hci_usb snd mac80211 button bluetooth
 > e1000e cfg80211 soundcore usb_storage dm_snapshot dm_zero dm_mirror dm_log
 > dm_mod ahci libata sd_mod scsi_mod ext3 jbd mbcach
 > May 17 15:49:44 localhost kernel: e uhci_hcd ohci_hcd ehci_hcd [last unloaded:
 > scsi_wait_scan]
 > May 17 15:49:44 localhost kernel: 
 > May 17 15:49:44 localhost kernel: Pid: 977, comm: iwl3945 Not tainted
 > (2.6.26-0.13.rc2.git5.fc10.i686 #1)
 > May 17 15:49:44 localhost kernel: EIP: 0060:[<f8de32bb>] EFLAGS: 00010246 CPU: 1
 > May 17 15:49:44 localhost kernel: EIP is at ieee80211_associate+0x289/0x524
 > [mac80211]
 > May 17 15:49:44 localhost kernel: EAX: 0000000a EBX: ebfc9500 ECX: 00000000 EDX:
 > ebfc9522
 > May 17 15:49:44 localhost kernel: ESI: 00000000 EDI: 00000000 EBP: f57a1e08 ESP:
 > f57a1da4
 > May 17 15:49:44 localhost kernel:  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 > May 17 15:49:44 localhost kernel: Process iwl3945 (pid: 977, ti=f57a1000
 > task=f6c217e0 task.ti=f57a1000)
 > May 17 15:49:44 localhost kernel: Stack: 00000052 00000246 00000001 f7b7e898
 > 00000018 f7b7e848 f7b7e120 f57a1dd0 
 > May 17 15:49:44 localhost kernel:        c0505058 f57a1de4 f57a1f4f f50896a4
 > 00000000 00000000 ebfc9522 f4a41c00 
 > May 17 15:49:44 localhost kernel:        f7b7e8a4 303a3030 37393a64 3a34303a
 > 623a6330 f57a0065 00000002 00000000 
 > May 17 15:49:44 localhost kernel: Call Trace:
 > May 17 15:49:44 localhost kernel:  [mac80211:scnprintf+24/38] ? scnprintf+0x18/0x26
 > May 17 15:49:44 localhost kernel:  [<f8de4d01>] ?
 > ieee80211_sta_work+0x645/0x1714 [mac80211]
 > May 17 15:49:44 localhost kernel:  [native_sched_clock+181/209] ?
 > native_sched_clock+0xb5/0xd1
 > May 17 15:49:44 localhost kernel:  [native_sched_clock+181/209] ?
 > native_sched_clock+0xb5/0xd1
 > May 17 15:49:44 localhost kernel:  [native_sched_clock+181/209] ?
 > native_sched_clock+0xb5/0xd1
 > May 17 15:49:44 localhost kernel:  [sched_clock+8/11] ? sched_clock+0x8/0xb
 > May 17 15:49:44 localhost kernel:  [run_workqueue+211/417] ?
 > run_workqueue+0xd3/0x1a1
 > May 17 15:49:44 localhost kernel:  [run_workqueue+145/417] ?
 > run_workqueue+0x91/0x1a1
 > May 17 15:49:44 localhost kernel:  [<f8de46bc>] ? ieee80211_sta_work+0x0/0x1714
 > [mac80211]
 > May 17 15:49:44 localhost kernel:  [worker_thread+182/194] ? worker_thread+0xb6/0xc2
 > May 17 15:49:44 localhost kernel:  [<c043be5b>] ? autoremove_wake_function+0x0/0x33
 > May 17 15:49:44 localhost kernel:  [worker_thread+0/194] ? worker_thread+0x0/0xc2
 > May 17 15:49:44 localhost kernel:  [kthread+59/97] ? kthread+0x3b/0x61
 > May 17 15:49:44 localhost kernel:  [kthread+0/97] ? kthread+0x0/0x61
 > May 17 15:49:44 localhost kernel:  [kernel_thread_helper+7/16] ?
 > kernel_thread_helper+0x7/0x10
 > May 17 15:49:44 localhost kernel:  =======================
 > May 17 15:49:44 localhost kernel: Code: 8b 55 d4 88 42 01 8b 87 80 00 00 00 89
 > d7 83 c7 02 8b 75 dc 89 c1 c1 e9 02 f3 a5 89 c1 83 e1 03 74 02 f3 a4 8b 4d d0 31
 > ff 31 f6 <8b> 89 9c 00 00 00 c7 45 c0 00 00 00 00 c7 45 c4 00 00 00 00 89 
 > May 17 15:49:44 localhost NetworkManager: <info>  (wlan0): supplicant connection
 > state change: 3 -> 0
 > May 17 15:49:44 localhost kernel: EIP: [<f8de32bb>]
 > ieee80211_associate+0x289/0x524 [mac80211] SS:ESP 0068:f57a1da4
 > May 17 15:49:44 localhost kernel: ---[ end trace 07aac334cae0913a ]---
 > May 17 15:49:59 localhost NetworkManager: <info>  (wlan0): supplicant connection
 > state change: 0 -> 2
 > 
 > 
 > Version-Release number of selected component (if applicable):
 > kernel-2.6.26-0.13.rc2.git5.fc10.i686
 > 
 > How reproducible:
 > Don't know
 > 
 > Steps to Reproduce:
 > 1.
 > 2.
 > 3.
 >   
 > Actual results:
 > 
 > 
 > Expected results:
 > 
 > 
 > Additional info:
 > 
 > -- 
 > Configure bugmail: https://bugzilla.redhat.com/userprefs.cgi?tab=email
 > ------- You are receiving this mail because: -------
 > You are the assignee for the bug, or are watching the assignee.
---end quoted text---

-- 
http://www.codemonkey.org.uk
