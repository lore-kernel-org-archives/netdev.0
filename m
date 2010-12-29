From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: 2.6.37-rc7: Regression: b43: crashes in hwrng_register()
Date: Wed, 29 Dec 2010 11:30:25 +0100
Message-ID: <201012291130.25416.maciej.rutecki@gmail.com>
References: <slrnihjpnh.7t4.Mario.Holbe@darkside.dyn.samba-tng.org>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: "Mario 'BitKoenig' Holbe" <Mario.Holbe@tu-ilmenau.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60834 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab0L2Kaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 05:30:30 -0500
In-Reply-To: <slrnihjpnh.7t4.Mario.Holbe@darkside.dyn.samba-tng.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(CC added)

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=25812
for your bug report, please add your address to the CC list in there, thanks!


On wtorek, 28 grudnia 2010 o 14:32:29 Mario 'BitKoenig' Holbe wrote:
> Hello,
> 
> on 2.6.37-rc7 the b43 driver crashes in hwrng_register(). This makes the
> system virtually unusable since it appears to block networking syscalls.
> This leads to, for example, ifconfig never return.
> This issue does also exist in 2.6.37-rc5.
> This issue does not exist in 2.6.36.2.
> 
> The hardware in question is:
> 02:00.0 Network controller [0280]: Broadcom Corporation BCM4312 802.11b/g
> LP-PHY [14e4:4315] (rev 01) on a Lenovo Ideapad S12 with VIA Nano.
> 
> dmesg excerpt:
> [    2.056847] b43-pci-bridge 0000:02:00.0: PCI INT A -> GSI 28 (level,
> low) -> IRQ 28 [    2.056864] b43-pci-bridge 0000:02:00.0: setting latency
> timer to 64 ...
> [    8.643695] b43-phy0: Broadcom 4312 WLAN found (core revision 15)
> [    9.047514] ieee80211 phy0: Selected rate control algorithm
> 'minstrel_ht' [    9.048441] Registered led device: b43-phy0::tx
> [    9.048479] Registered led device: b43-phy0::rx
> [    9.048518] Registered led device: b43-phy0::radio
> [    9.048542] Broadcom 43xx driver loaded [ Features: PMLS, Firmware-ID:
> FW13 ] ...
> [   24.312100] b43-phy0: Loading firmware version 410.2160 (2007-05-26
> 15:32:10) ...
> [   29.848400] b43-pci-bridge 0000:02:00.0: PCI: Disallowing DAC for device
> [   29.848407] b43-phy0: DMA mask fallback from 64-bit to 32-bit
> [   29.868632] BUG: unable to handle kernel paging request at 907cde0c
> [   29.868640] IP: [<f8d543cc>] hwrng_register+0x4c/0x139 [rng_core]
> [   29.868655] *pde = 00000000
> [   29.868659] Oops: 0000 [#1] SMP
> [   29.868664] last sysfs file: /sys/bus/pci/drivers/parport_pc/uevent
> [   29.868670] Modules linked in: parport_pc ppdev lp parport sbs sbshc
> power_meter pci_slot hed fan container acpi_cpufreq mperf
> cpufreq_conservative cpufreq_userspace cpufreq_stats cpufreq_powersave
> dm_crypt fuse loop eeprom via_cputemp i2c_dev nvram padlock_aes aes_i586
> aes_generic padlock_sha sha256_generic sha1_generic via_rng msr cpuid
> snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 snd_hwdep ecb
> snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_midi b43 snd_rawmidi uvcvideo
> snd_seq_midi_event joydev videodev btusb snd_seq rng_core video ac battery
> tpm_tis v4l1_compat tpm tpm_bios output power_supply i2c_viapro snd_timer
> ideapad_laptop snd_seq_device serio_raw wmi mac80211 cfg80211 processor
> snd pcspkr i2c_core psmouse button bluetooth evdev shpchp soundcore
> snd_page_alloc rfkill pci_hotplug ext3 jbd mbcache raid10 raid456
> async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx
> raid1 raid0 multipath linear md_mod dm_mirror dm_region_hash dm_log dm_mod
> btrfs zli b_deflate crc32c libcrc32c sd_mod crc_t10dif ata_generic
> uhci_hcd pata_via libata ssb ehci_hcd tg3 scsi_mod usbcore pcmcia
> via_sdmmc mmc_core pcmcia_core libphy thermal thermal_sys nls_base [last
> unloaded: scsi_wait_scan] [   29.868810]
> [   29.868816] Pid: 1781, comm: NetworkManager Not tainted 2.6.37-rc7-686
> #1 MoutCook/20021,2959 [   29.868822] EIP: 0060:[<f8d543cc>] EFLAGS:
> 00010286 CPU: 0
> [   29.868829] EIP is at hwrng_register+0x4c/0x139 [rng_core]
> [   29.868834] EAX: 00000001 EBX: f4b17010 ECX: f6e5db6c EDX: f4b17035
> [   29.868839] ESI: 907cddf0 EDI: 00000000 EBP: 00000036 ESP: f6e5db54
> [   29.868844]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [   29.868850] Process NetworkManager (pid: 1781, ti=f6e5c000 task=f6eb6080
> task.ti=f6e5c000) [   29.868854] Stack:
> [   29.868856]  f4b16fc0 f4b17035 f8e5a870 f4b17035 0000001f f8e70095
> f8e6f9ca f4b71e70 [   29.868866]  0000000f f6c95000 f6c95000 f6e97400
> f4b162c0 f4b10240 f4b16fc8 f8e5ad67 [   29.868875]  f89e43da f4b162c0
> f6cab400 f8b80e44 f6cab000 f8b70889 f8b6fe7a 00000000 [   29.868884] Call
> Trace:
> [   29.868909]  [<f8e5a870>] ? b43_wireless_core_init+0xd0c/0xdd6 [b43]
> [   29.868925]  [<f8e5ad67>] ? b43_op_start+0xf8/0x142 [b43]
> [   29.868947]  [<f89e43da>] ? cfg80211_netdev_notifier_call+0x342/0x355
> [cfg80211] [   29.868984]  [<f8b70889>] ? ieee80211_do_open+0xed/0x45f
> [mac80211] [   29.869002]  [<f8b6fe7a>] ?
> ieee80211_check_concurrent_iface+0x1c/0x135 [mac80211] [   29.869015] 
> [<c11edcba>] ? __dev_open+0x7d/0xa7
> [   29.869022]  [<c11ec683>] ? __dev_change_flags+0x9a/0x10d
> [   29.869028]  [<c11edc12>] ? dev_change_flags+0x10/0x3b
> [   29.869036]  [<c11f7c77>] ? do_setlink+0x23e/0x532
> [   29.869044]  [<c11f803b>] ? rtnl_setlink+0xd0/0xe1
> [   29.869058]  [<c1145b00>] ? __strncpy_from_user+0x1d/0x2b
> [   29.869064]  [<c11f7f6b>] ? rtnl_setlink+0x0/0xe1
> [   29.869069]  [<c11f77a2>] ? rtnetlink_rcv_msg+0x186/0x19c
> [   29.869075]  [<c11f761c>] ? rtnetlink_rcv_msg+0x0/0x19c
> [   29.869082]  [<c1206818>] ? netlink_rcv_skb+0x2d/0x72
> [   29.869088]  [<c11f7616>] ? rtnetlink_rcv+0x18/0x1e
> [   29.869093]  [<c120666c>] ? netlink_unicast+0xba/0x10e
> [   29.869099]  [<c1207170>] ? netlink_sendmsg+0x23d/0x256
> [   29.869111]  [<c11dfe26>] ? __sock_sendmsg+0x48/0x4e
> [   29.869117]  [<c11e008f>] ? sock_sendmsg+0x78/0x8f
> [   29.869123]  [<c11e008f>] ? sock_sendmsg+0x78/0x8f
> [   29.869131]  [<c10c6785>] ? d_kill+0x38/0x3d
> [   29.869141]  [<c11e7f0c>] ? verify_iovec+0x3d/0x79
> [   29.869147]  [<c11e088d>] ? sys_sendmsg+0x15f/0x1c1
> [   29.869153]  [<c11e04c4>] ? sockfd_lookup_light+0x13/0x3f
> [   29.869160]  [<c11e0b25>] ? sys_sendto+0xfd/0x121
> [   29.869166]  [<c11e43eb>] ? sk_prot_alloc+0x62/0xd6
> [   29.869174]  [<c1001e6e>] ? __switch_to+0x6f/0xe2
> [   29.869183]  [<c12860de>] ? schedule+0x579/0x5b6
> [   29.869190]  [<c11e0723>] ? sys_recvmsg+0x3c/0x47
> [   29.869196]  [<c11e1afd>] ? sys_socketcall+0x17f/0x1cb
> [   29.869202]  [<c1002f9f>] ? sysenter_do_call+0x12/0x28
> [   29.869206] Code: f8 e8 46 25 53 c8 8b 35 ec 45 d5 f8 eb 1a 8b 13 8b 06
> e8 17 11 3f c8 85 c0 75 0a be ef ff ff ff e9 d3 00 00 00 8b 76 1c 83 ee 1c
> <8b> 46 1c 0f 18 00 90 81 fe d0 45 d5 f8 75 d4 83 3d ec 47 d5 f8 [  
> 29.869249] EIP: [<f8d543cc>] hwrng_register+0x4c/0x139 [rng_core] SS:ESP
> 0068:f6e5db54 [   29.869259] CR2: 00000000907cde0c
> [   29.869264] ---[ end trace 6719399ed79e8cc1 ]---
> 
> 
> regards
>    Mario

-- 
Maciej Rutecki
http://www.maciek.unixy.pl
