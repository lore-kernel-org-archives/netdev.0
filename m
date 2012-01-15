From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: NETDEV WATCHDOG: eth0 (sis900): transmit queue 0 timed out
Date: Mon, 16 Jan 2012 00:21:15 +1030
Message-ID: <k72bu8-roo.ln1@ppp121-45-136-118.lns11.adl6.internode.on.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:59095 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653Ab2AOPKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 10:10:12 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RmRil-0001DN-L2
	for netdev@vger.kernel.org; Sun, 15 Jan 2012 16:10:11 +0100
Received: from ppp121-45-83-177.lns20.adl6.internode.on.net ([121.45.83.177])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2012 16:10:11 +0100
Received: from arthur.marsh by ppp121-45-83-177.lns20.adl6.internode.on.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2012 16:10:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I've recently started using an ASUS P4S800 motherboard with a dual 
core Pentium 4 CPU and the latest Linus git master kernel.

lspci -v reports that the ethernet card is the following:

00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI 
Fast Et
hernet (rev 91)
         Subsystem: ASUSTeK Computer Inc. Device 80ff
         Flags: bus master, medium devsel, latency 32, IRQ 19
         I/O ports at 8800 [size=256]
         Memory at d5000000 (32-bit, non-prefetchable) [size=4K]
         Expansion ROM at dffe0000 [disabled] [size=128K]
         Capabilities: [40] Power Management version 2
         Kernel driver in use: sis900

A few times per day I get the following error. The kernel recovers 
quickly enough so that the link isn't reported as down.


Jan 15 23:19:43 localhost kernel: [18090.008013] ------------[ cut here 
]------------
Jan 15 23:19:43 localhost kernel: [18090.008031] WARNING: at 
net/sched/sch_generic.c:256 dev_watchdog+0xb7/0x11a()
Jan 15 23:19:43 localhost kernel: [18090.008035] Hardware name: System Name
Jan 15 23:19:43 localhost kernel: [18090.008038] NETDEV WATCHDOG: eth0 
(sis900): transmit queue 0 timed out
Jan 15 23:19:43 localhost kernel: [18090.008041] Modules linked in: 
snd_seq_dummy ppdev lp tun snd_hrtimer binfmt_misc microcode fuse 
nls_utf8 nls_cp437 vfat fat w83627hf hwmon_vid max6650 snd_emu10k1_synth 
snd_emux_synth snd_seq_midi_emul snd_seq_virmidi snd_emu10k1 
snd_ac97_codec ac97_bus usb_storage snd_pcm_oss snd_mixer_oss snd_pcm 
snd_page_alloc snd_util_mem snd_hwdep radeon snd_seq_midi 
snd_seq_midi_event emu10k1_gp ttm drm_kms_helper psmouse drm evdev 
pcspkr i2c_algo_bit snd_rawmidi snd_seq serio_raw ns558 gameport 
i2c_sis96x power_supply i2c_core parport_pc snd_seq_device snd_timer snd 
soundcore parport processor thermal_sys shpchp pci_hotplug button ext3 
jbd mbcache raid1 md_mod sr_mod cdrom sd_mod ata_generic crc_t10dif uas 
ohci_hcd floppy pata_sis libata ehci_hcd firewire_ohci eata scsi_mod 
firewire_core sis900 mii usbcore crc_itu_t usb_common [last unloaded: 
scsi_wait_scan]
Jan 15 23:19:43 localhost kernel: [18090.008154] Pid: 0, comm: swapper/0 
Not tainted 3.2.0+ #117
Jan 15 23:19:43 localhost kernel: [18090.008158] Call Trace:
Jan 15 23:19:43 localhost kernel: [18090.008169]  [<c1021549>] ? 
warn_slowpath_common+0x68/0x79
Jan 15 23:19:43 localhost kernel: [18090.008175]  [<c120e614>] ? 
dev_watchdog+0xb7/0x11a
Jan 15 23:19:43 localhost kernel: [18090.008180]  [<c10215c2>] ? 
warn_slowpath_fmt+0x29/0x2d
Jan 15 23:19:43 localhost kernel: [18090.008185]  [<c120e614>] ? 
dev_watchdog+0xb7/0x11a
Jan 15 23:19:43 localhost kernel: [18090.008194]  [<c120e55d>] ? 
netif_tx_lock+0x69/0x69
Jan 15 23:19:43 localhost kernel: [18090.008199]  [<c102afa0>] ? 
run_timer_softirq+0x132/0x218
Jan 15 23:19:43 localhost kernel: [18090.008205]  [<c10260d0>] ? 
__do_softirq+0x7d/0x162
Jan 15 23:19:43 localhost kernel: [18090.008210]  [<c1026053>] ? 
perf_trace_irq_handler_entry+0xd3/0xd3
Jan 15 23:19:43 localhost kernel: [18090.008213]  <IRQ>  [<c1026326>] ? 
irq_exit+0x32/0x7d
Jan 15 23:19:43 localhost kernel: [18090.008222]  [<c1014e0b>] ? 
smp_apic_timer_interrupt+0x5b/0x65
Jan 15 23:19:43 localhost kernel: [18090.008228]  [<c129f68d>] ? 
apic_timer_interrupt+0x31/0x38
Jan 15 23:19:43 localhost kernel: [18090.008235]  [<c107007b>] ? 
ack_bad+0x3/0x174
Jan 15 23:19:43 localhost kernel: [18090.008241]  [<c11e007b>] ? 
input_event+0x59/0x6a
Jan 15 23:19:43 localhost kernel: [18090.008248]  [<c100711b>] ? 
mwait_idle+0x65/0x8b
Jan 15 23:19:43 localhost kernel: [18090.008252]  [<c100168c>] ? 
cpu_idle+0x95/0xb4
Jan 15 23:19:43 localhost kernel: [18090.008258]  [<c13e36fd>] ? 
start_kernel+0x35b/0x360
Jan 15 23:19:43 localhost kernel: [18090.008261] ---[ end trace 
f628be76a6a336bc ]---
Jan 15 23:19:43 localhost kernel: [18090.008267] eth0: Transmit timeout, 
status 00000004 00000040

Any more information required? Any tests that I could run?

Arthur.
