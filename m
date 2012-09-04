From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 47041]  8139cp transmit queue timeout and panic
Date: Tue, 4 Sep 2012 16:26:26 -0700
Message-ID: <20120904162626.67c2cce7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48497 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab2IDX05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 19:26:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Begin forwarded message:

Date: Tue,  4 Sep 2012 23:19:34 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 47041] New: my laptop HP Pavilion ZT3000 became unusable cause kernel panic


https://bugzilla.kernel.org/show_bug.cgi?id=47041

           Summary: my laptop HP Pavilion ZT3000 became unusable cause
                    kernel panic
           Product: Networking
           Version: 2.5
    Kernel Version: 3.5.3
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: slacky@cheapnet.it
        Regression: Yes


Created an attachment (id=79301)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=79301)
dmesg from kernel 3.5.3 before to panic

I started ArchLinux with the default 3.5.3 kernel and the 8139cp doesn't work
anymore. I got IP assigned, but the network card doesn't work anymore. Till
3.4.x it worked. I've seen a problem in the dmesg I attached.

I rebooted to start with kernel 3.0.42 and the system gone into a wonderful
kernel panic.

I see new kernel release, new kernel panic introduced. Lots of regression. What
happening to the kernel source code?

-- 

---
[  108.360033] ------------[ cut here ]------------
[  108.360060] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1f1/0x200()
[  108.360067] Hardware name: HP Pavilion zt3000 (DX681E#ABZ) 
[  108.360074] NETDEV WATCHDOG: eth0 (8139cp): transmit queue 0 timed out
[  108.360078] Modules linked in: sha256_generic cbc usb_storage uas xt_limit xt_tcpudp xt_length xt_state iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_filter ip_tables x_tables ext4 jbd2 mbcache crc16 radeon snd_intel8x0m snd_intel8x0 firewire_ohci i2c_algo_bit snd_ac97_codec joydev drm_kms_helper ttm ipw2200 libipw firewire_core ac97_bus snd_pcm cfg80211 pcmcia drm 8139too iTCO_wdt 8139cp iTCO_vendor_support snd_page_alloc rfkill lib80211 snd_timer crc_itu_t snd yenta_socket mii pcmcia_rsrc smsc_ircc2 pcmcia_core lpc_ich intel_agp serio_raw psmouse shpchp ppdev soundcore irda crc_ccitt intel_gtt agpgart microcode pci_hotplug i2c_i801 wbsd evdev i2c_core parport_pc mmc_core pcspkr parport battery container video fuse ac button cpufreq_powersave a
 cpi_cpufreq mperf processor reiserfs aes_i586 cryptd aes_generic lrw gf128mul hid_generic usbhid hid dm_crypt dm_mod sd_mod sr_mod cdrom pata_acpi ata_generic ata_piix libata scsi_mod uhci_h
 cd ehci_hcd usbcore usb_common
[  108.360320] Pid: 0, comm: swapper/0 Not tainted 3.5.3-1-ARCH #1
[  108.360324] Call Trace:
[  108.360343]  [<c0136902>] warn_slowpath_common+0x72/0xa0
[  108.360355]  [<c04049e1>] ? dev_watchdog+0x1f1/0x200
[  108.360365]  [<c04049e1>] ? dev_watchdog+0x1f1/0x200
[  108.360376]  [<c01369d3>] warn_slowpath_fmt+0x33/0x40
[  108.360387]  [<c04049e1>] dev_watchdog+0x1f1/0x200
[  108.360402]  [<c04047f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  108.360416]  [<c0145638>] run_timer_softirq+0x108/0x320
[  108.360431]  [<c01b45dc>] ? __rcu_process_callbacks+0x2ac/0x380
[  108.360442]  [<c04047f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  108.360454]  [<c013eaef>] __do_softirq+0x7f/0x1b0
[  108.360465]  [<c013ea70>] ? ftrace_define_fields_irq_handler_entry+0x80/0x80
[  108.360471]  <IRQ>  [<c013eebe>] ? irq_exit+0x7e/0xa0
[  108.360490]  [<c04cc87b>] ? do_IRQ+0x4b/0xc0
[  108.360504]  [<c01091d8>] ? sched_clock+0x8/0x10
[  108.360516]  [<c01691d2>] ? sched_clock_local+0xb2/0x1a0
[  108.360527]  [<c04cc7b0>] ? common_interrupt+0x30/0x38
[  108.360541]  [<c016007b>] ? perf_trace_sched_pi_setprio+0xab/0xe0
[  108.360566]  [<f878fe27>] ? acpi_idle_enter_simple+0x12d/0x16e [processor]
[  108.360589]  [<f878ff39>] ? acpi_idle_enter_bm+0xd1/0x2bd [processor]
[  108.360604]  [<c03c4129>] ? menu_select+0xb9/0x420
[  108.360622]  [<c03c28a5>] ? cpuidle_enter+0x15/0x20
[  108.360633]  [<c03c2e28>] ? cpuidle_idle_call+0x88/0x2d0
[  108.360647]  [<c010aeda>] ? cpu_idle+0xaa/0x100
[  108.360659]  [<c04aa4d4>] ? rest_init+0x6c/0x78
[  108.360669]  [<c06439c1>] ? start_kernel+0x362/0x368
[  108.360680]  [<c0643494>] ? repair_env_string+0x51/0x51
[  108.360691]  [<c06432c2>] ? i386_start_kernel+0x78/0x7d
[  108.360698] ---[ end trace 10638527877ea302 ]---
[  108.360717] 8139cp 0000:02:01.0: eth0: Transmit timeout, status  c   2b    0 80ff
[  108.360793] ------------[ cut here ]------------
[  108.360803] WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x68/0xa0()
[  108.360809] Hardware name: HP Pavilion zt3000 (DX681E#ABZ) 
[  108.360813] Modules linked in: sha256_generic cbc usb_storage uas xt_limit xt_tcpudp xt_length xt_state iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_filter ip_tables x_tables ext4 jbd2 mbcache crc16 radeon snd_intel8x0m snd_intel8x0 firewire_ohci i2c_algo_bit snd_ac97_codec joydev drm_kms_helper ttm ipw2200 libipw firewire_core ac97_bus snd_pcm cfg80211 pcmcia drm 8139too iTCO_wdt 8139cp iTCO_vendor_support snd_page_alloc rfkill lib80211 snd_timer crc_itu_t snd yenta_socket mii pcmcia_rsrc smsc_ircc2 pcmcia_core lpc_ich intel_agp serio_raw psmouse shpchp ppdev soundcore irda crc_ccitt intel_gtt agpgart microcode pci_hotplug i2c_i801 wbsd evdev i2c_core parport_pc mmc_core pcspkr parport battery container video fuse ac button cpufreq_powersave a
 cpi_cpufreq mperf processor reiserfs aes_i586 cryptd aes_generic lrw gf128mul hid_generic usbhid hid dm_crypt dm_mod sd_mod sr_mod cdrom pata_acpi ata_generic ata_piix libata scsi_mod uhci_h
 cd ehci_hcd usbcore usb_common
[  108.361030] Pid: 0, comm: swapper/0 Tainted: G        W    3.5.3-1-ARCH #1
[  108.361033] Call Trace:
[  108.361045]  [<c0136902>] warn_slowpath_common+0x72/0xa0
[  108.361056]  [<c013e898>] ? local_bh_enable_ip+0x68/0xa0
[  108.361066]  [<c013e898>] ? local_bh_enable_ip+0x68/0xa0
[  108.361077]  [<c0136952>] warn_slowpath_null+0x22/0x30
[  108.361088]  [<c013e898>] local_bh_enable_ip+0x68/0xa0
[  108.361099]  [<c04c5dee>] _raw_spin_unlock_bh+0x1e/0x20
[  108.361116]  [<f8498a4c>] destroy_conntrack+0x7c/0xb0 [nf_conntrack]
[  108.361129]  [<c04100de>] nf_conntrack_destroy+0x1e/0x30
[  108.361141]  [<c03e00d5>] skb_release_head_state+0xa5/0xe0
[  108.361152]  [<c03dfe80>] __kfree_skb+0x10/0x90
[  108.361162]  [<c03dff27>] consume_skb+0x27/0x90
[  108.361179]  [<f8148218>] cp_clean_rings+0xf8/0x2c0 [8139cp]
[  108.361193]  [<f81486ce>] cp_tx_timeout+0x8e/0xf0 [8139cp]
[  108.361206]  [<c04049a7>] dev_watchdog+0x1b7/0x200
[  108.361218]  [<c04047f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  108.361230]  [<c0145638>] run_timer_softirq+0x108/0x320
[  108.361242]  [<c01b45dc>] ? __rcu_process_callbacks+0x2ac/0x380
[  108.361253]  [<c04047f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  108.361264]  [<c013eaef>] __do_softirq+0x7f/0x1b0
[  108.361276]  [<c013ea70>] ? ftrace_define_fields_irq_handler_entry+0x80/0x80
[  108.361281]  <IRQ>  [<c013eebe>] ? irq_exit+0x7e/0xa0
[  108.361298]  [<c04cc87b>] ? do_IRQ+0x4b/0xc0
[  108.361309]  [<c01091d8>] ? sched_clock+0x8/0x10
[  108.361320]  [<c01691d2>] ? sched_clock_local+0xb2/0x1a0
[  108.361331]  [<c04cc7b0>] ? common_interrupt+0x30/0x38
[  108.361343]  [<c016007b>] ? perf_trace_sched_pi_setprio+0xab/0xe0
[  108.361364]  [<f878fe27>] ? acpi_idle_enter_simple+0x12d/0x16e [processor]
[  108.361386]  [<f878ff39>] ? acpi_idle_enter_bm+0xd1/0x2bd [processor]
[  108.361398]  [<c03c4129>] ? menu_select+0xb9/0x420
[  108.361416]  [<c03c28a5>] ? cpuidle_enter+0x15/0x20
[  108.361427]  [<c03c2e28>] ? cpuidle_idle_call+0x88/0x2d0
[  108.361441]  [<c010aeda>] ? cpu_idle+0xaa/0x100
[  108.361451]  [<c04aa4d4>] ? rest_init+0x6c/0x78
[  108.361462]  [<c06439c1>] ? start_kernel+0x362/0x368
[  108.361473]  [<c0643494>] ? repair_env_string+0x51/0x51
[  108.361484]  [<c06432c2>] ? i386_start_kernel+0x78/0x7d
[  108.361490] ---[ end trace 10638527877ea303 ]---
[  162.360046] 8139cp 0000:02:01.0: eth0: Transmit timeout, status  c   2b    0    0
[  246.360036] 8139cp 0000:02:01.0: eth0: Transmit timeout, status  c   2b 2020    0
[  321.032996] usb 1-1: USB disconnect, device number 3
[  331.013361] 8139cp 0000:02:01.0: eth0: Transmit timeout, status  c   2b    0    0
[  331.973376] usb 1-1: new high-speed USB device number 4 using ehci_hcd
[  332.101530] scsi3 : usb-storage 1-1:1.0
[  333.104432] scsi 3:0:0:0: Direct-Access     SanDisk  Cruzer Blade     1.10 PQ: 0 ANSI: 2
[  333.111011] sd 3:0:0:0: [sdb] 31266816 512-byte logical blocks: (16.0 GB/14.9 GiB)
[  333.112504] sd 3:0:0:0: [sdb] Write Protect is off
[  333.112517] sd 3:0:0:0: [sdb] Mode Sense: 03 00 00 00
[  333.114042] sd 3:0:0:0: [sdb] No Caching mode page present
[  333.114053] sd 3:0:0:0: [sdb] Assuming drive cache: write through
[  333.119119] sd 3:0:0:0: [sdb] No Caching mode page present
[  333.119131] sd 3:0:0:0: [sdb] Assuming drive cache: write through
[  333.122919]  sdb: sdb1
[  333.126121] sd 3:0:0:0: [sdb] No Caching mode page present
[  333.126133] sd 3:0:0:0: [sdb] Assuming drive cache: write through
[  333.126143] sd 3:0:0:0: [sdb] Attached SCSI removable disk
[  385.209116] sdb: detected capacity change from 16008609792 to 0
