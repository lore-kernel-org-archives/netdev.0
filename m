From: Andrew Dickinson <andrew@whydna.net>
Subject: transmit timed out (netdev watchdog)
Date: Fri, 1 May 2009 12:37:17 -0700
Message-ID: <606676310905011237y349e2e4cwba48c7a9196fba3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:5417 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759423AbZEAThR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 15:37:17 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1910019wfd.4
        for <netdev@vger.kernel.org>; Fri, 01 May 2009 12:37:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy gang...

While trying to push my nehalem/ixgbe box to saturation (10Gbps x 2 @
1500 byte frames), I hit this:

WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x11f/0x1b0()
Hardware name: Urbanna
NETDEV WATCHDOG: eth2 (ixgbe): transmit timed out
Modules linked in: bridge stp ipv6 dm_mirror dm_region_hash dm_log
dm_multipath scsi_dh dm_mod sbs sbshc battery acpi_memhotplug ac
parport_pc lp parport joydev sr_mod cdrom sg igb ixgbe button rtc_cmos
rtc_core rtc_lib i2c_i801 i2c_core shpchp pcspkr usb_storage ata_piix
libata sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last
unloaded: microcode]
Pid: 0, comm: swapper Not tainted 2.6.30-rc3 #10
Call Trace:
 <IRQ>  [<ffffffff80236f9e>] ? warn_slowpath+0x117/0x134
 [<ffffffff80267600>] ? handle_fasteoi_irq+0xa4/0xaa
 [<ffffffff80448204>] ? nf_iterate+0x41/0x7d
 [<ffffffffa02727c9>] ? br_handle_frame_finish+0x0/0x148 [bridge]
 [<ffffffff8022f272>] ? find_busiest_group+0x1e6/0x82a
 [<ffffffff8043e267>] ? dev_watchdog+0x11f/0x1b0
 [<ffffffff8023ef22>] ? cascade+0x57/0x6d
 [<ffffffff8043e148>] ? dev_watchdog+0x0/0x1b0
 [<ffffffff8023f064>] ? run_timer_softirq+0x12c/0x192
 [<ffffffff8023b50a>] ? __do_softirq+0xa3/0x163
 [<ffffffff8020c9fc>] ? call_softirq+0x1c/0x28
 [<ffffffff8020db9a>] ? do_softirq+0x2c/0x6c
 [<ffffffff8021b4de>] ? smp_apic_timer_interrupt+0x88/0x96
 [<ffffffff8020c413>] ? apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff80387e70>] ? acpi_idle_enter_bm+0x249/0x274
 [<ffffffff80387e66>] ? acpi_idle_enter_bm+0x23f/0x274
 [<ffffffff8040daa8>] ? cpuidle_idle_call+0x7f/0xbb
 [<ffffffff8020aa61>] ? cpu_idle+0x40/0x5e

I'm running 2.6.30-rc3.



Also, after that happened, it looks like eth2  is now flapping:
May  1 19:25:35 freeip kernel: br0: port 1(eth2) entering learning state
May  1 19:25:50 freeip kernel: br0: topology change detected, propagating
May  1 19:25:50 freeip kernel: br0: port 1(eth2) entering forwarding state
May  1 19:25:59 freeip kernel: ixgbe: eth2 NIC Link is Down
May  1 19:25:59 freeip kernel: br0: port 1(eth2) entering disabled state
May  1 19:25:59 freeip kernel: ixgbe: eth2 NIC Link is Up 10 Gbps,
Flow Control: RX/TX
May  1 19:25:59 freeip kernel: br0: port 1(eth2) entering learning state
May  1 19:26:09 freeip kernel: br0: port 1(eth2) entering disabled state
May  1 19:26:11 freeip kernel: ixgbe: eth2 NIC Link is Up 10 Gbps,
Flow Control: RX/TX
May  1 19:26:11 freeip kernel: br0: port 1(eth2) entering learning state
May  1 19:26:26 freeip kernel: br0: topology change detected, propagating
May  1 19:26:26 freeip kernel: br0: port 1(eth2) entering forwarding state
May  1 19:26:50 freeip kernel: ixgbe: eth2 NIC Link is Down

Thoughts?
