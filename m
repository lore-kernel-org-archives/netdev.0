From: Vincent Pelletier <plr.vincent@gmail.com>
Subject: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Thu, 31 May 2012 23:31:05 +0200
Message-ID: <201205312331.06623.plr.vincent@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64836 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932546Ab2EaVbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 17:31:10 -0400
Received: by wibhj8 with SMTP id hj8so5390340wib.1
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 14:31:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

First of all, I'm running 3.3.4 as of debian experimental (the rest of
userland is from sid). I am not subscribed to this list, so please keep me
in CC.

I'm getting consistently errors when using btlaunchmanycurses (multi-torrent
downloader) after a few minutes. I usually first notice the network being down
(no trafic) then find this in syslog (see at bottom).

Then, I "ifdown eth0;rmmod r8169;modprobe r8169" (which implicitely ifup's),
but network never comes back - at least no trafic can go through - until
reboot.

www.kerneloops.org being down (aparently for quite some time...) I though I
should report here.

I'm quite sure this problem also occured on 3.2, but I don't know the exact
version I was using at that time. I only have this motherboard since a few
months, and previous one didn't have an IOMMU - which in my understanding is
what causes (well, detects actually) this error.

May 31 22:54:55 x2 kernel: [78579.111904] AMD-Vi: Event logged [IO_PAGE_FAULT device=05:00.0 domain=0x0019 address=0x0000000000003000 flags=0x0050]
May 31 22:55:07 x2 kernel: [78590.832047] ------------[ cut here ]------------
May 31 22:55:07 x2 kernel: [78590.832067] WARNING: at /build/buildd-linux-2.6_3.3.4-1~experimental.1-amd64-_y3OdD/linux-2.6-3.3.4/debian/build/source_amd64_none/net/sched/sch_generic.c:256 dev_watchdog+0xf2/0x151()
May 31 22:55:07 x2 kernel: [78590.832080] Hardware name: GA-990FXA-UD3
May 31 22:55:07 x2 kernel: [78590.832087] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
May 31 22:55:07 x2 kernel: [78590.832093] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) snd_hrtimer cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative xt_multiport iptable_filter ip_tables x_tables tun parport_pc ppdev lp parport binfmt_misc ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp 
libiscsi scsi_transport_iscsi fuse nfsd nfs nfs_acl auth_rpcgss fscache lockd sunrpc ext3 mbcache jbd dm_crypt raid1 md_mod powernow_k8 mperf adt7475 it87 hwmon_vid snd_emu10k1_synth snd_emux_synth snd_seq_midi_emul snd_seq_virmidi snd_emu10k1 snd_util_mem snd_ac97_codec snd_hwdep snd_pcm_oss snd_mixer_oss joydev snd_pcm snd_page_alloc nouveau snd_seq_midi 
snd_seq_midi_event snd_rawmidi snd_seq video ttm drm_kms_helper drm sp5100_tco i2c_piix4 snd_seq_device k10temp snd_timer i2c_core mxm_wmi snd emu10k1_gp gameport edac_mce_amd edac_core evdev pcspkr wmi processor soundcore ac97_bus button thermal_sys sr_mod cdrom usbhid hid power_supply re
May 31 22:55:07 x2 kernel: iserfs dm_mod nbd usb_storage uas sd_mod crc_t10dif ohci_hcd firewire_ohci firewire_core crc_itu_t ahci libahci ehci_hcd xhci_hcd r8169 mii libata scsi_mod usbcore usb_common [last unloaded: scsi_wait_scan]
May 31 22:55:07 x2 kernel: [78590.832306] Pid: 0, comm: swapper/0 Tainted: G        W  O 3.3.0-trunk-amd64 #1
May 31 22:55:07 x2 kernel: [78590.832314] Call Trace:
May 31 22:55:07 x2 kernel: [78590.832319]  <IRQ>  [<ffffffff810387cb>] ? warn_slowpath_common+0x78/0x8c
May 31 22:55:07 x2 kernel: [78590.832339]  [<ffffffff81038877>] ? warn_slowpath_fmt+0x45/0x4a
May 31 22:55:07 x2 kernel: [78590.832349]  [<ffffffff812aa28d>] ? netif_tx_lock+0x40/0x76
May 31 22:55:07 x2 kernel: [78590.832363]  [<ffffffff812aa3ff>] ? dev_watchdog+0xf2/0x151
May 31 22:55:07 x2 kernel: [78590.832374]  [<ffffffff81043ef1>] ? run_timer_softirq+0x19a/0x261
May 31 22:55:07 x2 kernel: [78590.832383]  [<ffffffff812aa30d>] ? netif_tx_unlock+0x4a/0x4a
May 31 22:55:07 x2 kernel: [78590.832395]  [<ffffffff8103de20>] ? __do_softirq+0xb9/0x177
May 31 22:55:07 x2 kernel: [78590.832405]  [<ffffffff8106d15b>] ? timekeeping_get_ns+0xd/0x2a
May 31 22:55:07 x2 kernel: [78590.832417]  [<ffffffff81358b5c>] ? call_softirq+0x1c/0x30
May 31 22:55:07 x2 kernel: [78590.832428]  [<ffffffff8100fa35>] ? do_softirq+0x3c/0x7b
May 31 22:55:07 x2 kernel: [78590.832438]  [<ffffffff8103e088>] ? irq_exit+0x3c/0x96
May 31 22:55:07 x2 kernel: [78590.832447]  [<ffffffff8100f763>] ? do_IRQ+0x82/0x98
May 31 22:55:07 x2 kernel: [78590.832459]  [<ffffffff8135282e>] ? common_interrupt+0x6e/0x6e
May 31 22:55:07 x2 kernel: [78590.832464]  <EOI>  [<ffffffff8102b0c8>] ? native_safe_halt+0x2/0x3
May 31 22:55:07 x2 kernel: [78590.832481]  [<ffffffff81014798>] ? default_idle+0x47/0x7f
May 31 22:55:07 x2 kernel: [78590.832490]  [<ffffffff8101488f>] ? amd_e400_idle+0xbf/0xe4
May 31 22:55:07 x2 kernel: [78590.832500]  [<ffffffff8100d252>] ? cpu_idle+0xaf/0xf7
May 31 22:55:07 x2 kernel: [78590.832510]  [<ffffffff8169ab37>] ? start_kernel+0x3bd/0x3c8
May 31 22:55:07 x2 kernel: [78590.832519]  [<ffffffff8169a140>] ? early_idt_handlers+0x140/0x140
May 31 22:55:07 x2 kernel: [78590.832529]  [<ffffffff8169a3c3>] ? x86_64_start_kernel+0x104/0x111
May 31 22:55:07 x2 kernel: [78590.832537] ---[ end trace 627ebd8c70d61b1a ]---
May 31 22:55:07 x2 kernel: [78590.848660] r8169 0000:05:00.0: eth0: link up
May 31 22:55:19 x2 kernel: [78602.848659] r8169 0000:05:00.0: eth0: link up
May 31 22:55:31 x2 kernel: [78614.848656] r8169 0000:05:00.0: eth0: link up
May 31 22:55:43 x2 kernel: [78626.848800] r8169 0000:05:00.0: eth0: link up
May 31 22:55:55 x2 ovpn-nexedi[2610]: NOTE: OpenVPN 2.1 requires '--script-security 2' or higher to call user-defined scripts or executables
May 31 22:56:31 x2 kernel: [78674.848666] r8169 0000:05:00.0: eth0: link up
May 31 22:57:19 x2 kernel: [78722.848598] r8169 0000:05:00.0: eth0: link up
May 31 22:58:07 x2 kernel: [78770.848662] r8169 0000:05:00.0: eth0: link up
May 31 22:58:17 x2 avahi-daemon[2744]: Withdrawing address record for 192.168.0.16 on eth0.
May 31 22:58:17 x2 avahi-daemon[2744]: Leaving mDNS multicast group on interface eth0.IPv4 with address 192.168.0.16.
May 31 22:58:17 x2 avahi-daemon[2744]: Interface eth0.IPv4 no longer relevant for mDNS.
May 31 22:58:17 x2 avahi-daemon[2744]: Interface eth0.IPv6 no longer relevant for mDNS.
May 31 22:58:17 x2 avahi-daemon[2744]: Leaving mDNS multicast group on interface eth0.IPv6 with address fe80::52e5:49ff:feb4:ed6f.
May 31 22:58:17 x2 avahi-daemon[2744]: Withdrawing address record for fe80::52e5:49ff:feb4:ed6f on eth0.
May 31 22:58:25 x2 avahi-daemon[2744]: Withdrawing workstation service for tun0.
May 31 22:59:29 x2 avahi-daemon[2744]: Withdrawing workstation service for eth0.
May 31 22:59:33 x2 kernel: [78856.929121] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
May 31 22:59:33 x2 kernel: [78856.929312] r8169 0000:05:00.0: irq 41 for MSI/MSI-X
May 31 22:59:33 x2 kernel: [78856.930671] r8169 0000:05:00.0: eth0: RTL8168evl/8111evl at 0xffffc90000c1e000, 50:e5:49:b4:ed:6f, XID 0c900880 IRQ 41
May 31 22:59:33 x2 kernel: [78856.930685] r8169 0000:05:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
May 31 22:59:33 x2 avahi-daemon[2744]: Joining mDNS multicast group on interface eth0.IPv4 with address 192.168.0.16.
May 31 22:59:33 x2 kernel: [78857.169029] r8169 0000:05:00.0: eth0: link down
May 31 22:59:33 x2 kernel: [78857.169043] r8169 0000:05:00.0: eth0: link down
May 31 22:59:33 x2 kernel: [78857.171749] ADDRCONF(NETDEV_UP): eth0: link is not ready
May 31 22:59:33 x2 avahi-daemon[2744]: New relevant interface eth0.IPv4 for mDNS.
May 31 22:59:33 x2 avahi-daemon[2744]: Registering new address record for 192.168.0.16 on eth0.IPv4.
May 31 22:59:36 x2 kernel: [78859.538358] r8169 0000:05:00.0: eth0: link up
May 31 22:59:36 x2 kernel: [78859.539012] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
May 31 22:59:37 x2 avahi-daemon[2744]: Joining mDNS multicast group on interface eth0.IPv6 with address fe80::52e5:49ff:feb4:ed6f.
May 31 22:59:37 x2 avahi-daemon[2744]: New relevant interface eth0.IPv6 for mDNS.
May 31 22:59:37 x2 avahi-daemon[2744]: Registering new address record for fe80::52e5:49ff:feb4:ed6f on eth0.*.
May 31 22:59:46 x2 kernel: [78870.104066] eth0: no IPv6 routers present
May 31 23:00:00 x2 kernel: [78883.792620] r8169 0000:05:00.0: eth0: link up
May 31 23:00:37 x2 kerneloops: Submitted 2 kernel oopses to www.kerneloops.org
May 31 23:00:48 x2 kernel: [78931.792643] r8169 0000:05:00.0: eth0: link up
May 31 23:01:21 x2 kernel: [78965.124469] r8169 0000:05:00.0: eth0: link down
May 31 23:01:26 x2 kernel: [78969.278184] r8169 0000:05:00.0: eth0: link up
May 31 23:01:27 x2 kerneloops: Submitted 1 kernel oopses to www.kerneloops.org
May 31 23:01:44 x2 kernel: [78987.792649] r8169 0000:05:00.0: eth0: link up
May 31 23:02:32 x2 kernel: [79035.792636] r8169 0000:05:00.0: eth0: link up
May 31 23:02:54 x2 shutdown[9402]: shutting down for system reboot

Regards,
-- 
Vincent Pelletier
