From: Armin Kazmi <armin.kazmi@tu-dortmund.de>
Subject: debian 3.0.0-2-amd64 ACPI + Realtek rtl8169 - Hangs, NMI Backtraces
Date: Wed, 02 Nov 2011 20:27:48 +0100
Message-ID: <3839845.SWoXOUlTMv@armin-pc>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart1703242.9C23h8g3pK"
Content-Transfer-Encoding: 7Bit
Cc: Network Development <netdev@vger.kernel.org>,
	linux-acpi@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.HRZ.Uni-Dortmund.DE ([129.217.128.51]:53975 "EHLO
	unimail.uni-dortmund.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194Ab1KBT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 15:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1703242.9C23h8g3pK
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi guys,

I'm a bit lost and don't know how to track this issue down. Attached is a 
dmesg output with a rtl8169 card connected, iwlagndmesg with connected iwlagn 
device, the output of lspci, lsmod and the kernel config.

Currently the named kernel series seems to have a very strange behaviour when 
connected to a network. All further named issues don't happen at all, if there 
is no address bound to the device. However, if there is an address bound to 
the device and there is absolutely no user interaction for about 200 seconds 
(sometimes 500 seconds - I don't have a clue about the real pattern here) the 
kernel triggers NMI backtraces on all cores (2 in my case).

As an example here is a truncated dmesg only showing the backtrace for cpu 0
last lines of the backtrace shows some issues with acpi_idle_enter so this 
entire issue is likely ACPI related.

Also, it's worth mentioning.. there is absolutely nothing leaving the device 
until a user action occurs after the dump of the backtrace. E.g. SSH-ing on 
the target machine does not react at all, until I just move the mouse cursor 
on the affected machine.

There are similar issues with connections using the wireless network device 
(iwlagn), hiccups, hangs until a user action occurs, but with other dumps 
showing other errors as in the attachment "iwlagndmesg". E.g. when getting the 
dumps of the machine via scp, the machine did not react on the connection 
request at all until I moved the mouse again.

Besides "ro and quiet" there is no boot parameter set.

Please feel free to ask for more information you might need .

Regards

Armin Kazmi

------------------------

[ 2991.259780] INFO: rcu_sched_state detected stall on CPU 0 (t=15992 jiffies)
[ 2991.259784] sending NMI to all CPUs:
[ 2991.259788] NMI backtrace for cpu 0
[ 2991.259790] CPU 0 
[ 2991.259791] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd 
nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 
snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 
btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device 
ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci 
sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit 
r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci 
mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button 
processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce 
ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw 
ext4 mbcache jbd2 crc16 sd_mod crc_t10dif ata_generic thermal thermal_sys 
ata_piix libata scsi_mod
[ 2991.259854] 
[ 2991.259856] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. 
M570RU/SANTA ROSA
[ 2991.259860] RIP: 0010:[<ffffffff811abe74>]  [<ffffffff811abe74>] __delay+0xb/0x11
[ 2991.259866] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[ 2991.259868] RAX: ffffffff811abec7 RBX: 0000000000002710 RCX: 0000000000000003
[ 2991.259870] RDX: 000000000025bfea RSI: 0000000000000200 RDI: 
000000000025bfeb
[ 2991.259872] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 2991.259874] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 2991.259877] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 2991.259879] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) 
knlGS:0000000000000000
[ 2991.259881] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2991.259883] CR2: 00007fb1c26fd000 CR3: 0000000001603000 CR4: 
00000000000006f0
[ 2991.259885] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 2991.259887] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2991.259890] Process swapper (pid: 0, threadinfo ffffffff81600000, task 
ffffffff8160b020)
[ 2991.259891] Stack:
[ 2991.259893]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64
[ 2991.259896]  ffff8801402c8e40 0000000000000000 0000000000000000 
0000000000000000
[ 2991.259900]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[ 2991.259903] Call Trace:
[ 2991.259905]  <IRQ> 
[ 2991.259910]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2991.259914]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2991.259917]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2991.259920]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2991.259923]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2991.259926]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2991.259930]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2991.259933]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2991.259936]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.259940]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2991.259943]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2991.259947]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2991.259950]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2991.259954]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2991.259956]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.259959]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2991.259962]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2991.259965]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2991.259967]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2991.259970]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2991.259972]  <EOI> 
[ 2991.259979]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2991.259984]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2991.259988]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.259991]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.259995]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2991.259997]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2991.259999] Code: 1f 84 00 00 00 00 00 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 
00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 
[ 2991.260016]  83 c4 08 ff e0 48 83 ec 08 48 8d 04 bd 00 00 00 00 65 48 8b 
[ 2991.260025] Call Trace:
[ 2991.260026]  <IRQ>  [<ffffffff8101ffa1>] ? 
arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2991.260031]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2991.260034]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2991.260037]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2991.260039]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2991.260042]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2991.260045]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2991.260047]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2991.260050]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.260053]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2991.260056]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2991.260059]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2991.260061]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2991.260064]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2991.260067]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.260069]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2991.260072]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2991.260075]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2991.260077]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2991.260080]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2991.260081]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 
[processor]
[ 2991.260090]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2991.260093]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.260095]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.260098]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2991.260101]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f

--------------
--nextPart1703242.9C23h8g3pK
Content-Disposition: attachment; filename="dmesg"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="dmesg"

3729] [drm] nouveau 0000:01:00.0:   12: 0x00000a10: type 0x10 idx 12 tag 0xff
[    4.843731] [drm] nouveau 0000:01:00.0:   13: 0x00000a11: type 0x11 idx 13 tag 0xff
[    4.843734] [drm] nouveau 0000:01:00.0:   14: 0x00000a13: type 0x13 idx 14 tag 0xff
[    4.843736] [drm] nouveau 0000:01:00.0:   15: 0x00010b31: type 0x31 idx 15 tag 0x51
[    4.843740] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 0 at offset 0xCC5B
[    4.867346] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 1 at offset 0xD00C
[    4.870175] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 2 at offset 0xDD87
[    4.870184] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 3 at offset 0xDEA9
[    4.871262] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 4 at offset 0xE0D9
[    4.871264] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table at offset 0xE13E
[    4.891112] [drm] nouveau 0000:01:00.0: 0xE13E: Condition still not met after 20ms, skipping following opcodes
[    4.912031] usb 7-1: new full speed USB device number 2 using uhci_hcd
[    4.913314] [drm] nouveau 0000:01:00.0: 4 available performance level(s)
[    4.913318] [drm] nouveau 0000:01:00.0: 0: memory 100MHz core 200MHz shader 400MHz voltage 850mV fanspeed 100% timing 0
[    4.913322] [drm] nouveau 0000:01:00.0: 1: memory 301MHz core 275MHz shader 550MHz voltage 850mV fanspeed 100% timing 1
[    4.913325] [drm] nouveau 0000:01:00.0: 2: memory 301MHz core 383MHz shader 767MHz voltage 850mV fanspeed 100% timing 1
[    4.913329] [drm] nouveau 0000:01:00.0: 3: memory 799MHz core 500MHz shader 1250MHz voltage 1000mV fanspeed 100% timing 3
[    4.913354] [drm] nouveau 0000:01:00.0: c: memory 300MHz core 275MHz shader 550MHz voltage 850mV
[    4.913458] [TTM] Zone  kernel: Available graphics memory: 2030268 kiB.
[    4.913461] [TTM] Initializing pool allocator.
[    4.913481] [drm] nouveau 0000:01:00.0: Detected 512MiB VRAM
[    4.913489] mtrr: type mismatch for d0000000,10000000 old: write-back new: write-combining
[    4.916100] [drm] nouveau 0000:01:00.0: 512 MiB GART (aperture)
[    4.949490] [drm] nouveau 0000:01:00.0: DCB encoder 1 unknown
[    4.949493] [drm] nouveau 0000:01:00.0: TV-1 has no encoders, removing
[    4.950580] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    4.950582] [drm] No driver support for vblank timestamp query.
[    5.029757] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.029789] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    5.079066] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:
[    5.079068] iwlagn: Copyright(c) 2003-2011 Intel Corporation
[    5.079139] iwlagn 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    5.079148] iwlagn 0000:06:00.0: setting latency timer to 64
[    5.079174] iwlagn 0000:06:00.0: Detected Intel(R) WiFi Link 5100 AGN, REV=0x54
[    5.100944] iwlagn 0000:06:00.0: device EEPROM VER=0x11f, CALIB=0x4
[    5.100946] iwlagn 0000:06:00.0: Device SKU: 0Xb
[    5.101756] iwlagn 0000:06:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
[    5.101836] iwlagn 0000:06:00.0: irq 48 for MSI/MSI-X
[    5.117267] [drm] nouveau 0000:01:00.0: allocated 1920x1200 fb: 0x40000000, bo ffff88015963f800
[    5.117326] fbcon: nouveaufb (fb0) is primary device
[    5.122378] usb 7-1: New USB device found, idVendor=0a12, idProduct=0001
[    5.122381] usb 7-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.232087] firewire_core: created device fw0: GUID 0011066600000034, S400
[    6.412869] Console: switching to colour frame buffer device 240x75
[    6.417068] fb0: nouveaufb frame buffer device
[    6.417070] drm: registered panic notifier
[    6.417082] [drm] Initialized nouveau 0.0.16 20090420 for 0000:01:00.0 on minor 0
[    6.447369] Bluetooth: Core ver 2.16
[    6.447397] NET: Registered protocol family 31
[    6.447399] Bluetooth: HCI device and connection manager initialized
[    6.447401] Bluetooth: HCI socket layer initialized
[    6.447405] Bluetooth: L2CAP socket layer initialized
[    6.447497] Bluetooth: SCO socket layer initialized
[    6.467904] Bluetooth: Generic Bluetooth USB driver ver 0.6
[    6.468033] usbcore: registered new interface driver btusb
[    6.487113] iwlagn 0000:06:00.0: loaded firmware version 8.83.5.1 build 33692
[    6.487324] Registered led device: phy0-led
[    6.531008] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[    6.605654] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    6.605722] HDA Intel 0000:00:1b.0: irq 49 for MSI/MSI-X
[    6.605783] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    7.848089] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input9
[    8.555365] Adding 2047992k swap on /dev/sda7.  Priority:-1 extents:1 across:2047992k 
[    8.558303] EXT4-fs (sda5): re-mounted. Opts: (null)
[    8.787543] EXT4-fs (sda5): re-mounted. Opts: user_xattr,errors=remount-ro
[    8.929412] loop: module loaded
[    9.715206] EXT3-fs: barriers not enabled
[    9.715538] kjournald starting.  Commit interval 5 seconds
[    9.716076] EXT3-fs (sda6): using internal journal
[    9.716081] EXT3-fs (sda6): mounted filesystem with ordered data mode
[   10.791290] RPC: Registered named UNIX socket transport module.
[   10.791293] RPC: Registered udp transport module.
[   10.791295] RPC: Registered tcp transport module.
[   10.791296] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   10.850738] FS-Cache: Loaded
[   10.884872] FS-Cache: Netfs 'nfs' registered for caching
[   10.910690] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   16.144394] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   16.144397] Bluetooth: BNEP filters: protocol multicast
[   16.155859] Bluetooth: RFCOMM TTY layer initialized
[   16.155863] Bluetooth: RFCOMM socket layer initialized
[   16.155864] Bluetooth: RFCOMM ver 1.11
[   16.848377] lp: driver loaded but no devices found
[   16.922560] ppdev: user-space parallel port driver
[   37.254007] EXT4-fs (sda5): re-mounted. Opts: user_xattr,errors=remount-ro,commit=0
[   46.736952] hda-intel: Invalid position buffer, using LPIB read method instead.
[   46.760811] hda-intel: Invalid position buffer, using LPIB read method instead.
[   49.083966] ACPI: EC: GPE storm detected, transactions will use polling mode
[   68.950875] r8169 0000:08:00.0: eth0: link down
[   68.951431] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   70.840063] r8169 0000:08:00.0: eth0: link up
[   70.840569] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   81.472079] eth0: no IPv6 routers present
[  294.726118] INFO: rcu_sched_state detected stall on CPU 0 (t=15048 jiffies)
[  294.726124] sending NMI to all CPUs:
[  294.726132] NMI backtrace for cpu 0
[  294.726135] CPU 0 
[  294.726137] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  294.726224] 
[  294.726226] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  294.726230] RIP: 0010:[<ffffffff8100ecad>]  [<ffffffff8100ecad>] native_read_tsc+0x2/0x11
[  294.726238] RSP: 0018:ffff88015fc03a70  EFLAGS: 00000096
[  294.726240] RAX: 000000001109849e RBX: 0000000000002710 RCX: 0000000000000003
[  294.726242] RDX: 000000000000007c RSI: 0000000000000200 RDI: 000000000025bfeb
[  294.726243] RBP: 000000000025bfeb R08: 0000000000000000 R09: 00000000fffffffe
[  294.726245] R10: 0000000000000000 R11: 0000000000000005 R12: 0000000000000000
[  294.726247] R13: ffff88015fc03ba8 R14: 0000000000000001 R15: ffffffff8106d090
[  294.726250] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[  294.726252] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  294.726254] CR2: 00000000018aca18 CR3: 0000000159c93000 CR4: 00000000000006f0
[  294.726256] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  294.726258] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  294.726260] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[  294.726262] Stack:
[  294.726263]  ffffffff811abe35 ffffffff811abee4 0000000000002710 ffffffff8161b800
[  294.726267]  ffffffff8161b900 ffff88015fc03ba8 ffffffff8101ffa1 ffff88015fc0ecf0
[  294.726270]  ffffffff81096d64 0000000000000001 0000000000000000 0000000000000000
[  294.726273] Call Trace:
[  294.726275]  <IRQ> 
[  294.726279]  [<ffffffff811abe35>] ? paravirt_read_tsc+0x5/0x8
[  294.726282]  [<ffffffff811abee4>] ? delay_tsc+0x1d/0x68
[  294.726286]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  294.726290]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  294.726293]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  294.726296]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  294.726299]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  294.726302]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  294.726305]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  294.726309]  [<ffffffff812ba2db>] ? tcp_established_options+0x2d/0xa4
[  294.726312]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  294.726315]  [<ffffffff8101f569>] ? smp_apic_timer_interrupt+0x71/0x86
[  294.726319]  [<ffffffff8133ca93>] ? apic_timer_interrupt+0x13/0x20
[  294.726322]  [<ffffffff812be27b>] ? atomic_dec_and_test+0x3/0xf
[  294.726325]  [<ffffffff812bf4ff>] ? sock_put+0xd/0x1c
[  294.726328]  [<ffffffff812c1a9a>] ? tcp_v4_rcv+0x4c7/0x66c
[  294.726332]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[  294.726336]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  294.726339]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[  294.726342]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  294.726345]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  294.726348]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  294.726355]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  294.726358]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  294.726361]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  294.726365]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  294.726368]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  294.726371]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  294.726374]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  294.726376]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  294.726378]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  294.726381]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  294.726383]  <EOI> 
[  294.726389]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  294.726394]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  294.726397]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  294.726400]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  294.726403]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  294.726406]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  294.726407] Code: eb 0e bf 8e 21 00 00 48 83 c4 08 e9 e8 d1 19 00 48 83 c4 08 c3 90 40 88 f8 e6 70 e4 71 c3 40 88 f0 e6 70 40 88 f8 e6 71 c3 0f 31 
[  294.726424]  c1 48 89 d0 48 c1 e0 20 89 c9 48 09 c8 c3 41 55 b2 0b 88 d0 
[  294.726433] Call Trace:
[  294.726434]  <IRQ>  [<ffffffff811abe35>] ? paravirt_read_tsc+0x5/0x8
[  294.726439]  [<ffffffff811abee4>] ? delay_tsc+0x1d/0x68
[  294.726441]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  294.726444]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  294.726447]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  294.726449]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  294.726452]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  294.726454]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  294.726457]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  294.726459]  [<ffffffff812ba2db>] ? tcp_established_options+0x2d/0xa4
[  294.726462]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  294.726465]  [<ffffffff8101f569>] ? smp_apic_timer_interrupt+0x71/0x86
[  294.726468]  [<ffffffff8133ca93>] ? apic_timer_interrupt+0x13/0x20
[  294.726471]  [<ffffffff812be27b>] ? atomic_dec_and_test+0x3/0xf
[  294.726473]  [<ffffffff812bf4ff>] ? sock_put+0xd/0x1c
[  294.726476]  [<ffffffff812c1a9a>] ? tcp_v4_rcv+0x4c7/0x66c
[  294.726479]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[  294.726482]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  294.726484]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[  294.726487]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  294.726490]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  294.726493]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  294.726497]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  294.726500]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  294.726503]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  294.726506]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  294.726508]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  294.726511]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  294.726513]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  294.726516]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  294.726518]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  294.726521]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  294.726522]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  294.726531]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  294.726534]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  294.726536]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  294.726539]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  294.726541]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  294.726544] NMI backtrace for cpu 1
[  294.726546] CPU 1 
[  294.726548] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  294.726592] 
[  294.726594] Pid: 2271, comm: mysqld Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  294.726598] RIP: 0033:[<00007f1717479385>]  [<00007f1717479385>] 0x7f1717479384
[  294.726603] RSP: 002b:00007f170c857e00  EFLAGS: 00000206
[  294.726604] RAX: 00007f171848fb90 RBX: 00007f1714d18920 RCX: 00007f1715faae63
[  294.726606] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00007f1714d18920
[  294.726608] RBP: 00000000000008df R08: 00007f170c857e10 R09: 00007f170c858700
[  294.726610] R10: 0000000000000000 R11: 0000000000000000 R12: 000000004eb1917f
[  294.726612] R13: 0000000000084830 R14: 00007f171848f5a0 R15: 0000000000084830
[  294.726615] FS:  00007f170c858700(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[  294.726617] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  294.726619] CR2: 00000000025df000 CR3: 00000001434ce000 CR4: 00000000000006e0
[  294.726621] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  294.726623] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  294.726625] Process mysqld (pid: 2271, threadinfo ffff88013e87a000, task ffff88013e854970)
[  294.726627] 
[  294.726628] Call Trace:
[  519.910244] CE: hpet increased min_delta_ns to 20113 nsec
[  678.718017] INFO: rcu_sched_state detected stall on CPU 0 (t=15865 jiffies)
[  678.718023] sending NMI to all CPUs:
[  678.718030] NMI backtrace for cpu 0
[  678.718033] CPU 0 
[  678.718035] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  678.718149] 
[  678.718153] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  678.718163] RIP: 0010:[<ffffffff811abe7e>]  [<ffffffff811abe7e>] __const_udelay+0x4/0x28
[  678.718176] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[  678.718177] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000003
[  678.718180] RDX: ffffffff81684078 RSI: 0000000000000200 RDI: 0000000000418958
[  678.718181] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[  678.718183] R10: 0000000000000000 R11: 0000000000003246 R12: ffffffff8161b900
[  678.718185] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[  678.718188] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[  678.718190] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  678.718192] CR2: 00007f7a14b4a000 CR3: 0000000001603000 CR4: 00000000000006f0
[  678.718194] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  678.718196] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  678.718198] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[  678.718200] Stack:
[  678.718201]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64
[  678.718205]  ffff88015fc12800 0000000000000000 0000000000000000 0000000000000000
[  678.718208]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[  678.718211] Call Trace:
[  678.718213]  <IRQ> 
[  678.718218]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  678.718222]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  678.718225]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  678.718228]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  678.718232]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  678.718234]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  678.718238]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  678.718241]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  678.718245]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  678.718248]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  678.718251]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  678.718255]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  678.718258]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  678.718261]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  678.718264]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  678.718267]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  678.718269]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  678.718272]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  678.718275]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  678.718277]  <EOI> 
[  678.718284]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  678.718289]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  678.718293]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  678.718296]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  678.718299]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  678.718302]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  678.718304] Code: 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 
[  678.718321]  8d 04 bd 00 00 00 00 65 48 8b 14 25 58 27 01 00 48 6b d2 3e 
[  678.718329] Call Trace:
[  678.718331]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  678.718335]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  678.718338]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  678.718341]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  678.718343]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  678.718346]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  678.718349]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  678.718351]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  678.718354]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  678.718357]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  678.718360]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  678.718363]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  678.718365]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  678.718368]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  678.718370]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  678.718373]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  678.718376]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  678.718378]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  678.718380]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  678.718382]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  678.718390]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  678.718393]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  678.718396]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  678.718399]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  678.718401]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  678.718404] NMI backtrace for cpu 1
[  678.718406] CPU 1 
[  678.718407] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  678.718452] 
[  678.718454] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  678.718457] RIP: 0010:[<ffffffff812a602d>]  [<ffffffff812a602d>] ip_rcv+0x12/0x219
[  678.718463] RSP: 0018:ffff88015fd03d40  EFLAGS: 00000297
[  678.718464] RAX: 0000000000000002 RBX: ffff88015841c980 RCX: ffff8801596e0000
[  678.718466] RDX: ffffffff81688cf0 RSI: ffff8801596e0000 RDI: ffff88015841c980
[  678.718468] RBP: ffff8801596e0000 R08: ffffffff81688cf0 R09: ffff88012ff17840
[  678.718470] R10: ffff8801599d60c0 R11: ffff8801435b3900 R12: ffff8801596e0000
[  678.718472] R13: 0000000000000000 R14: ffffffff81686e50 R15: 0000000000001486
[  678.718475] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[  678.718477] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  678.718479] CR2: 00007ffe5b9ac000 CR3: 0000000159c93000 CR4: 00000000000006e0
[  678.718481] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  678.718483] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  678.718485] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[  678.718487] Stack:
[  678.718488]  ffffffff81686e10 0000000000000008 ffff8801596e0000 ffffffff8127d0c7
[  678.718492]  ffffffff8103f092 ffff88015841c980 ffff88015841c980 ffffffff81686e50
[  678.718495]  ffff8801596e0758 ffff88015841c980 ffff8801596e0740 ffff880037c2e860
[  678.718498] Call Trace:
[  678.718499]  <IRQ> 
[  678.718504]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  678.718507]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[  678.718510]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  678.718513]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  678.718516]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  678.718522]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  678.718525]  [<ffffffff81064cf3>] ? sched_clock_local+0x10/0x75
[  678.718528]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  678.718530]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  678.718534]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  678.718537]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  678.718540]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  678.718542]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  678.718545]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  678.718547]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  678.718548]  <EOI> 
[  678.718553]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  678.718558]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  678.718561]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  678.718563]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  678.718566]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  678.718570]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[  678.718572] Code: 48 89 de 48 c7 c1 d9 5c 2a 81 5b bf 01 00 00 00 e9 7d fe ff ff 31 c0 5b c3 41 54 55 48 89 f5 53 8a 47 7d 48 89 fb 83 e0 07 3c 03 <0f> 84 ee 01 00 00 48 8b 86 e0 03 00 00 48 8b 80 e0 00 00 00 65 
[  678.718597] Call Trace:
[  678.718598]  <IRQ>  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  678.718603]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[  678.718606]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  678.718609]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  678.718611]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  678.718616]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  678.718618]  [<ffffffff81064cf3>] ? sched_clock_local+0x10/0x75
[  678.718621]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  678.718624]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  678.718627]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  678.718629]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  678.718632]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  678.718634]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  678.718636]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  678.718639]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  678.718640]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  678.718649]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  678.718651]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  678.718654]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  678.718657]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  678.718659]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[  740.183881] INFO: rcu_sched_state detected stall on CPU 0 (t=15268 jiffies)
[  740.183887] sending NMI to all CPUs:
[  740.183894] NMI backtrace for cpu 0
[  740.183897] CPU 0 
[  740.183899] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  740.184016] 
[  740.184018] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  740.184022] RIP: 0010:[<ffffffff811abe69>]  [<ffffffff811abe69>] delay_loop+0x31/0x31
[  740.184029] RSP: 0018:ffff88015fc03bb0  EFLAGS: 00000893
[  740.184030] RAX: 00000000ad863300 RBX: 0000000000002710 RCX: 0000000000000003
[  740.184032] RDX: 000000000025bfea RSI: 0000000000000200 RDI: 000000000025bfeb
[  740.184034] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[  740.184036] R10: 0000000000000000 R11: ffffffff817ee008 R12: ffffffff8161b900
[  740.184038] R13: ffff88015fc03cb8 R14: 0000000000000001 R15: ffffffff8106d090
[  740.184041] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[  740.184043] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  740.184045] CR2: 00007fb1be7dd028 CR3: 0000000001603000 CR4: 00000000000006f0
[  740.184047] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  740.184049] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  740.184051] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[  740.184053] Stack:
[  740.184054]  ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64 0000000000000001
[  740.184058]  0000000000000000 0000000000000000 0000000000000000 ffff88015fc03cb8
[  740.184061]  0000000000000001 ffffffff8106d090 ffffffff81097365 ffffffff8160b020
[  740.184064] Call Trace:
[  740.184066]  <IRQ> 
[  740.184070]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  740.184074]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  740.184078]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  740.184080]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  740.184084]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  740.184086]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  740.184090]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  740.184093]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  740.184097]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  740.184100]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  740.184104]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  740.184107]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  740.184110]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  740.184113]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  740.184115]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  740.184117]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  740.184121]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184125]  [<ffffffff8104b19b>] ? arch_local_irq_enable+0x4/0x8
[  740.184127]  [<ffffffff8109285c>] ? handle_irq_event_percpu+0x166/0x184
[  740.184131]  [<ffffffff8104bde4>] ? __do_softirq+0x59/0x178
[  740.184134]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  740.184137]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  740.184139]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  740.184142]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  740.184144]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  740.184147]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184148]  <EOI> 
[  740.184156]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  740.184161]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  740.184164]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  740.184167]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  740.184170]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  740.184173]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  740.184174] Code: 74 25 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 
[  740.184191]  83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 
[  740.184200] Call Trace:
[  740.184202]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  740.184206]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  740.184209]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  740.184212]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  740.184214]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  740.184217]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  740.184219]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  740.184222]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  740.184225]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  740.184228]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  740.184231]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  740.184233]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  740.184236]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  740.184239]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  740.184241]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  740.184244]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  740.184246]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184249]  [<ffffffff8104b19b>] ? arch_local_irq_enable+0x4/0x8
[  740.184252]  [<ffffffff8109285c>] ? handle_irq_event_percpu+0x166/0x184
[  740.184254]  [<ffffffff8104bde4>] ? __do_softirq+0x59/0x178
[  740.184257]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  740.184259]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  740.184262]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  740.184264]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  740.184267]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  740.184269]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184270]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  740.184279]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  740.184282]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  740.184284]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  740.184287]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  740.184290]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  740.184292] NMI backtrace for cpu 1
[  740.184294] CPU 1 
[  740.184296] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  740.184340] 
[  740.184342] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  740.184346] RIP: 0010:[<ffffffff811b734e>]  [<ffffffff811b734e>] swiotlb_bounce+0x2e/0x31
[  740.184351] RSP: 0018:ffff88015fd03908  EFLAGS: 00010246
[  740.184353] RAX: ffff88009ec9f800 RBX: ffff88009ec9f800 RCX: 000000000000004a
[  740.184355] RDX: 000000000000004e RSI: ffff88014b325ce6 RDI: ffff88009ec9f804
[  740.184356] RBP: ffff88009ec9f800 R08: 0000000000000000 R09: 0000000000000000
[  740.184358] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
[  740.184360] R13: 0000000000000001 R14: 0000000000200000 R15: 0000000000000286
[  740.184363] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[  740.184365] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  740.184367] CR2: 00007f365a981010 CR3: 0000000159c93000 CR4: 00000000000006e0
[  740.184369] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  740.184371] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  740.184373] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[  740.184375] Stack:
[  740.184376]  ffffffff811b7874 ffff88015fd12800 ffffffff00000000 0000000000137d96
[  740.184379]  000000000000004e 000000014b325ce2 0000000181336e1c 0000000000000086
[  740.184383]  ffff88015a925090 000000000000004e 0000000000000001 000000000000004e
[  740.184386] Call Trace:
[  740.184387]  <IRQ> 
[  740.184390]  [<ffffffff811b7874>] ? swiotlb_tbl_map_single+0x1d3/0x1e5
[  740.184393]  [<ffffffff811b7a52>] ? swiotlb_map_page+0x6e/0xe3
[  740.184396]  [<ffffffff811b79e4>] ? swiotlb_map_sg+0x10/0x10
[  740.184402]  [<ffffffffa01f4944>] ? dma_map_single_attrs.clone.46+0x5a/0x71 [r8169]
[  740.184408]  [<ffffffffa01f50c7>] ? rtl8169_start_xmit+0xc8/0x4af [r8169]
[  740.184412]  [<ffffffff8127538a>] ? skb_checksum+0x46/0x1ce
[  740.184416]  [<ffffffff8127ef6c>] ? dev_hard_start_xmit+0x3c3/0x4dc
[  740.184420]  [<ffffffff8100e74a>] ? native_sched_clock+0x28/0x30
[  740.184423]  [<ffffffff81295c7c>] ? sch_direct_xmit+0x60/0x134
[  740.184426]  [<ffffffff8127f33e>] ? dev_queue_xmit+0x2b9/0x461
[  740.184429]  [<ffffffff812a1bba>] ? ipv4_default_mtu+0x21/0x59
[  740.184432]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  740.184435]  [<ffffffff812bba9e>] ? tcp_transmit_skb+0x724/0x757
[  740.184438]  [<ffffffff812b9e95>] ? tcp_rcv_established+0x4f1/0x532
[  740.184441]  [<ffffffff812bf875>] ? tcp_v4_do_rcv+0x172/0x32c
[  740.184444]  [<ffffffff812c19ec>] ? tcp_v4_rcv+0x419/0x66c
[  740.184448]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[  740.184451]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  740.184454]  [<ffffffff8133cf73>] ? reschedule_interrupt+0x13/0x20
[  740.184457]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  740.184459]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  740.184462]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  740.184467]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  740.184470]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  740.184473]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  740.184475]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  740.184478]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  740.184481]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  740.184483]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  740.184486]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  740.184488]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  740.184491]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184492]  <EOI> 
[  740.184497]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  740.184502]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  740.184505]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  740.184507]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  740.184510]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  740.184514]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[  740.184515] Code: 89 f0 75 13 48 be 00 00 00 00 00 88 ff ff 48 8d 34 37 48 89 c7 eb 11 49 b8 00 00 00 00 00 88 ff ff 4e 8d 04 07 4c 89 c7 48 89 d1 <f3> a4 c3 48 89 f0 48 2b 05 8d b4 62 00 4c 8b 0d 8e b4 62 00 48 
[  740.184540] Call Trace:
[  740.184541]  <IRQ>  [<ffffffff811b7874>] ? swiotlb_tbl_map_single+0x1d3/0x1e5
[  740.184547]  [<ffffffff811b7a52>] ? swiotlb_map_page+0x6e/0xe3
[  740.184549]  [<ffffffff811b79e4>] ? swiotlb_map_sg+0x10/0x10
[  740.184554]  [<ffffffffa01f4944>] ? dma_map_single_attrs.clone.46+0x5a/0x71 [r8169]
[  740.184559]  [<ffffffffa01f50c7>] ? rtl8169_start_xmit+0xc8/0x4af [r8169]
[  740.184562]  [<ffffffff8127538a>] ? skb_checksum+0x46/0x1ce
[  740.184565]  [<ffffffff8127ef6c>] ? dev_hard_start_xmit+0x3c3/0x4dc
[  740.184568]  [<ffffffff8100e74a>] ? native_sched_clock+0x28/0x30
[  740.184571]  [<ffffffff81295c7c>] ? sch_direct_xmit+0x60/0x134
[  740.184573]  [<ffffffff8127f33e>] ? dev_queue_xmit+0x2b9/0x461
[  740.184576]  [<ffffffff812a1bba>] ? ipv4_default_mtu+0x21/0x59
[  740.184579]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  740.184581]  [<ffffffff812bba9e>] ? tcp_transmit_skb+0x724/0x757
[  740.184584]  [<ffffffff812b9e95>] ? tcp_rcv_established+0x4f1/0x532
[  740.184587]  [<ffffffff812bf875>] ? tcp_v4_do_rcv+0x172/0x32c
[  740.184590]  [<ffffffff812c19ec>] ? tcp_v4_rcv+0x419/0x66c
[  740.184593]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[  740.184596]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[  740.184598]  [<ffffffff8133cf73>] ? reschedule_interrupt+0x13/0x20
[  740.184601]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[  740.184604]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[  740.184606]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[  740.184611]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[  740.184614]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  740.184616]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  740.184619]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  740.184622]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  740.184624]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  740.184627]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  740.184629]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  740.184632]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  740.184634]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  740.184636]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  740.184644]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[  740.184647]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  740.184649]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  740.184652]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  740.184655]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[  998.711523] INFO: rcu_sched_state detected stall on CPU 0 (t=15747 jiffies)
[  998.711527] sending NMI to all CPUs:
[  998.711532] NMI backtrace for cpu 0
[  998.711533] CPU 0 
[  998.711535] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  998.711597] 
[  998.711600] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  998.711603] RIP: 0010:[<ffffffff811abe8f>]  [<ffffffff811abe8f>] __const_udelay+0x15/0x28
[  998.711610] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[  998.711612] RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000003
[  998.711614] RDX: 000000000098371c RSI: 0000000000000200 RDI: 0000000000418958
[  998.711616] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[  998.711618] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[  998.711620] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[  998.711623] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[  998.711625] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  998.711627] CR2: 00007f0e11be8000 CR3: 0000000001603000 CR4: 00000000000006f0
[  998.711629] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  998.711631] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  998.711633] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[  998.711635] Stack:
[  998.711636]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64
[  998.711639]  ffff88015fc12800 0000000000000000 0000000000000000 0000000000000000
[  998.711643]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[  998.711646] Call Trace:
[  998.711647]  <IRQ> 
[  998.711652]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  998.711656]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  998.711660]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  998.711662]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  998.711666]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  998.711668]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  998.711672]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  998.711675]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  998.711678]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  998.711682]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  998.711685]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  998.711688]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  998.711691]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  998.711695]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  998.711697]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  998.711700]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  998.711703]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  998.711705]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  998.711708]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  998.711711]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  998.711713]  <EOI> 
[  998.711720]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  998.711725]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  998.711728]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  998.711731]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  998.711735]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  998.711738]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  998.711739] Code: fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 48 8d 04 bd 00 00 00 00 65 48 8b 14 25 58 27 01 00 
[  998.711756]  6b d2 3e 48 83 c4 08 f7 e2 48 8d 7a 01 e9 c7 ff ff ff 48 69 
[  998.711765] Call Trace:
[  998.711766]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[  998.711771]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[  998.711774]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[  998.711776]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[  998.711779]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[  998.711781]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[  998.711784]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[  998.711787]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[  998.711790]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  998.711793]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[  998.711795]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[  998.711798]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[  998.711801]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[  998.711803]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[  998.711806]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[  998.711809]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[  998.711811]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[  998.711814]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[  998.711816]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[  998.711818]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  998.711820]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  998.711829]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  998.711831]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  998.711834]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  998.711837]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[  998.711839]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[  998.711842] NMI backtrace for cpu 1
[  998.711844] CPU 1 
[  998.711845] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[  998.711890] 
[  998.711892] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[  998.711895] RIP: 0010:[<ffffffff811b734e>]  [<ffffffff811b734e>] swiotlb_bounce+0x2e/0x31
[  998.711900] RSP: 0018:ffff88015fd03df8  EFLAGS: 00010202
[  998.711902] RAX: ffff88009ce73000 RBX: ffff8801596e0000 RCX: 0000000000000066
[  998.711904] RDX: 0000000000000176 RSI: ffff88009ce73110 RDI: ffff880139e28110
[  998.711906] RBP: ffff8801596e0740 R08: ffff880139e28000 R09: ffff88015ff43000
[  998.711908] R10: ffff8801599d60c0 R11: 0000000000000006 R12: ffff880037c2e1d0
[  998.711910] R13: 000000003804417a R14: ffff88015afc49c0 R15: 000000000000151d
[  998.711912] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[  998.711914] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  998.711916] CR2: 00007fb1c26fd000 CR3: 0000000001603000 CR4: 00000000000006e0
[  998.711918] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  998.711920] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  998.711923] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[  998.711924] Stack:
[  998.711926]  ffffffffa01f4bc3 ffffffff81064cf3 0000000000000176 ffff880139e28000
[  998.711929]  ffff8801596e0758 ffff88015a925090 00000176000003a6 0000004000000033
[  998.711933]  ffffc90000642000 000000009ce73000 ffff8801596e0758 ffffffff81279894
[  998.711936] Call Trace:
[  998.711937]  <IRQ> 
[  998.711943]  [<ffffffffa01f4bc3>] ? rtl8169_poll+0x19d/0x454 [r8169]
[  998.711946]  [<ffffffff81064cf3>] ? sched_clock_local+0x10/0x75
[  998.711950]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  998.711953]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  998.711957]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  998.711960]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  998.711962]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  998.711965]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  998.711967]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  998.711970]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  998.711971]  <EOI> 
[  998.711976]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  998.711981]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  998.711984]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  998.711987]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  998.711990]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  998.711993]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[  998.711995] Code: 89 f0 75 13 48 be 00 00 00 00 00 88 ff ff 48 8d 34 37 48 89 c7 eb 11 49 b8 00 00 00 00 00 88 ff ff 4e 8d 04 07 4c 89 c7 48 89 d1 <f3> a4 c3 48 89 f0 48 2b 05 8d b4 62 00 4c 8b 0d 8e b4 62 00 48 
[  998.712020] Call Trace:
[  998.712021]  <IRQ>  [<ffffffffa01f4bc3>] ? rtl8169_poll+0x19d/0x454 [r8169]
[  998.712027]  [<ffffffff81064cf3>] ? sched_clock_local+0x10/0x75
[  998.712030]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[  998.712033]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[  998.712036]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[  998.712038]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[  998.712041]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[  998.712043]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[  998.712046]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[  998.712048]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[  998.712050]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[  998.712058]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[  998.712061]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[  998.712064]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[  998.712066]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[  998.712069]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 1446.702350] INFO: rcu_sched_state detected stall on CPU 1 (t=15966 jiffies)
[ 1446.702355] sending NMI to all CPUs:
[ 1446.702359] NMI backtrace for cpu 1
[ 1446.702361] CPU 1 
[ 1446.702362] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 1446.702425] 
[ 1446.702427] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 1446.702430] RIP: 0010:[<ffffffff811abe74>]  [<ffffffff811abe74>] __delay+0xb/0x11
[ 1446.702437] RSP: 0018:ffff88015fd03d08  EFLAGS: 00000092
[ 1446.702439] RAX: ffffffff811abec7 RBX: 0000000000002710 RCX: 0000000000000003
[ 1446.702441] RDX: 000000000025bf43 RSI: 0000000000000200 RDI: 000000000025bf44
[ 1446.702443] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 1446.702445] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 1446.702447] R13: ffff88015fd03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 1446.702450] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 1446.702452] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1446.702454] CR2: 00007f04ef0c0000 CR3: 0000000001603000 CR4: 00000000000006e0
[ 1446.702456] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1446.702458] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1446.702460] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 1446.702462] Stack:
[ 1446.702463]  0000000000000096 ffffffff8101ffa1 ffff88015fd0ecf0 ffffffff81096d64
[ 1446.702467]  ffff88015fd12800 0000000000000001 0000000000000000 0000000000000001
[ 1446.702470]  ffff88015fd03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[ 1446.702473] Call Trace:
[ 1446.702475]  <IRQ> 
[ 1446.702480]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 1446.702484]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 1446.702487]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 1446.702490]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 1446.702493]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 1446.702496]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 1446.702499]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 1446.702502]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 1446.702506]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 1446.702509]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 1446.702512]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 1446.702516]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 1446.702519]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 1446.702522]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 1446.702525]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 1446.702528]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 1446.702531]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 1446.702533]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 1446.702535]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 1446.702539]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 1446.702540]  <EOI> 
[ 1446.702548]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 1446.702553]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 1446.702557]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 1446.702560]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 1446.702563]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 1446.702566]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 1446.702568] Code: 1f 84 00 00 00 00 00 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 
[ 1446.702585]  83 c4 08 ff e0 48 83 ec 08 48 8d 04 bd 00 00 00 00 65 48 8b 
[ 1446.702594] Call Trace:
[ 1446.702595]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 1446.702600]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 1446.702602]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 1446.702605]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 1446.702608]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 1446.702610]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 1446.702613]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 1446.702615]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 1446.702618]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 1446.702621]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 1446.702624]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 1446.702627]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 1446.702629]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 1446.702632]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 1446.702634]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 1446.702637]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 1446.702640]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 1446.702642]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 1446.702645]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 1446.702647]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 1446.702648]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 1446.702657]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 1446.702660]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 1446.702662]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 1446.702665]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 1446.702668]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 1446.702671] NMI backtrace for cpu 0
[ 1446.702673] CPU 0 
[ 1446.702674] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 1446.702718] 
[ 1446.702720] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 1446.702724] RIP: 0010:[<ffffffffa01f4bf9>]  [<ffffffffa01f4bf9>] rtl8169_poll+0x1d3/0x454 [r8169]
[ 1446.702731] RSP: 0018:ffff88015fc03e00  EFLAGS: 00010282
[ 1446.702733] RAX: ffff88013761d040 RBX: ffff8801596e0000 RCX: 000000000000017b
[ 1446.702735] RDX: 00000000000002b0 RSI: ffff880137488005 RDI: ffff88013761d045
[ 1446.702737] RBP: ffff8801596e0740 R08: ffff880137488000 R09: ffff88015ff43000
[ 1446.702739] R10: ffff8801599d60c0 R11: 0000000000000007 R12: ffff880037c2eb50
[ 1446.702741] R13: 0000000038044184 R14: ffff880159215980 R15: 000000000000e3b5
[ 1446.702743] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 1446.702745] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1446.702747] CR2: 00007f04ef0c0000 CR3: 0000000001603000 CR4: 00000000000006f0
[ 1446.702749] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1446.702751] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1446.702753] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 1446.702755] Stack:
[ 1446.702756]  7fffffffffffffff 0000000000000180 ffff880137488000 ffff8801596e0758
[ 1446.702760]  ffff88015a925090 000001805fc0eaf0 0000004000000037 ffffc90000642000
[ 1446.702763]  000000009d0d3000 ffff8801596e0758 ffffffff81279894 ffff8801596e0758
[ 1446.702767] Call Trace:
[ 1446.702768]  <IRQ> 
[ 1446.702772]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 1446.702776]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 1446.702779]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 1446.702783]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 1446.702785]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 1446.702788]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 1446.702790]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 1446.702793]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 1446.702795]  <EOI> 
[ 1446.702800]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 1446.702805]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 1446.702807]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 1446.702810]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 1446.702813]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 1446.702816]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 1446.702818] Code: 24 2c 0f 18 0a ba 20 00 00 00 e8 c5 fa 07 e1 48 85 c0 49 89 c6 74 16 48 8b 80 e0 00 00 00 48 8b 74 24 10 48 8b 4c 24 08 48 89 c7 <f3> a4 48 8b 7c 24 20 e8 af df ff ff 48 8b 40 38 48 85 c0 74 16 
[ 1446.702843] Call Trace:
[ 1446.702844]  <IRQ>  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 1446.702849]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 1446.702852]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 1446.702854]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 1446.702857]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 1446.702859]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 1446.702862]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 1446.702864]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 1446.702865]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 1446.702874]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 1446.702877]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 1446.702879]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 1446.702882]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 1446.702885]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2285.148702] INFO: rcu_sched_state detected stall on CPU 0 (t=15784 jiffies)
[ 2285.148706] sending NMI to all CPUs:
[ 2285.148711] NMI backtrace for cpu 0
[ 2285.148712] CPU 0 
[ 2285.148713] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2285.148776] 
[ 2285.148778] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2285.148782] RIP: 0010:[<ffffffff8100ecab>]  [<ffffffff8100ecab>] rtc_cmos_write+0xb/0xb
[ 2285.148789] RSP: 0018:ffff88015fc03ce0  EFLAGS: 00000092
[ 2285.148791] RAX: ffffffff811abec7 RBX: 0000000000002710 RCX: 0000000000000003
[ 2285.148793] RDX: 000000000025bfea RSI: 0000000000000200 RDI: 000000000025bfeb
[ 2285.148795] RBP: 000000000025bfeb R08: 0000000000000000 R09: 00000000fffffffe
[ 2285.148797] R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000000
[ 2285.148799] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 2285.148801] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 2285.148804] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2285.148806] CR2: 00007fc104b71000 CR3: 0000000001603000 CR4: 00000000000006f0
[ 2285.148808] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2285.148810] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2285.148812] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 2285.148813] Stack:
[ 2285.148815]  ffffffff811abe35 ffffffff811abee4 0000000000002710 ffffffff8161b800
[ 2285.148819]  ffffffff8161b900 ffff88015fc03e18 ffffffff8101ffa1 ffff88015fc0ecf0
[ 2285.148822]  ffffffff81096d64 ffff88015fc12800 0000000000000000 0000000000000000
[ 2285.148825] Call Trace:
[ 2285.148827]  <IRQ> 
[ 2285.148831]  [<ffffffff811abe35>] ? paravirt_read_tsc+0x5/0x8
[ 2285.148834]  [<ffffffff811abee4>] ? delay_tsc+0x1d/0x68
[ 2285.148838]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2285.148842]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2285.148845]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2285.148848]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2285.148851]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2285.148854]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2285.148858]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2285.148861]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2285.148865]  [<ffffffff811a856d>] ? rb_insert_color+0x5f/0xd9
[ 2285.148869]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2285.148871]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2285.148875]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2285.148878]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2285.148881]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2285.148884]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2285.148887]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2285.148890]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2285.148892]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2285.148895]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2285.148898]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2285.148900]  <EOI> 
[ 2285.148907]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2285.148912]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2285.148916]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2285.148919]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2285.148922]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2285.148925]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2285.148927] Code: e6 ed eb 0e bf 8e 21 00 00 48 83 c4 08 e9 e8 d1 19 00 48 83 c4 08 c3 90 40 88 f8 e6 70 e4 71 c3 40 88 f0 e6 70 40 88 f8 e6 71 c3 <0f> 31 89 c1 48 89 d0 48 c1 e0 20 89 c9 48 09 c8 c3 41 55 b2 0b 
[ 2285.148952] Call Trace:
[ 2285.148953]  <IRQ>  [<ffffffff811abe35>] ? paravirt_read_tsc+0x5/0x8
[ 2285.148958]  [<ffffffff811abee4>] ? delay_tsc+0x1d/0x68
[ 2285.148961]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2285.148963]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2285.148966]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2285.148969]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2285.148971]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2285.148974]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2285.148976]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2285.148979]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2285.148982]  [<ffffffff811a856d>] ? rb_insert_color+0x5f/0xd9
[ 2285.148985]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2285.148988]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2285.148991]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2285.148994]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2285.148996]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2285.148999]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2285.149002]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2285.149004]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2285.149007]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2285.149009]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2285.149012]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2285.149013]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2285.149022]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2285.149025]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2285.149028]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2285.149030]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2285.149033]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2285.149035] NMI backtrace for cpu 1
[ 2285.149036] CPU 1 
[ 2285.149038] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2285.149083] 
[ 2285.149085] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2285.149088] RIP: 0010:[<ffffffff811b76ff>]  [<ffffffff811b76ff>] swiotlb_tbl_map_single+0x5e/0x1e5
[ 2285.149094] RSP: 0018:ffff88015fd03910  EFLAGS: 00000207
[ 2285.149096] RAX: 00000000ffffffff RBX: ffff88015a925090 RCX: 000000000000004e
[ 2285.149098] RDX: ffff88015a925060 RSI: 000000009becb7ff RDI: ffff88015a925090
[ 2285.149100] RBP: 000000000000004e R08: 0000000000000001 R09: 0000000000000000
[ 2285.149102] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
[ 2285.149104] R13: 000000000000004e R14: 00000001000007ff R15: 000000000000004e
[ 2285.149106] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 2285.149108] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2285.149110] CR2: 00007fb1c26fd000 CR3: 0000000001603000 CR4: 00000000000006e0
[ 2285.149112] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2285.149114] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2285.149117] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 2285.149118] Stack:
[ 2285.149120]  ffff88015fd12800 ffff880100000000 0000000000137d96 000000000000004e
[ 2285.149123]  000000012fc868e2 0000000100000001 0000000000000036 ffff88015a925090
[ 2285.149127]  000000000000004e 0000000000000001 000000000000004e 0000000000000001
[ 2285.149130] Call Trace:
[ 2285.149131]  <IRQ> 
[ 2285.149134]  [<ffffffff811b7a52>] ? swiotlb_map_page+0x6e/0xe3
[ 2285.149137]  [<ffffffff811b79e4>] ? swiotlb_map_sg+0x10/0x10
[ 2285.149143]  [<ffffffffa01f4944>] ? dma_map_single_attrs.clone.46+0x5a/0x71 [r8169]
[ 2285.149149]  [<ffffffffa01f50c7>] ? rtl8169_start_xmit+0xc8/0x4af [r8169]
[ 2285.149153]  [<ffffffff8127538a>] ? skb_checksum+0x46/0x1ce
[ 2285.149157]  [<ffffffff8127ef6c>] ? dev_hard_start_xmit+0x3c3/0x4dc
[ 2285.149160]  [<ffffffff810720f0>] ? arch_local_irq_save+0x14/0x1d
[ 2285.149164]  [<ffffffff81295c7c>] ? sch_direct_xmit+0x60/0x134
[ 2285.149166]  [<ffffffff8127f33e>] ? dev_queue_xmit+0x2b9/0x461
[ 2285.149170]  [<ffffffff812a1bba>] ? ipv4_default_mtu+0x21/0x59
[ 2285.149174]  [<ffffffff812bba9e>] ? tcp_transmit_skb+0x724/0x757
[ 2285.149177]  [<ffffffff812b997f>] ? tcp_rcv_state_process+0x87f/0x8a4
[ 2285.149180]  [<ffffffff812bf9de>] ? tcp_v4_do_rcv+0x2db/0x32c
[ 2285.149183]  [<ffffffff812c19ec>] ? tcp_v4_rcv+0x419/0x66c
[ 2285.149186]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[ 2285.149190]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[ 2285.149193]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2285.149196]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2285.149199]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2285.149203]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2285.149206]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2285.149209]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2285.149213]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2285.149216]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2285.149218]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2285.149221]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2285.149223]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2285.149226]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2285.149227]  <EOI> 
[ 2285.149232]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2285.149237]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2285.149240]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2285.149243]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2285.149245]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2285.149249]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2285.149251] Code: 21 c6 49 be 00 00 00 00 00 00 20 00 48 81 c6 ff 07 00 00 48 89 74 24 10 48 c1 6c 24 10 0b 48 83 f8 ff 74 0b 4c 8d b0 00 08 00 00 
[ 2285.149268]  c1 ee 0b 4c 8b 6c 24 18 49 81 c5 ff 07 00 00 49 c1 ed 0b 48 
[ 2285.149277] Call Trace:
[ 2285.149278]  <IRQ>  [<ffffffff811b7a52>] ? swiotlb_map_page+0x6e/0xe3
[ 2285.149283]  [<ffffffff811b79e4>] ? swiotlb_map_sg+0x10/0x10
[ 2285.149287]  [<ffffffffa01f4944>] ? dma_map_single_attrs.clone.46+0x5a/0x71 [r8169]
[ 2285.149292]  [<ffffffffa01f50c7>] ? rtl8169_start_xmit+0xc8/0x4af [r8169]
[ 2285.149295]  [<ffffffff8127538a>] ? skb_checksum+0x46/0x1ce
[ 2285.149299]  [<ffffffff8127ef6c>] ? dev_hard_start_xmit+0x3c3/0x4dc
[ 2285.149302]  [<ffffffff810720f0>] ? arch_local_irq_save+0x14/0x1d
[ 2285.149305]  [<ffffffff81295c7c>] ? sch_direct_xmit+0x60/0x134
[ 2285.149307]  [<ffffffff8127f33e>] ? dev_queue_xmit+0x2b9/0x461
[ 2285.149310]  [<ffffffff812a1bba>] ? ipv4_default_mtu+0x21/0x59
[ 2285.149313]  [<ffffffff812bba9e>] ? tcp_transmit_skb+0x724/0x757
[ 2285.149315]  [<ffffffff812b997f>] ? tcp_rcv_state_process+0x87f/0x8a4
[ 2285.149318]  [<ffffffff812bf9de>] ? tcp_v4_do_rcv+0x2db/0x32c
[ 2285.149321]  [<ffffffff812c19ec>] ? tcp_v4_rcv+0x419/0x66c
[ 2285.149324]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[ 2285.149327]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[ 2285.149330]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2285.149333]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2285.149336]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2285.149340]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2285.149343]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2285.149346]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2285.149349]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2285.149351]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2285.149354]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2285.149356]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2285.149359]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2285.149361]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2285.149363]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2285.149372]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2285.149374]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2285.149377]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2285.149380]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2285.149382]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2353.269940] INFO: rcu_sched_state detected stalls on CPUs/tasks: { 1} (detected by 0, t=16968 jiffies)
[ 2353.269947] sending NMI to all CPUs:
[ 2353.269952] NMI backtrace for cpu 0
[ 2353.269954] CPU 0 
[ 2353.269955] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2353.270018] 
[ 2353.270020] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2353.270024] RIP: 0010:[<ffffffff811abe8f>]  [<ffffffff811abe8f>] __const_udelay+0x15/0x28
[ 2353.270031] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[ 2353.270033] RAX: 0000000001062560 RBX: 0000000000002710 RCX: 0000000000000003
[ 2353.270035] RDX: 000000000098371c RSI: 0000000000000200 RDI: 0000000000418958
[ 2353.270037] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 2353.270039] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 2353.270041] R13: ffffffff8161d900 R14: 0000000000000000 R15: ffffffff8161d900
[ 2353.270043] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 2353.270046] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2353.270047] CR2: 00007fc244a4c010 CR3: 0000000001603000 CR4: 00000000000006f0
[ 2353.270050] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2353.270052] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2353.270054] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 2353.270056] Stack:
[ 2353.270057]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096edb
[ 2353.270061]  ffff88015fc12800 0000000000000000 0000000000000000 0000000000000000
[ 2353.270064]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[ 2353.270067] Call Trace:
[ 2353.270069]  <IRQ> 
[ 2353.270074]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2353.270078]  [<ffffffff81096edb>] ? __rcu_pending+0x1f9/0x2ed
[ 2353.270081]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2353.270084]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2353.270088]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2353.270090]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2353.270094]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2353.270097]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2353.270100]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2353.270104]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2353.270107]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2353.270111]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2353.270114]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2353.270118]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2353.270120]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2353.270123]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2353.270126]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2353.270129]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2353.270131]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2353.270135]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2353.270136]  <EOI> 
[ 2353.270143]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2353.270148]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2353.270152]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2353.270155]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2353.270159]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2353.270162]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2353.270163] Code: fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 48 8d 04 bd 00 00 00 00 65 48 8b 14 25 58 27 01 00 
[ 2353.270180]  6b d2 3e 48 83 c4 08 f7 e2 48 8d 7a 01 e9 c7 ff ff ff 48 69 
[ 2353.270189] Call Trace:
[ 2353.270190]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2353.270196]  [<ffffffff81096edb>] ? __rcu_pending+0x1f9/0x2ed
[ 2353.270198]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2353.270201]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2353.270203]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2353.270206]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2353.270209]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2353.270212]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2353.270214]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2353.270217]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2353.270220]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2353.270223]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2353.270226]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2353.270228]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2353.270231]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2353.270234]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2353.270237]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2353.270239]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2353.270241]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2353.270244]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2353.270245]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2353.270254]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2353.270257]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2353.270260]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2353.270262]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2353.270265]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2353.270269] NMI backtrace for cpu 1
[ 2353.270271] CPU 1 
[ 2353.270272] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2353.270317] 
[ 2353.270319] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2353.270323] RIP: 0010:[<ffffffff8128c26c>]  [<ffffffff8128c26c>] load_pointer+0x12/0xa4
[ 2353.270328] RSP: 0018:ffff88015fd03c30  EFLAGS: 00000202
[ 2353.270329] RAX: 0000000000000154 RBX: ffff88015fd03c9c RCX: ffff88015fd03c9c
[ 2353.270331] RDX: 0000000000000002 RSI: 0000000000000024 RDI: ffff88012fc219c0
[ 2353.270334] RBP: 0000000000004000 R08: ffff88012fc219ee R09: ffff88012feb6440
[ 2353.270336] R10: ffff8801599d60c0 R11: 000000000000000d R12: ffff88013e8b2518
[ 2353.270338] R13: 0000000000000014 R14: ffff88012fc219c0 R15: ffff88015fd03c9c
[ 2353.270340] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 2353.270342] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2353.270344] CR2: 00007fc24493c010 CR3: 0000000001603000 CR4: 00000000000006e0
[ 2353.270346] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2353.270348] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2353.270351] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 2353.270352] Stack:
[ 2353.270354]  0000000000000010 ffffffff8128c458 0000000000000000 ffffffff812a3799
[ 2353.270357]  0000000000000400 00000000000007fe ffff8801539bc080 0000000000000401
[ 2353.270361]  0000000000000400 ffff880159404980 ffff88012fdd4062 ffff88012fdd404e
[ 2353.270364] Call Trace:
[ 2353.270365]  <IRQ> 
[ 2353.270368]  [<ffffffff8128c458>] ? sk_run_filter+0x15a/0x397
[ 2353.270372]  [<ffffffff812a3799>] ? ip_route_input_common+0x117/0xbac
[ 2353.270375]  [<ffffffff8128c6c1>] ? sk_filter+0x2c/0x6f
[ 2353.270378]  [<ffffffff812713d2>] ? sock_queue_rcv_skb+0x3e/0x158
[ 2353.270382]  [<ffffffff8131c2b5>] ? packet_rcv_spkt+0xbb/0xd4
[ 2353.270386]  [<ffffffff8127d091>] ? __netif_receive_skb+0x3a1/0x40b
[ 2353.270389]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2353.270392]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2353.270395]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2353.270401]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2353.270404]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2353.270407]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2353.270411]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2353.270414]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2353.270416]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2353.270419]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2353.270421]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2353.270424]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2353.270425]  <EOI> 
[ 2353.270430]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2353.270435]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2353.270438]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2353.270441]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2353.270444]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2353.270447]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2353.270449] Code: 89 ef e8 04 fc ff ff 48 83 c4 18 44 89 e8 5b 5d 41 5c 41 5d 41 5e 41 5f c3 85 f6 53 48 89 cb 78 2f 8b 47 68 2b 47 6c 29 f0 39 d0 <7c> 0c 48 63 de 48 03 9f e0 00 00 00 eb 7f 89 d1 48 89 da e8 ff 
[ 2353.270474] Call Trace:
[ 2353.270475]  <IRQ>  [<ffffffff8128c458>] ? sk_run_filter+0x15a/0x397
[ 2353.270480]  [<ffffffff812a3799>] ? ip_route_input_common+0x117/0xbac
[ 2353.270483]  [<ffffffff8128c6c1>] ? sk_filter+0x2c/0x6f
[ 2353.270486]  [<ffffffff812713d2>] ? sock_queue_rcv_skb+0x3e/0x158
[ 2353.270489]  [<ffffffff8131c2b5>] ? packet_rcv_spkt+0xbb/0xd4
[ 2353.270492]  [<ffffffff8127d091>] ? __netif_receive_skb+0x3a1/0x40b
[ 2353.270495]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2353.270497]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2353.270500]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2353.270505]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2353.270508]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2353.270511]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2353.270513]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2353.270516]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2353.270519]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2353.270521]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2353.270523]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2353.270526]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2353.270527]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2353.270536]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2353.270539]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2353.270542]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2353.270544]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2353.270547]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2669.886195] INFO: rcu_sched_state detected stall on CPU 0 (t=15287 jiffies)
[ 2669.886201] sending NMI to all CPUs:
[ 2669.886208] NMI backtrace for cpu 0
[ 2669.886211] CPU 0 
[ 2669.886214] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2669.886333] 
[ 2669.886335] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2669.886339] RIP: 0010:[<ffffffff811abe7e>]  [<ffffffff811abe7e>] __const_udelay+0x4/0x28
[ 2669.886346] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[ 2669.886348] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000003
[ 2669.886350] RDX: ffffffff81684078 RSI: 0000000000000200 RDI: 0000000000418958
[ 2669.886352] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 2669.886354] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 2669.886356] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 2669.886358] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 2669.886361] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2669.886362] CR2: 00007fc104b71000 CR3: 0000000001603000 CR4: 00000000000006f0
[ 2669.886365] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2669.886367] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2669.886369] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 2669.886371] Stack:
[ 2669.886372]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64
[ 2669.886376]  ffff88015fc12800 0000000000000000 0000000000000000 0000000000000000
[ 2669.886379]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[ 2669.886382] Call Trace:
[ 2669.886384]  <IRQ> 
[ 2669.886389]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2669.886393]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2669.886396]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2669.886399]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2669.886402]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2669.886405]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2669.886409]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2669.886412]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2669.886416]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2669.886419]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2669.886422]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2669.886426]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2669.886429]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2669.886432]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2669.886435]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2669.886438]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2669.886440]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2669.886443]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2669.886447]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2669.886448]  <EOI> 
[ 2669.886455]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2669.886460]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2669.886464]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2669.886467]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2669.886471]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2669.886473]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2669.886475] Code: 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 
[ 2669.886492]  8d 04 bd 00 00 00 00 65 48 8b 14 25 58 27 01 00 48 6b d2 3e 
[ 2669.886501] Call Trace:
[ 2669.886502]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2669.886507]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2669.886510]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2669.886513]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2669.886515]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2669.886518]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2669.886521]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2669.886524]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2669.886527]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2669.886529]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2669.886532]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2669.886535]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2669.886538]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2669.886540]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2669.886543]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2669.886546]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2669.886548]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2669.886551]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2669.886553]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2669.886555]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2669.886563]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2669.886566]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2669.886569]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2669.886572]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2669.886574]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2669.886577] NMI backtrace for cpu 1
[ 2669.886579] CPU 1 
[ 2669.886580] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2669.886625] 
[ 2669.886627] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2669.886631] RIP: 0010:[<ffffffff812c4ac3>]  [<ffffffff812c4ac3>] atomic_dec_and_test+0x3/0xf
[ 2669.886636] RSP: 0018:ffff88015fd03b38  EFLAGS: 00000202
[ 2669.886638] RAX: 0000000000000000 RBX: ffff880156696700 RCX: 0000000000000000
[ 2669.886641] RDX: 0000000000020001 RSI: 0000000000000016 RDI: ffff88015669674c
[ 2669.886643] RBP: 0000000000000001 R08: 00000000000000c3 R09: ffff880143613ad8
[ 2669.886645] R10: ffff8801599d60c0 R11: 0000000000000000 R12: ffff88015fd03b78
[ 2669.886647] R13: ffff8801462babc0 R14: 0000000000000001 R15: ffff88015fd03b78
[ 2669.886649] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 2669.886651] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2669.886653] CR2: 00007f04ef095fc0 CR3: 00000001435c0000 CR4: 00000000000006e0
[ 2669.886655] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2669.886657] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2669.886660] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 2669.886661] Stack:
[ 2669.886663]  ffffffff812c5a08 0000000000000001 ffffffff812c770d 0000000000000002
[ 2669.886666]  ffff88012fc33d10 0000000000003908 faffffef0101a8c0 ffff880156696700
[ 2669.886670]  ffff88012fc35480 0000000000000286 ffff88012fe26862 0000000000000000
[ 2669.886673] Call Trace:
[ 2669.886675]  <IRQ> 
[ 2669.886677]  [<ffffffff812c5a08>] ? sock_put+0xd/0x1c
[ 2669.886680]  [<ffffffff812c770d>] ? __udp4_lib_mcast_deliver+0x147/0x169
[ 2669.886685]  [<ffffffff810ed5ba>] ? kmem_cache_free+0x2d/0x69
[ 2669.886688]  [<ffffffff812b47eb>] ? tcp_data_snd_check+0x3b/0x104
[ 2669.886691]  [<ffffffff812b94cb>] ? tcp_rcv_state_process+0x3cb/0x8a4
[ 2669.886694]  [<ffffffff812bf9de>] ? tcp_v4_do_rcv+0x2db/0x32c
[ 2669.886697]  [<ffffffff8128c458>] ? sk_run_filter+0x15a/0x397
[ 2669.886701]  [<ffffffff812a3799>] ? ip_route_input_common+0x117/0xbac
[ 2669.886704]  [<ffffffff812c7974>] ? __udp4_lib_rcv+0x245/0x46d
[ 2669.886707]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[ 2669.886711]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[ 2669.886714]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[ 2669.886717]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2669.886720]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2669.886723]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2669.886729]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2669.886732]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2669.886735]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2669.886739]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2669.886742]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2669.886744]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2669.886747]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2669.886749]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2669.886752]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2669.886753]  <EOI> 
[ 2669.886758]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2669.886763]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[ 2669.886766]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2669.886768]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2669.886771]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2669.886775]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2669.886777] Code: 85 ed b8 00 00 00 00 4c 0f 44 e0 31 c0 4d 85 e4 0f 95 c0 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f c3 90 90 f0 ff 07 c3 f0 ff 0f <0f> 94 c0 84 c0 0f 95 c0 0f b6 c0 c3 8d 14 11 c1 e2 08 41 01 f0 
[ 2669.886802] Call Trace:
[ 2669.886803]  <IRQ>  [<ffffffff812c5a08>] ? sock_put+0xd/0x1c
[ 2669.886807]  [<ffffffff812c770d>] ? __udp4_lib_mcast_deliver+0x147/0x169
[ 2669.886810]  [<ffffffff810ed5ba>] ? kmem_cache_free+0x2d/0x69
[ 2669.886813]  [<ffffffff812b47eb>] ? tcp_data_snd_check+0x3b/0x104
[ 2669.886816]  [<ffffffff812b94cb>] ? tcp_rcv_state_process+0x3cb/0x8a4
[ 2669.886819]  [<ffffffff812bf9de>] ? tcp_v4_do_rcv+0x2db/0x32c
[ 2669.886821]  [<ffffffff8128c458>] ? sk_run_filter+0x15a/0x397
[ 2669.886824]  [<ffffffff812a3799>] ? ip_route_input_common+0x117/0xbac
[ 2669.886826]  [<ffffffff812c7974>] ? __udp4_lib_rcv+0x245/0x46d
[ 2669.886830]  [<ffffffff812a5e24>] ? ip_local_deliver_finish+0x14b/0x1bb
[ 2669.886833]  [<ffffffff8127d0c7>] ? __netif_receive_skb+0x3d7/0x40b
[ 2669.886835]  [<ffffffff8103f092>] ? try_to_wake_up+0x187/0x199
[ 2669.886838]  [<ffffffff8127db83>] ? netif_receive_skb+0x52/0x58
[ 2669.886841]  [<ffffffff8127e075>] ? napi_gro_receive+0x1f/0x2f
[ 2669.886844]  [<ffffffff8127dc5a>] ? napi_skb_finish+0x1c/0x31
[ 2669.886848]  [<ffffffffa01f4cc8>] ? rtl8169_poll+0x2a2/0x454 [r8169]
[ 2669.886851]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2669.886854]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2669.886857]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2669.886860]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2669.886862]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2669.886865]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2669.886867]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2669.886870]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2669.886871]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2669.886880]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[ 2669.886882]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2669.886885]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2669.886888]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2669.886890]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2736.561608] INFO: rcu_sched_state detected stall on CPU 1 (t=16608 jiffies)
[ 2736.561615] sending NMI to all CPUs:
[ 2736.561623] NMI backtrace for cpu 1
[ 2736.561626] CPU 1 
[ 2736.561628] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2736.561742] 
[ 2736.561746] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2736.561759] RIP: 0010:[<ffffffff811abe69>]  [<ffffffff811abe69>] delay_loop+0x31/0x31
[ 2736.561772] RSP: 0018:ffff88015fd03d10  EFLAGS: 00000893
[ 2736.561774] RAX: 0000000086495080 RBX: 0000000000002710 RCX: 0000000000000003
[ 2736.561776] RDX: 000000000025bf43 RSI: 0000000000000200 RDI: 000000000025bf44
[ 2736.561778] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 2736.561780] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 2736.561782] R13: ffff88015fd03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 2736.561785] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 2736.561787] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2736.561789] CR2: 00007fc24479c010 CR3: 0000000159c93000 CR4: 00000000000006e0
[ 2736.561791] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2736.561793] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2736.561795] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 2736.561797] Stack:
[ 2736.561798]  ffffffff8101ffa1 ffff88015fd0ecf0 ffffffff81096d64 ffff88015fd12800
[ 2736.561802]  0000000000000001 0000000000000000 0000000000000001 ffff88015fd03e18
[ 2736.561805]  0000000000000001 ffffffff8106d090 ffffffff81097365 ffff88015af780c0
[ 2736.561809] Call Trace:
[ 2736.561810]  <IRQ> 
[ 2736.561815]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2736.561819]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2736.561823]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2736.561825]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2736.561829]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2736.561831]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2736.561835]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2736.561838]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2736.561843]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2736.561845]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2736.561849]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2736.561852]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2736.561856]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2736.561859]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2736.561862]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2736.561865]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2736.561867]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2736.561870]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2736.561873]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2736.561875]  <EOI> 
[ 2736.561882]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2736.561887]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[ 2736.561891]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2736.561894]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2736.561897]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2736.561900]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2736.561902] Code: 74 25 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 
[ 2736.561919]  83 ec 08 48 8b 05 7c 13 49 00 48 83 c4 08 ff e0 48 83 ec 08 
[ 2736.561928] Call Trace:
[ 2736.561929]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2736.561934]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2736.561937]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2736.561939]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2736.561942]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2736.561945]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2736.561947]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2736.561950]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2736.561953]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2736.561956]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2736.561959]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2736.561962]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2736.561965]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2736.561967]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2736.561970]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2736.561973]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2736.561975]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2736.561977]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2736.561980]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2736.561981]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2736.561990]  [<ffffffffa01730c1>] ? acpi_idle_enter_simple+0xbe/0xf4 [processor]
[ 2736.561993]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2736.561995]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2736.561998]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2736.562001]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2736.562004] NMI backtrace for cpu 0
[ 2736.562006] CPU 0 
[ 2736.562007] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2736.562052] 
[ 2736.562054] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2736.562058] RIP: 0010:[<ffffffff811b734e>]  [<ffffffff811b734e>] swiotlb_bounce+0x2e/0x31
[ 2736.562063] RSP: 0018:ffff88015fc03df8  EFLAGS: 00010202
[ 2736.562065] RAX: ffff88009d1d3000 RBX: ffff8801596e0000 RCX: 000000000000049f
[ 2736.562067] RDX: 00000000000004a0 RSI: ffff88009d1d3001 RDI: ffff880137588001
[ 2736.562069] RBP: ffff8801596e0740 R08: ffff880137588000 R09: ffff88015ff43000
[ 2736.562071] R10: 0000000000012800 R11: 0000000000003246 R12: ffff880037c2ef50
[ 2736.562073] R13: 00000000340284a4 R14: ffff880159404880 R15: 000000000000e5f5
[ 2736.562076] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 2736.562078] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2736.562080] CR2: 00007fb196fea7d8 CR3: 0000000001603000 CR4: 00000000000006f0
[ 2736.562082] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2736.562084] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2736.562086] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 2736.562088] Stack:
[ 2736.562089]  ffffffffa01f4bc3 ffff88015fc15800 00000000000004a0 ffff880137588000
[ 2736.562093]  ffff8801596e0758 ffff88015a925090 000004a05fc0eaf0 000000400000003f
[ 2736.562096]  ffffc90000642000 000000009d1d3000 ffff8801596e0758 ffffffff81279894
[ 2736.562100] Call Trace:
[ 2736.562101]  <IRQ> 
[ 2736.562107]  [<ffffffffa01f4bc3>] ? rtl8169_poll+0x19d/0x454 [r8169]
[ 2736.562111]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2736.562115]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2736.562119]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2736.562122]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2736.562125]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2736.562128]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2736.562130]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2736.562133]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2736.562135]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2736.562137]  <EOI> 
[ 2736.562142]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2736.562147]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2736.562150]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2736.562152]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2736.562155]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2736.562158]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2736.562160] Code: 89 f0 75 13 48 be 00 00 00 00 00 88 ff ff 48 8d 34 37 48 89 c7 eb 11 49 b8 00 00 00 00 00 88 ff ff 4e 8d 04 07 4c 89 c7 48 89 d1 <f3> a4 c3 48 89 f0 48 2b 05 8d b4 62 00 4c 8b 0d 8e b4 62 00 48 
[ 2736.562185] Call Trace:
[ 2736.562186]  <IRQ>  [<ffffffffa01f4bc3>] ? rtl8169_poll+0x19d/0x454 [r8169]
[ 2736.562193]  [<ffffffff81279894>] ? arch_local_irq_save+0x12/0x1b
[ 2736.562196]  [<ffffffff8127e1a0>] ? net_rx_action+0xa4/0x1b2
[ 2736.562199]  [<ffffffff8104be44>] ? __do_softirq+0xb9/0x178
[ 2736.562201]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2736.562204]  [<ffffffff8133d2dc>] ? call_softirq+0x1c/0x30
[ 2736.562207]  [<ffffffff8100a9ef>] ? do_softirq+0x3f/0x84
[ 2736.562209]  [<ffffffff8104c0b0>] ? irq_exit+0x3f/0xa3
[ 2736.562212]  [<ffffffff8100a71b>] ? do_IRQ+0x85/0x9e
[ 2736.562214]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2736.562216]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2736.562224]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2736.562227]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2736.562230]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2736.562233]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2736.562235]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2991.259780] INFO: rcu_sched_state detected stall on CPU 0 (t=15992 jiffies)
[ 2991.259784] sending NMI to all CPUs:
[ 2991.259788] NMI backtrace for cpu 0
[ 2991.259790] CPU 0 
[ 2991.259791] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2991.259854] 
[ 2991.259856] Pid: 0, comm: swapper Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2991.259860] RIP: 0010:[<ffffffff811abe74>]  [<ffffffff811abe74>] __delay+0xb/0x11
[ 2991.259866] RSP: 0018:ffff88015fc03d08  EFLAGS: 00000092
[ 2991.259868] RAX: ffffffff811abec7 RBX: 0000000000002710 RCX: 0000000000000003
[ 2991.259870] RDX: 000000000025bfea RSI: 0000000000000200 RDI: 000000000025bfeb
[ 2991.259872] RBP: ffffffff8161b800 R08: 0000000000000000 R09: 00000000fffffffe
[ 2991.259874] R10: 0000000000000000 R11: 0000000000000293 R12: ffffffff8161b900
[ 2991.259877] R13: ffff88015fc03e18 R14: 0000000000000001 R15: ffffffff8106d090
[ 2991.259879] FS:  0000000000000000(0000) GS:ffff88015fc00000(0000) knlGS:0000000000000000
[ 2991.259881] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2991.259883] CR2: 00007fb1c26fd000 CR3: 0000000001603000 CR4: 00000000000006f0
[ 2991.259885] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2991.259887] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2991.259890] Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8160b020)
[ 2991.259891] Stack:
[ 2991.259893]  0000000000000096 ffffffff8101ffa1 ffff88015fc0ecf0 ffffffff81096d64
[ 2991.259896]  ffff8801402c8e40 0000000000000000 0000000000000000 0000000000000000
[ 2991.259900]  ffff88015fc03e18 0000000000000001 ffffffff8106d090 ffffffff81097365
[ 2991.259903] Call Trace:
[ 2991.259905]  <IRQ> 
[ 2991.259910]  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2991.259914]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2991.259917]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2991.259920]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2991.259923]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2991.259926]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2991.259930]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2991.259933]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2991.259936]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.259940]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2991.259943]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2991.259947]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2991.259950]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2991.259954]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2991.259956]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.259959]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2991.259962]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2991.259965]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2991.259967]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2991.259970]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2991.259972]  <EOI> 
[ 2991.259979]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2991.259984]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2991.259988]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.259991]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.259995]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2991.259997]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2991.259999] Code: 1f 84 00 00 00 00 00 eb 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 c3 48 83 ec 08 48 8b 05 7c 13 49 00 
[ 2991.260016]  83 c4 08 ff e0 48 83 ec 08 48 8d 04 bd 00 00 00 00 65 48 8b 
[ 2991.260025] Call Trace:
[ 2991.260026]  <IRQ>  [<ffffffff8101ffa1>] ? arch_trigger_all_cpu_backtrace+0x6c/0x7b
[ 2991.260031]  [<ffffffff81096d64>] ? __rcu_pending+0x82/0x2ed
[ 2991.260034]  [<ffffffff8106d090>] ? tick_nohz_handler+0xd0/0xd0
[ 2991.260037]  [<ffffffff81097365>] ? rcu_check_callbacks+0x7e/0xa9
[ 2991.260039]  [<ffffffff81053372>] ? update_process_times+0x31/0x63
[ 2991.260042]  [<ffffffff8106d0fa>] ? tick_sched_timer+0x6a/0x90
[ 2991.260045]  [<ffffffff81062e12>] ? __run_hrtimer+0xaf/0x13a
[ 2991.260047]  [<ffffffff810635a3>] ? hrtimer_interrupt+0xd6/0x19a
[ 2991.260050]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.260053]  [<ffffffff8106c389>] ? tick_do_broadcast+0x3f/0x83
[ 2991.260056]  [<ffffffff8106c49c>] ? tick_handle_oneshot_broadcast+0xcf/0x103
[ 2991.260059]  [<ffffffff8100afe8>] ? timer_interrupt+0x18/0x22
[ 2991.260061]  [<ffffffff81092746>] ? handle_irq_event_percpu+0x50/0x184
[ 2991.260064]  [<ffffffff8100e28d>] ? paravirt_read_tsc+0x5/0x8
[ 2991.260067]  [<ffffffff810671a7>] ? timekeeping_get_ns+0xd/0x2a
[ 2991.260069]  [<ffffffff810928ae>] ? handle_irq_event+0x34/0x52
[ 2991.260072]  [<ffffffff8109481a>] ? handle_edge_irq+0x9f/0xc6
[ 2991.260075]  [<ffffffff8100a9aa>] ? handle_irq+0x1a/0x20
[ 2991.260077]  [<ffffffff8100a6db>] ? do_IRQ+0x45/0x9e
[ 2991.260080]  [<ffffffff813371d3>] ? common_interrupt+0x13/0x13
[ 2991.260081]  <EOI>  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2991.260090]  [<ffffffffa0172fcb>] ? acpi_idle_enter_bm+0x218/0x250 [processor]
[ 2991.260093]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.260095]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.260098]  [<ffffffff8169fb65>] ? start_kernel+0x3bd/0x3c8
[ 2991.260101]  [<ffffffff8169f3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 2991.260103] NMI backtrace for cpu 1
[ 2991.260105] CPU 1 
[ 2991.260107] Modules linked in: parport_pc ppdev lp parport rfcomm bnep nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ext3 jbd loop firewire_sbp2 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec arc4 btusb bluetooth snd_hwdep snd_pcm iwlagn sg snd_seq snd_timer snd_seq_device ir_lirc_codec lirc_dev nouveau mac80211 cfg80211 i2c_i801 ttm firewire_ohci sdhci_pci drm_kms_helper drm uhci_hcd sr_mod snd ir_sony_decoder i2c_algo_bit r8169 soundcore ehci_hcd usbcore cdrom snd_page_alloc joydev mii rfkill sdhci mmc_core i2c_core mxm_wmi firewire_core ir_jvc_decoder battery ac button processor video ir_rc6_decoder evdev crc_itu_t wmi ir_rc5_decoder rc_rc6_mce ir_nec_decoder pcspkr container ite_cir rc_core power_supply psmouse serio_raw ext4 mbcache jbd2 crc16 sd_mod crc
 _t10dif ata_generic thermal thermal_sys ata_piix libata scsi_mod
[ 2991.260152] 
[ 2991.260154] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-2-amd64 #1 Clevo Co. M570RU/SANTA ROSA
[ 2991.260158] RIP: 0010:[<ffffffff81336e31>]  [<ffffffff81336e31>] _raw_spin_lock_irqsave+0x1e/0x25
[ 2991.260162] RSP: 0018:ffff88015af87d78  EFLAGS: 00000097
[ 2991.260164] RAX: 0000000000000092 RBX: ffffffff8177c8b0 RCX: 000000000000835b
[ 2991.260166] RDX: 000000000000835c RSI: 0000000000000005 RDI: ffffffff8177c8b0
[ 2991.260168] RBP: ffff88015fd0dd00 R08: 0000000000000000 R09: 0000000000000011
[ 2991.260170] R10: dead000000100100 R11: 0000000000003311 R12: 0000000000000001
[ 2991.260172] R13: ffffffff81611200 R14: 0000000000000005 R15: 0000000000000001
[ 2991.260175] FS:  0000000000000000(0000) GS:ffff88015fd00000(0000) knlGS:0000000000000000
[ 2991.260177] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2991.260179] CR2: 000000000184e730 CR3: 0000000001603000 CR4: 00000000000006e0
[ 2991.260181] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2991.260183] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2991.260185] Process kworker/0:0 (pid: 0, threadinfo ffff88015af86000, task ffff88015af780c0)
[ 2991.260187] Stack:
[ 2991.260188]  ffff88015983180c ffffffff8106c861 ffff88015983180c 0000000000000001
[ 2991.260192]  00000000ffffffff 0000000000000000 0000000000000180 ffffffff8106c1d3
[ 2991.260195]  0000000000000180 ffffffff811fd2c1 ffff88015fd0eaf0 ffff88015983180c
[ 2991.260199] Call Trace:
[ 2991.260202]  [<ffffffff8106c861>] ? tick_broadcast_oneshot_control+0x54/0x110
[ 2991.260205]  [<ffffffff8106c1d3>] ? tick_notify+0x210/0x365
[ 2991.260208]  [<ffffffff811fd2c1>] ? acpi_hw_read+0x4d/0x54
[ 2991.260211]  [<ffffffff81339ee3>] ? notifier_call_chain+0x2e/0x5b
[ 2991.260214]  [<ffffffff8106b930>] ? clockevents_notify+0x2a/0x13b
[ 2991.260220]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2991.260225]  [<ffffffffa0172ff1>] ? acpi_idle_enter_bm+0x23e/0x250 [processor]
[ 2991.260227]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.260230]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.260233]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2991.260237]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5
[ 2991.260239] Code: c0 0f 95 c0 0f b6 c0 c3 e9 0d b3 d3 ff 53 48 89 fb e8 c0 b2 d3 ff ba 00 00 01 00 f0 0f c1 13 0f b7 ca c1 ea 10 39 d1 74 07 f3 90 <0f> b7 0b eb f5 5b c3 48 83 ec 08 48 89 3c 24 e8 8f b2 d3 ff 48 
[ 2991.260264] Call Trace:
[ 2991.260266]  [<ffffffff8106c861>] ? tick_broadcast_oneshot_control+0x54/0x110
[ 2991.260269]  [<ffffffff8106c1d3>] ? tick_notify+0x210/0x365
[ 2991.260272]  [<ffffffff811fd2c1>] ? acpi_hw_read+0x4d/0x54
[ 2991.260275]  [<ffffffff81339ee3>] ? notifier_call_chain+0x2e/0x5b
[ 2991.260278]  [<ffffffff8106b930>] ? clockevents_notify+0x2a/0x13b
[ 2991.260282]  [<ffffffffa0172400>] ? arch_local_irq_enable+0x4/0x8 [processor]
[ 2991.260287]  [<ffffffffa0172ff1>] ? acpi_idle_enter_bm+0x23e/0x250 [processor]
[ 2991.260290]  [<ffffffff81265ce4>] ? cpuidle_idle_call+0xf5/0x180
[ 2991.260292]  [<ffffffff8100827e>] ? cpu_idle+0xa2/0xc4
[ 2991.260295]  [<ffffffff810720ce>] ? arch_local_irq_restore+0x2/0x8
[ 2991.260298]  [<ffffffff8132fc18>] ? start_secondary+0x1de/0x1e5

--nextPart1703242.9C23h8g3pK
Content-Disposition: attachment; filename="config"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-mpsub; charset="UTF-8"; name="config"

#
# Automatically generated make config: don't edit
# Linux/x86 3.0.0 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_FHANDLE=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_DISABLED=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
# CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_PERF_COUNTERS is not set
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=m
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_INLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
CONFIG_INLINE_READ_UNLOCK=y
# CONFIG_INLINE_READ_UNLOCK_BH is not set
CONFIG_INLINE_READ_UNLOCK_IRQ=y
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
CONFIG_INLINE_WRITE_UNLOCK=y
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=128
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_DEBUG is not set
CONFIG_KVM_CLOCK=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_CMPXCHG=y
CONFIG_CMPXCHG_LOCAL=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_IOMMU_API=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
# CONFIG_CLEANCACHE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_EFI=y
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_CAN_PM_TRACE=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=m
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=m
CONFIG_ACPI_HOTPLUG_MEMORY=m
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=m
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=m
CONFIG_ACPI_APEI_PCIEAER=y
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=m
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=m
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_SPEEDSTEP_CENTRINO=m
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=m

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_DMAR=y
# CONFIG_DMAR_DEFAULT_ON is not set
CONFIG_DMAR_FLOPPY_WA=y
CONFIG_INTR_REMAP=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=m
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_STUB=m
CONFIG_XEN_PCIDEV_FRONTEND=m
CONFIG_HT_IRQ=y
CONFIG_PCI_IOV=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=m
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
CONFIG_I82092=m
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=m
CONFIG_HOTPLUG_PCI_FAKE=m
CONFIG_HOTPLUG_PCI_ACPI=m
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=m
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=m
CONFIG_HOTPLUG_PCI_SHPC=m
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=m
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_LRO=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CT_PROTO_DCCP=m
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=m
CONFIG_NF_CT_PROTO_UDPLITE=m
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NETFILTER_TPROXY=m
CONFIG_NETFILTER_XTABLES=m

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_SOCKET=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
CONFIG_IP_SET_HASH_NET=m
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_DCCP=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PROTO_UDPLITE=m
CONFIG_NF_NAT_PROTO_SCTP=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
CONFIG_IP6_NF_QUEUE=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_TARGET_LOG=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=m
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_ULOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_NET_DCCPPROBE=m
CONFIG_IP_SCTP=m
CONFIG_NET_SCTPPROBE=m
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_RDS=m
CONFIG_RDS_RDMA=m
CONFIG_RDS_TCP=m
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=m
CONFIG_TIPC_ADVANCED=y
CONFIG_TIPC_PORTS=8191
CONFIG_TIPC_LOG=0
# CONFIG_TIPC_DEBUG is not set
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
CONFIG_ATM_MPOA=m
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_DECNET=m
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=m
CONFIG_IPX=m
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=m
CONFIG_DEV_APPLETALK=m
CONFIG_IPDDP=m
CONFIG_IPDDP_ENCAP=y
CONFIG_IPDDP_DECAP=y
# CONFIG_X25 is not set
CONFIG_LAPB=m
# CONFIG_ECONET is not set
CONFIG_WAN_ROUTER=m
CONFIG_PHONET=m
CONFIG_IEEE802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_INGRESS=m

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=m
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_HAVE_BPF_JIT=y
CONFIG_BPF_JIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=m
# CONFIG_AX25_DAMA_SLAVE is not set
CONFIG_NETROM=m
CONFIG_ROSE=m

#
# AX.25 network device drivers
#
CONFIG_MKISS=m
CONFIG_6PACK=m
CONFIG_BPQETHER=m
CONFIG_BAYCOM_SER_FDX=m
CONFIG_BAYCOM_SER_HDX=m
CONFIG_BAYCOM_PAR=m
CONFIG_YAM=m
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
CONFIG_CAN_SLCAN=m
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_MCP251X=m
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=m
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCI=m
CONFIG_CAN_KVASER_PCI=m
CONFIG_CAN_PLX_PCI=m
# CONFIG_CAN_C_CAN is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=m
CONFIG_CAN_ESD_USB2=m
CONFIG_CAN_SOFTING=m
CONFIG_CAN_SOFTING_CS=m
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=m

#
# IrDA protocols
#
CONFIG_IRLAN=m
CONFIG_IRNET=m
CONFIG_IRCOMM=m
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=m

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=m
CONFIG_ACTISYS_DONGLE=m
CONFIG_TEKRAM_DONGLE=m
CONFIG_TOIM3232_DONGLE=m
CONFIG_LITELINK_DONGLE=m
CONFIG_MA600_DONGLE=m
CONFIG_GIRBIL_DONGLE=m
CONFIG_MCP2120_DONGLE=m
CONFIG_OLD_BELKIN_DONGLE=m
CONFIG_ACT200L_DONGLE=m
CONFIG_KINGSUN_DONGLE=m
CONFIG_KSDAZZLE_DONGLE=m
CONFIG_KS959_DONGLE=m

#
# FIR device drivers
#
CONFIG_USB_IRDA=m
CONFIG_SIGMATEL_FIR=m
CONFIG_NSC_FIR=m
CONFIG_WINBOND_FIR=m
CONFIG_SMC_IRCC_FIR=m
CONFIG_ALI_FIR=m
CONFIG_VLSI_FIR=m
CONFIG_VIA_FIR=m
CONFIG_MCS_FIR=m
CONFIG_BT=m
CONFIG_BT_L2CAP=y
CONFIG_BT_SCO=y
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_CMTP=m
CONFIG_BT_HIDP=m

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=m
CONFIG_BT_HCIBTSDIO=m
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=m
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIDTL1=m
CONFIG_BT_HCIBT3C=m
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
CONFIG_BT_HCIVHCI=m
CONFIG_BT_MRVL=m
CONFIG_BT_MRVL_SDIO=m
CONFIG_BT_ATH3K=m
CONFIG_BT_WILINK=m
CONFIG_AF_RXRPC=m
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=m
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
# CONFIG_WIRELESS_EXT_SYSFS is not set
CONFIG_LIB80211=m
CONFIG_LIB80211_CRYPT_WEP=m
CONFIG_LIB80211_CRYPT_CCMP=m
CONFIG_LIB80211_CRYPT_TKIP=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=m
CONFIG_NET_9P_VIRTIO=m
CONFIG_NET_9P_RDMA=m
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=m
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_CONNECTOR=m
CONFIG_MTD=m
# CONFIG_MTD_DEBUG is not set
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=m
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
CONFIG_SSFDC=m
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=m
CONFIG_MTD_SWAP=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=m
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_SC520CDP=m
CONFIG_MTD_NETSC520=m
CONFIG_MTD_TS5500=m
CONFIG_MTD_SBC_GXX=m
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
CONFIG_MTD_NETtel=m
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=m
CONFIG_MTD_PCMCIA=m
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
# CONFIG_MTD_GPIO_ADDR is not set
CONFIG_MTD_INTEL_VR_NOR=m
CONFIG_MTD_PLATRAM=m
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=m
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=m
CONFIG_M25PXX_USE_FAST_READ=y
CONFIG_MTD_SST25L=m
CONFIG_MTD_SLRAM=m
CONFIG_MTD_PHRAM=m
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOC2000=m
CONFIG_MTD_DOC2001=m
CONFIG_MTD_DOC2001PLUS=m
CONFIG_MTD_DOCPROBE=m
CONFIG_MTD_DOCECC=m
# CONFIG_MTD_DOCPROBE_ADVANCED is not set
CONFIG_MTD_DOCPROBE_ADDRESS=0
CONFIG_MTD_NAND_ECC=m
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=m
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=m
CONFIG_MTD_NAND_RICOH=m
CONFIG_MTD_NAND_DISKONCHIP=m
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_PLATFORM=m
CONFIG_MTD_ALAUDA=m
CONFIG_MTD_ONENAND=m
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=m
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=m

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_RESERVE=1
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_DEBUG is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=m
CONFIG_PARIDE_BPCK=m
CONFIG_PARIDE_COMM=m
CONFIG_PARIDE_DSTR=m
CONFIG_PARIDE_FIT2=m
CONFIG_PARIDE_FIT3=m
CONFIG_PARIDE_EPAT=m
# CONFIG_PARIDE_EPATC8 is not set
CONFIG_PARIDE_EPIA=m
CONFIG_PARIDE_FRIQ=m
CONFIG_PARIDE_FRPW=m
CONFIG_PARIDE_KBIC=m
CONFIG_PARIDE_KTTI=m
CONFIG_PARIDE_ON20=m
CONFIG_PARIDE_ON26=m
CONFIG_BLK_CPQ_DA=m
CONFIG_BLK_CPQ_CISS_DA=m
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=m
CONFIG_BLK_DEV_UMEM=m
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
CONFIG_BLK_DEV_DRBD=m
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=m
CONFIG_BLK_DEV_OSD=m
CONFIG_BLK_DEV_SX8=m
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
CONFIG_XEN_BLKDEV_BACKEND=m
CONFIG_VIRTIO_BLK=m
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=m
CONFIG_SENSORS_LIS3LV02D=m
CONFIG_MISC_DEVICES=y
CONFIG_AD525X_DPOT=m
CONFIG_AD525X_DPOT_I2C=m
CONFIG_AD525X_DPOT_SPI=m
CONFIG_IBM_ASM=m
CONFIG_PHANTOM=m
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_HP_ILO=m
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1780=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
CONFIG_HMC6352=m
CONFIG_DS1682=m
CONFIG_TI_DAC7512=m
CONFIG_VMWARE_BALLOON=m
CONFIG_BMP085=m
# CONFIG_PCH_PHUB is not set
CONFIG_C2PORT=m
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
CONFIG_EEPROM_AT25=m
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y
CONFIG_IWMC3200TOP=m
# CONFIG_IWMC3200TOP_DEBUG is not set
# CONFIG_IWMC3200TOP_DEBUGFS is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=m
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_HAVE_IDE=y
CONFIG_IDE=m

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=m
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_DELKIN=m
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=m
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=m
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=m
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=m
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
CONFIG_BLK_DEV_HPT366=m
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
CONFIG_BLK_DEV_IT8172=m
CONFIG_BLK_DEV_IT8213=m
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=m
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=m
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
CONFIG_BLK_DEV_3W_XXXX_RAID=m
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
CONFIG_SCSI_ACARD=m
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=8
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=m
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=m
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ARCMSR_AER is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=m
CONFIG_MEGARAID_MAILBOX=m
CONFIG_MEGARAID_LEGACY=m
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
CONFIG_SCSI_HPTIOP=m
CONFIG_SCSI_BUSLOGIC=m
CONFIG_VMWARE_PVSCSI=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
CONFIG_SCSI_DMX3191D=m
CONFIG_SCSI_EATA=m
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=m
CONFIG_SCSI_GDTH=m
CONFIG_SCSI_ISCI=m
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
CONFIG_SCSI_INIA100=m
CONFIG_SCSI_PPA=m
CONFIG_SCSI_IMM=m
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=m
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=m
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
# CONFIG_SCSI_LPFC_DEBUG_FS is not set
CONFIG_SCSI_DC395x=m
CONFIG_SCSI_DC390T=m
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
CONFIG_SCSI_SRP=m
CONFIG_SCSI_BFA_FC=m
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
CONFIG_PCMCIA_FDOMAIN=m
CONFIG_PCMCIA_QLOGIC=m
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=m
CONFIG_SCSI_DH_RDAC=m
CONFIG_SCSI_DH_HP_SW=m
CONFIG_SCSI_DH_EMC=m
CONFIG_SCSI_DH_ALUA=m
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=m
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARASAN_CF=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
CONFIG_PATA_CS5520=m
CONFIG_PATA_CS5530=m
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
CONFIG_PATA_EFAR=m
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87415=m
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SC1200=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
CONFIG_PATA_TRIFLEX=m
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=m
CONFIG_PATA_NS87410=m
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=m
CONFIG_PATA_RZ1000=m

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=m
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
CONFIG_DM_RAID=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
CONFIG_LOOPBACK_TARGET=m
# CONFIG_LOOPBACK_TARGET_CDB_DEBUG is not set
CONFIG_TCM_FC=m
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LAN=m
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_OHCI_DEBUG=y
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
CONFIG_FIREWIRE_NOSY=m
CONFIG_I2O=m
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=m
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=m
CONFIG_I2O_BLOCK=m
CONFIG_I2O_SCSI=m
CONFIG_I2O_PROC=m
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_IFB=m
CONFIG_DUMMY=m
CONFIG_BONDING=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
CONFIG_EQUALIZER=m
CONFIG_TUN=m
CONFIG_VETH=m
CONFIG_NET_SB1000=m
CONFIG_ARCNET=m
CONFIG_ARCNET_1201=m
CONFIG_ARCNET_1051=m
CONFIG_ARCNET_RAW=m
CONFIG_ARCNET_CAP=m
CONFIG_ARCNET_COM90xx=m
CONFIG_ARCNET_COM90xxIO=m
CONFIG_ARCNET_RIM_I=m
CONFIG_ARCNET_COM20020=m
CONFIG_ARCNET_COM20020_PCI=m
CONFIG_MII=m
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
CONFIG_MARVELL_PHY=m
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_LXT_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
CONFIG_SMSC_PHY=m
CONFIG_BROADCOM_PHY=m
CONFIG_ICPLUS_PHY=m
CONFIG_REALTEK_PHY=m
CONFIG_NATIONAL_PHY=m
CONFIG_STE10XP=m
CONFIG_LSI_ET1011C_PHY=m
CONFIG_MICREL_PHY=m
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
CONFIG_NET_ETHERNET=y
CONFIG_HAPPYMEAL=m
CONFIG_SUNGEM=m
CONFIG_CASSINI=m
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=m
CONFIG_TYPHOON=m
CONFIG_ENC28J60=m
# CONFIG_ENC28J60_WRITEVERIFY is not set
CONFIG_ETHOC=m
CONFIG_DNET=m
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=m
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=y
CONFIG_TULIP_NAPI_HW_MITIGATION=y
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
CONFIG_HP100=m
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
CONFIG_PCNET32=m
CONFIG_AMD8111_ETH=m
CONFIG_ADAPTEC_STARFIRE=m
CONFIG_KSZ884X_PCI=m
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_FORCEDETH=m
CONFIG_E100=m
CONFIG_FEALNX=m
CONFIG_NATSEMI=m
CONFIG_NE2K_PCI=m
CONFIG_8139CP=m
CONFIG_8139TOO=m
# CONFIG_8139TOO_PIO is not set
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R6040=m
CONFIG_SIS900=m
CONFIG_EPIC100=m
CONFIG_SMSC9420=m
CONFIG_SUNDANCE=m
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_TLAN=m
CONFIG_KS8842=m
CONFIG_KS8851=m
CONFIG_KS8851_MLL=m
CONFIG_VIA_RHINE=m
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_SC92031=m
# CONFIG_NET_POCKET is not set
CONFIG_ATL2=m
CONFIG_NETDEV_1000=y
CONFIG_ACENIC=m
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_DL2K=m
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_IP1000=m
CONFIG_IGB=m
CONFIG_IGB_DCA=y
CONFIG_IGBVF=m
CONFIG_NS83820=m
CONFIG_HAMACHI=m
CONFIG_YELLOWFIN=m
CONFIG_R8169=m
CONFIG_SIS190=m
CONFIG_SKGE=m
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
CONFIG_VIA_VELOCITY=m
CONFIG_TIGON3=m
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_QLA3XXX=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_JME=m
# CONFIG_STMMAC_ETH is not set
# CONFIG_PCH_GBE is not set
CONFIG_NETDEV_10000=y
CONFIG_MDIO=m
CONFIG_CHELSIO_T1=m
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
CONFIG_CHELSIO_T4VF=m
CONFIG_ENIC=m
CONFIG_IXGBE=m
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_IXGB=m
CONFIG_S2IO=m
CONFIG_VXGE=m
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_MYRI10GE=m
CONFIG_MYRI10GE_DCA=y
CONFIG_NETXEN_NIC=m
CONFIG_NIU=m
CONFIG_MLX4_EN=m
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_TEHUTI=m
CONFIG_BNX2X=m
CONFIG_QLCNIC=m
CONFIG_QLGE=m
CONFIG_BNA=m
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_BE2NET=m
CONFIG_TR=y
CONFIG_IBMOL=m
CONFIG_3C359=m
CONFIG_TMS380TR=m
CONFIG_TMSPCI=m
CONFIG_ABYSS=m
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=m
CONFIG_LIBERTAS_THINFIRM=m
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=m
CONFIG_AIRO=m
CONFIG_ATMEL=m
CONFIG_PCI_ATMEL=m
CONFIG_PCMCIA_ATMEL=m
CONFIG_AT76C50X_USB=m
CONFIG_AIRO_CS=m
CONFIG_PCMCIA_WL3501=m
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=m
CONFIG_USB_NET_RNDIS_WLAN=m
CONFIG_RTL8180=m
CONFIG_RTL8187=m
CONFIG_RTL8187_LEDS=y
CONFIG_ADM8211=m
CONFIG_MAC80211_HWSIM=m
CONFIG_MWL8K=m
CONFIG_ATH_COMMON=m
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=m
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=m
CONFIG_ATH9K_COMMON=m
CONFIG_ATH9K=m
CONFIG_ATH9K_PCI=y
# CONFIG_ATH9K_AHB is not set
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_RATE_CONTROL=y
CONFIG_ATH9K_HTC=m
# CONFIG_ATH9K_HTC_DEBUGFS is not set
CONFIG_CARL9170=m
CONFIG_CARL9170_LEDS=y
CONFIG_CARL9170_WPC=y
CONFIG_B43=m
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_PIO=y
CONFIG_B43_PHY_N=y
CONFIG_B43_PHY_LP=y
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
# CONFIG_B43_DEBUG is not set
CONFIG_B43LEGACY=m
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_HOSTAP=m
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
CONFIG_HOSTAP_PLX=m
CONFIG_HOSTAP_PCI=m
CONFIG_HOSTAP_CS=m
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=m
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=m
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLAGN=m

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
# CONFIG_IWLWIFI_DEVICE_SVTOOL is not set
# CONFIG_IWL_P2P is not set
CONFIG_IWLWIFI_LEGACY=m

#
# Debugging Options
#
# CONFIG_IWLWIFI_LEGACY_DEBUG is not set
# CONFIG_IWLWIFI_LEGACY_DEVICE_TRACING is not set
CONFIG_IWL4965=m
CONFIG_IWL3945=m
CONFIG_IWM=m
# CONFIG_IWM_DEBUG is not set
# CONFIG_IWM_TRACING is not set
CONFIG_LIBERTAS=m
CONFIG_LIBERTAS_USB=m
CONFIG_LIBERTAS_CS=m
CONFIG_LIBERTAS_SDIO=m
CONFIG_LIBERTAS_SPI=m
# CONFIG_LIBERTAS_DEBUG is not set
CONFIG_LIBERTAS_MESH=y
CONFIG_HERMES=m
# CONFIG_HERMES_PRISM is not set
CONFIG_HERMES_CACHE_FW_ON_INIT=y
CONFIG_PLX_HERMES=m
CONFIG_TMD_HERMES=m
CONFIG_NORTEL_HERMES=m
CONFIG_PCMCIA_HERMES=m
CONFIG_PCMCIA_SPECTRUM=m
CONFIG_ORINOCO_USB=m
CONFIG_P54_COMMON=m
CONFIG_P54_USB=m
CONFIG_P54_PCI=m
CONFIG_P54_SPI=m
# CONFIG_P54_SPI_DEFAULT_EEPROM is not set
CONFIG_P54_LEDS=y
CONFIG_RT2X00=m
CONFIG_RT2400PCI=m
CONFIG_RT2500PCI=m
CONFIG_RT61PCI=m
CONFIG_RT2800PCI=m
CONFIG_RT2800PCI_RT33XX=y
CONFIG_RT2800PCI_RT35XX=y
CONFIG_RT2800PCI_RT53XX=y
CONFIG_RT2500USB=m
CONFIG_RT73USB=m
CONFIG_RT2800USB=m
CONFIG_RT2800USB_RT33XX=y
CONFIG_RT2800USB_RT35XX=y
CONFIG_RT2800USB_RT53XX=y
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=m
CONFIG_RT2X00_LIB_PCI=m
CONFIG_RT2X00_LIB_USB=m
CONFIG_RT2X00_LIB=m
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
CONFIG_RTL8192CE=m
CONFIG_RTL8192SE=m
CONFIG_RTL8192CU=m
CONFIG_RTLWIFI=m
CONFIG_RTL8192C_COMMON=m
CONFIG_WL1251=m
CONFIG_WL1251_SPI=m
CONFIG_WL1251_SDIO=m
CONFIG_WL12XX_MENU=m
CONFIG_WL12XX=m
# CONFIG_WL12XX_HT is not set
CONFIG_WL12XX_SPI=m
CONFIG_WL12XX_SDIO=m
# CONFIG_WL12XX_SDIO_TEST is not set
CONFIG_WL12XX_PLATFORM_DATA=y
CONFIG_ZD1211RW=m
# CONFIG_ZD1211RW_DEBUG is not set
CONFIG_MWIFIEX=m
CONFIG_MWIFIEX_SDIO=m

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=m
CONFIG_WIMAX_I2400M_USB=m
CONFIG_WIMAX_I2400M_SDIO=m
CONFIG_WIMAX_IWMC3200_SDIO=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_CDC_EEM=m
CONFIG_USB_NET_CDC_NCM=m
CONFIG_USB_NET_DM9601=m
CONFIG_USB_NET_SMSC75XX=m
CONFIG_USB_NET_SMSC95XX=m
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
CONFIG_USB_NET_PLUSB=m
CONFIG_USB_NET_MCS7830=m
CONFIG_USB_NET_RNDIS_HOST=m
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=m
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=m
CONFIG_USB_CDC_PHONET=m
CONFIG_USB_IPHETH=m
CONFIG_USB_SIERRA_NET=m
CONFIG_USB_VL600=m
CONFIG_NET_PCMCIA=y
CONFIG_PCMCIA_3C589=m
CONFIG_PCMCIA_3C574=m
CONFIG_PCMCIA_FMVJ18X=m
CONFIG_PCMCIA_PCNET=m
CONFIG_PCMCIA_NMCLAN=m
CONFIG_PCMCIA_SMC91C92=m
CONFIG_PCMCIA_XIRC2PS=m
CONFIG_PCMCIA_AXNET=m
CONFIG_ARCNET_COM20020_CS=m
CONFIG_PCMCIA_IBMTR=m
CONFIG_WAN=y
CONFIG_LANMEDIA=m
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
CONFIG_HDLC_RAW_ETH=m
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m
# CONFIG_HDLC_X25 is not set
CONFIG_PCI200SYN=m
CONFIG_WANXL=m
# CONFIG_PC300TOO is not set
CONFIG_FARSYNC=m
CONFIG_DSCC4=m
CONFIG_DSCC4_PCISYNC=y
CONFIG_DSCC4_PCI_RST=y
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
CONFIG_WAN_ROUTER_DRIVERS=m
CONFIG_CYCLADES_SYNC=m
# CONFIG_CYCLOMX_X25 is not set
CONFIG_SBNI=m
# CONFIG_SBNI_MULTILINE is not set
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=m
CONFIG_ATM_TCP=m
CONFIG_ATM_LANAI=m
CONFIG_ATM_ENI=m
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=m
CONFIG_ATM_ZATM=m
# CONFIG_ATM_ZATM_DEBUG is not set
CONFIG_ATM_NICSTAR=m
CONFIG_ATM_NICSTAR_USE_SUNI=y
CONFIG_ATM_NICSTAR_USE_IDT77105=y
CONFIG_ATM_IDT77252=m
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=m
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=m
# CONFIG_ATM_HORIZON_DEBUG is not set
CONFIG_ATM_IA=m
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=m
# CONFIG_ATM_FORE200E_USE_TASKLET is not set
CONFIG_ATM_FORE200E_TX_RETRY=16
CONFIG_ATM_FORE200E_DEBUG=0
CONFIG_ATM_HE=m
CONFIG_ATM_HE_USE_SUNI=y
CONFIG_ATM_SOLOS=m
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKEHARD=m

#
# CAIF transport drivers
#
CONFIG_XEN_NETDEV_FRONTEND=m
CONFIG_XEN_NETDEV_BACKEND=m
CONFIG_FDDI=y
CONFIG_DEFXX=m
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=m
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=m
# CONFIG_ROADRUNNER_LARGE_RINGS is not set
CONFIG_PLIP=m
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOATM=m
CONFIG_PPPOL2TP=m
CONFIG_SLIP=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLHC=m
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y
CONFIG_NET_FC=y
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_VIRTIO_NET=m
CONFIG_VMXNET3=m
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=m
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPI20=m

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=m
CONFIG_ISDN_DRV_AVMB1_AVM_CS=m
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
CONFIG_CAPI_EICON=y
CONFIG_ISDN_DIVAS=m
CONFIG_ISDN_DIVAS_BRIPCI=y
CONFIG_ISDN_DIVAS_PRIPCI=y
CONFIG_ISDN_DIVAS_DIVACAPI=m
CONFIG_ISDN_DIVAS_USERIDI=m
CONFIG_ISDN_DIVAS_MAINT=m
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_PHONE=m
CONFIG_PHONE_IXJ=m
CONFIG_PHONE_IXJ_PCMCIA=m

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=m
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=m
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=m
CONFIG_KEYBOARD_LKKBD=m
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=m
CONFIG_KEYBOARD_MAX7359=m
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=m
CONFIG_KEYBOARD_OPENCORES=m
CONFIG_KEYBOARD_STOWAWAY=m
CONFIG_KEYBOARD_SUNKBD=m
CONFIG_KEYBOARD_XTKBD=m
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=m
CONFIG_JOYSTICK_A3D=m
CONFIG_JOYSTICK_ADI=m
CONFIG_JOYSTICK_COBRA=m
CONFIG_JOYSTICK_GF2K=m
CONFIG_JOYSTICK_GRIP=m
CONFIG_JOYSTICK_GRIP_MP=m
CONFIG_JOYSTICK_GUILLEMOT=m
CONFIG_JOYSTICK_INTERACT=m
CONFIG_JOYSTICK_SIDEWINDER=m
CONFIG_JOYSTICK_TMDC=m
CONFIG_JOYSTICK_IFORCE=m
CONFIG_JOYSTICK_IFORCE_USB=y
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=m
CONFIG_JOYSTICK_MAGELLAN=m
CONFIG_JOYSTICK_SPACEORB=m
CONFIG_JOYSTICK_SPACEBALL=m
CONFIG_JOYSTICK_STINGER=m
CONFIG_JOYSTICK_TWIDJOY=m
CONFIG_JOYSTICK_ZHENHUA=m
CONFIG_JOYSTICK_DB9=m
CONFIG_JOYSTICK_GAMECON=m
CONFIG_JOYSTICK_TURBOGRAFX=m
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=m
CONFIG_JOYSTICK_XPAD=m
CONFIG_JOYSTICK_XPAD_FF=y
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_JOYSTICK_WALKERA0701=m
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
CONFIG_TABLET_USB_HANWANG=m
CONFIG_TABLET_USB_KBTAB=m
CONFIG_TABLET_USB_WACOM=m
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=m
CONFIG_TOUCHSCREEN_AD7877=m
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
CONFIG_TOUCHSCREEN_DYNAPRO=m
CONFIG_TOUCHSCREEN_HAMPSHIRE=m
CONFIG_TOUCHSCREEN_EETI=m
CONFIG_TOUCHSCREEN_FUJITSU=m
CONFIG_TOUCHSCREEN_GUNZE=m
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=m
CONFIG_TOUCHSCREEN_MTOUCH=m
CONFIG_TOUCHSCREEN_INEXIO=m
CONFIG_TOUCHSCREEN_MK712=m
CONFIG_TOUCHSCREEN_PENMOUNT=m
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=m
CONFIG_TOUCHSCREEN_WM97XX=m
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=m
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_TOUCHIT213=m
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=m
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_TPS6507X=m
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_PCSPKR=m
CONFIG_INPUT_APANEL=m
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
CONFIG_INPUT_PCF50633_PMU=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PARKBD=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=m
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
CONFIG_ISI=m
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=m
# CONFIG_SERIAL_MAX3107 is not set
CONFIG_SERIAL_MFD_HSU=m
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_VIRTIO_CONSOLE=m
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=m
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=m
CONFIG_NVRAM=m
CONFIG_R3964=m
CONFIG_APPLICOM=m

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=m
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
CONFIG_IPWIRELESS=m
CONFIG_MWAVE=m
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
CONFIG_RAMOOPS=m
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=m
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
CONFIG_I2C_SIS5595=m
CONFIG_I2C_SIS630=m
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=m
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set
# CONFIG_I2C_EG20T is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
CONFIG_I2C_TAOS_EVM=m
CONFIG_I2C_TINY_USB=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=m
CONFIG_SPI_BUTTERFLY=m
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=m
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=m

#
# PPS support
#
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=m

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_BASIC_MMIO is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MCP23S08 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_74X164 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_W1=m
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=m
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=m
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=m
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2760=m
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2782=m
# CONFIG_BATTERY_BQ20Z75 is not set
CONFIG_BATTERY_BQ27x00=m
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=m
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=m
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_GPIO is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADCXX=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM70=m
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_MAX1111=m
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_ADS7871=m
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_APPLESMC=m

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=m
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
CONFIG_ACQUIRE_WDT=m
CONFIG_ADVANTECH_WDT=m
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SC520_WDT=m
CONFIG_SBC_FITPC2_WATCHDOG=m
CONFIG_EUROTECH_WDT=m
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
CONFIG_WAFER_WDT=m
CONFIG_I6300ESB_WDT=m
CONFIG_ITCO_WDT=m
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=m
CONFIG_PC87413_WDT=m
CONFIG_NV_TCO=m
CONFIG_60XX_WDT=m
CONFIG_SBC8360_WDT=m
CONFIG_CPU5_WDT=m
CONFIG_SMSC_SCH311X_WDT=m
CONFIG_SMSC37B787_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83697HF_WDT=m
CONFIG_W83697UG_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
CONFIG_SBC_EPX_C3_WATCHDOG=m
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set
CONFIG_MFD_SUPPORT=y
CONFIG_MFD_CORE=m
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_HTC_PASIC3=m
# CONFIG_UCB1400_CORE is not set
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=m
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_WM8400=m
# CONFIG_MFD_WM831X_SPI is not set
CONFIG_MFD_PCF50633=m
CONFIG_PCF50633_ADC=m
CONFIG_PCF50633_GPIO=m
# CONFIG_MFD_MC13XXX is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=m
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_WL1273_CORE=m
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=m
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
CONFIG_REGULATOR_BQ24022=m
CONFIG_REGULATOR_MAX1586=m
CONFIG_REGULATOR_MAX8649=m
CONFIG_REGULATOR_MAX8660=m
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_WM8400=m
CONFIG_REGULATOR_PCF50633=m
CONFIG_REGULATOR_LP3971=m
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=m
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2_COMMON=m
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_DVB_CORE=m
CONFIG_VIDEO_MEDIA=m

#
# Multimedia drivers
#
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_RC_CORE=m
CONFIG_LIRC=m
CONFIG_RC_MAP=m
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_RC5_SZ_DECODER=m
CONFIG_IR_LIRC_CODEC=m
CONFIG_IR_ENE=m
CONFIG_IR_IMON=m
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
CONFIG_RC_LOOPBACK=m
CONFIG_MEDIA_ATTACH=y
CONFIG_MEDIA_TUNER=m
# CONFIG_MEDIA_TUNER_CUSTOMISE is not set
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_VIDEO_BTCX=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEO_CAPTURE_DRIVERS=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_HELPER_CHIPS_AUTO=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_TDA9840=m
CONFIG_VIDEO_TEA6415C=m
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_BT819=m
CONFIG_VIDEO_BT856=m
CONFIG_VIDEO_BT866=m
CONFIG_VIDEO_KS0127=m
CONFIG_VIDEO_SAA7110=m
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_VPX3220=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# MPEG video encoders
#
CONFIG_VIDEO_CX2341X=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m
CONFIG_VIDEO_SAA7185=m
CONFIG_VIDEO_ADV7170=m
CONFIG_VIDEO_ADV7175=m

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7670=m
CONFIG_VIDEO_MT9V011=m

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Miscelaneous helper chips
#
CONFIG_VIDEO_M52790=m
CONFIG_VIDEO_VIVI=m
CONFIG_VIDEO_BT848=m
CONFIG_VIDEO_BT848_DVB=y
CONFIG_VIDEO_BWQCAM=m
CONFIG_VIDEO_CQCAM=m
CONFIG_VIDEO_W9966=m
CONFIG_VIDEO_CPIA2=m
CONFIG_VIDEO_ZORAN=m
CONFIG_VIDEO_ZORAN_DC30=m
CONFIG_VIDEO_ZORAN_ZR36060=m
CONFIG_VIDEO_ZORAN_BUZ=m
CONFIG_VIDEO_ZORAN_DC10=m
CONFIG_VIDEO_ZORAN_LML33=m
CONFIG_VIDEO_ZORAN_LML33R10=m
CONFIG_VIDEO_ZORAN_AVS6EYES=m
CONFIG_VIDEO_MEYE=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_MXB=m
CONFIG_VIDEO_HEXIUM_ORION=m
CONFIG_VIDEO_HEXIUM_GEMINI=m
# CONFIG_VIDEO_TIMBERDALE is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX23885=m
# CONFIG_MEDIA_ALTERA_CI is not set
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_IVTV=m
CONFIG_VIDEO_FB_IVTV=m
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_SAA7164=m
CONFIG_VIDEO_CAFE_CCIC=m
CONFIG_VIDEO_SR030PC30=m
CONFIG_VIDEO_VIA_CAMERA=m
CONFIG_VIDEO_NOON010PC30=m
CONFIG_SOC_CAMERA=m
CONFIG_SOC_CAMERA_IMX074=m
CONFIG_SOC_CAMERA_MT9M001=m
CONFIG_SOC_CAMERA_MT9M111=m
CONFIG_SOC_CAMERA_MT9T031=m
CONFIG_SOC_CAMERA_MT9T112=m
CONFIG_SOC_CAMERA_MT9V022=m
CONFIG_SOC_CAMERA_RJ54N1=m
CONFIG_SOC_CAMERA_TW9910=m
CONFIG_SOC_CAMERA_PLATFORM=m
CONFIG_SOC_CAMERA_OV2640=m
CONFIG_SOC_CAMERA_OV6650=m
CONFIG_SOC_CAMERA_OV772X=m
CONFIG_SOC_CAMERA_OV9640=m
CONFIG_SOC_CAMERA_OV9740=m
CONFIG_V4L_USB_DRIVERS=y
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_KINECT=m
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_EM28XX=m
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_TLG2300=m
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_USBVISION=m
CONFIG_USB_ET61X251=m
CONFIG_USB_SN9C102=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
CONFIG_V4L_MEM2MEM_DRIVERS=y
# CONFIG_VIDEO_MEM2MEM_TESTDEV is not set
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_MAXIRADIO=m
CONFIG_I2C_SI4713=m
CONFIG_RADIO_SI4713=m
CONFIG_USB_DSBR=m
CONFIG_RADIO_SI470X=y
CONFIG_USB_SI470X=m
CONFIG_I2C_SI470X=m
CONFIG_USB_MR800=m
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=m
CONFIG_RADIO_TEF6862=m
CONFIG_RADIO_WL1273=m

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_RADIO_WL128X=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_CAPTURE_DRIVERS=y

#
# Supported SAA7146 based PCI Adapters
#
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m

#
# Supported USB Adapters
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
CONFIG_DVB_USB_DIBUSB_MB_FAULTY=y
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_FRIIO=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_SIANO_MDTV=m

#
# Siano module components
#
CONFIG_SMS_USB_DRV=m
CONFIG_SMS_SDIO_DRV=m

#
# Supported FlexCopII (B2C2) Adapters
#
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set

#
# Supported BT878 Adapters
#
CONFIG_DVB_BT8XX=m

#
# Supported Pluto2 Adapters
#
CONFIG_DVB_PLUTO2=m

#
# Supported SDMC DM1105 Adapters
#
CONFIG_DVB_DM1105=m

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y

#
# Supported Earthsoft PT1 Adapters
#
CONFIG_DVB_PT1=m

#
# Supported Mantis Adapters
#
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m

#
# Supported nGene Adapters
#
CONFIG_DVB_NGENE=m

#
# Supported DVB Frontends
#
# CONFIG_DVB_FE_CUSTOMISE is not set

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV6110x=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_TTM=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=m
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=m
CONFIG_DRM_SIS=m
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
# CONFIG_STUB_POULSBO is not set
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=m
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
CONFIG_FB_PM2=m
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=m
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=m
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=m
CONFIG_FB_UVESA=m
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
CONFIG_FB_LE80578=m
CONFIG_FB_CARILLO_RANCH=m
CONFIG_FB_MATROX=m
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_MATROX_MAVEN=m
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=m
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=m
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=m
# CONFIG_FB_SAVAGE_I2C is not set
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=m
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=m
CONFIG_FB_3DFX=m
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=m
CONFIG_FB_TRIDENT=m
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=m
# CONFIG_FB_UDL is not set
CONFIG_FB_VIRTUAL=m
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_PROGEAR=m
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=m

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
CONFIG_SND_OPL3_LIB_SEQ=m
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
CONFIG_SND_MTS64=m
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m
CONFIG_SND_PORTMAN2X4=m
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=m
CONFIG_SND_SB16_DSP=m
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
CONFIG_SND_ALS300=m
CONFIG_SND_ALS4000=m
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=m
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
CONFIG_SND_CS4281=m
CONFIG_SND_CS46XX=m
CONFIG_SND_CS5530=m
CONFIG_SND_CS5535AUDIO=m
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
CONFIG_SND_ES1938=m
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
CONFIG_SND_FM801=m
CONFIG_SND_FM801_TEA575X_BOOL=y
CONFIG_SND_TEA575X=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
CONFIG_SND_PCXHR=m
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
CONFIG_SND_SONICVIBES=m
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
CONFIG_SND_YMFPCI=m
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
CONFIG_SND_FIREWIRE_SPEAKERS=m
CONFIG_SND_ISIGHT=m
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=m
CONFIG_SND_PDAUDIOCF=m
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=m
CONFIG_HIDRAW=y

#
# USB Input Devices
#
CONFIG_USB_HID=m
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=m
CONFIG_HID_ACRUX_FF=m
CONFIG_HID_APPLE=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_PRODIKEYS=m
CONFIG_HID_CYPRESS=m
CONFIG_HID_DRAGONRISE=m
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
CONFIG_HID_EZKEY=m
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=m
CONFIG_HID_LOGITECH=m
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWII_FF=y
CONFIG_HID_MAGICMOUSE=m
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
CONFIG_HID_MULTITOUCH=m
CONFIG_HID_NTRIG=m
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_QUANTA=m
CONFIG_HID_ROCCAT=m
CONFIG_HID_ROCCAT_COMMON=m
CONFIG_HID_ROCCAT_ARVO=m
CONFIG_HID_ROCCAT_KONE=m
CONFIG_HID_ROCCAT_KONEPLUS=m
CONFIG_HID_ROCCAT_KOVAPLUS=m
CONFIG_HID_ROCCAT_PYRA=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_GREENASIA=m
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=m
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TOPSEED=m
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=m
CONFIG_HID_WACOM_POWER_SUPPLY=y
CONFIG_HID_ZEROPLUS=m
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=m
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=m
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_HCD_SSB is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=m
CONFIG_USB_R8A66597_HCD=m
CONFIG_USB_WHCI_HCD=m
CONFIG_USB_HWA_HCD=m

#
# Enable Host or Gadget support to see Inventra options
#

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_FUNSOFT=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
CONFIG_USB_SERIAL_MOTOROLA=m
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_HP4X=m
CONFIG_USB_SERIAL_SAFE=m
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=m
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_VIVOPAY_SERIAL=m
CONFIG_USB_SERIAL_ZIO=m
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
CONFIG_USB_CYPRESS_CY7C63=m
CONFIG_USB_CYTHERM=m
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=m
CONFIG_USB_TEST=m
CONFIG_USB_ISIGHTFW=m
CONFIG_USB_YUREX=m
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=m
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_PLTFM=m
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
CONFIG_MMC_SPI=m
CONFIG_MMC_SDRICOH_CS=m
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_ALIX2=m
CONFIG_LEDS_PCA9532=m
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=m
CONFIG_LEDS_DAC124S085=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_INTEL_SS4200=m
CONFIG_LEDS_LT3593=m
CONFIG_LEDS_DELL_NETBOOKS=m
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_NFC_DEVICES is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
CONFIG_INFINIBAND=m
CONFIG_INFINIBAND_USER_MAD=m
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=m
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=m
CONFIG_INFINIBAND_QIB=m
CONFIG_INFINIBAND_AMSO1100=m
# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=m
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=m
CONFIG_MLX4_INFINIBAND=m
CONFIG_INFINIBAND_NES=m
# CONFIG_INFINIBAND_NES_DEBUG is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=m
CONFIG_INFINIBAND_ISER=m
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_MCE=y
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1374=m
CONFIG_RTC_DRV_DS1672=m
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=m
CONFIG_RTC_DRV_S35390A=m
CONFIG_RTC_DRV_FM3130=m
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=m
CONFIG_RTC_DRV_DS1305=m
CONFIG_RTC_DRV_DS1390=m
CONFIG_RTC_DRV_MAX6902=m
CONFIG_RTC_DRV_R9701=m
CONFIG_RTC_DRV_RS5C348=m
CONFIG_RTC_DRV_DS3234=m
CONFIG_RTC_DRV_PCF2123=m

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_STK17TA8=m
CONFIG_RTC_DRV_M48T86=m
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m
CONFIG_RTC_DRV_PCF50633=m

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=m
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV=m
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
CONFIG_XEN_PLATFORM_PCI=y
CONFIG_SWIOTLB_XEN=y
CONFIG_STAGING=y
# CONFIG_STALLION is not set
# CONFIG_ISTALLION is not set
CONFIG_DIGIEPCA=m
CONFIG_RISCOM8=m
CONFIG_SPECIALIX=m
CONFIG_COMPUTONE=m
CONFIG_ET131X=m
# CONFIG_ET131X_DEBUG is not set
# CONFIG_SLICOSS is not set
# CONFIG_VIDEO_GO7007 is not set
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m
# CONFIG_DVB_CXD2099 is not set
CONFIG_USBIP_CORE=m
CONFIG_USBIP_VHCI_HCD=m
CONFIG_USBIP_HOST=m
# CONFIG_USBIP_DEBUG is not set
# CONFIG_W35UND is not set
CONFIG_PRISM2_USB=m
# CONFIG_ECHO is not set
CONFIG_BRCMUTIL=m
CONFIG_BRCMSMAC=m
# CONFIG_BRCMFMAC is not set
# CONFIG_BRCMDBG is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_MISC_DRIVERS=m
CONFIG_COMEDI_KCOMEDILIB=m
CONFIG_COMEDI_BOND=m
CONFIG_COMEDI_TEST=m
CONFIG_COMEDI_PARPORT=m
CONFIG_COMEDI_SERIAL2002=m
# CONFIG_COMEDI_SKEL is not set
CONFIG_COMEDI_PCI_DRIVERS=m
CONFIG_COMEDI_ADDI_APCI_035=m
CONFIG_COMEDI_ADDI_APCI_1032=m
CONFIG_COMEDI_ADDI_APCI_1500=m
CONFIG_COMEDI_ADDI_APCI_1516=m
CONFIG_COMEDI_ADDI_APCI_1564=m
CONFIG_COMEDI_ADDI_APCI_16XX=m
CONFIG_COMEDI_ADDI_APCI_2016=m
CONFIG_COMEDI_ADDI_APCI_2032=m
CONFIG_COMEDI_ADDI_APCI_2200=m
CONFIG_COMEDI_ADDI_APCI_3001=m
CONFIG_COMEDI_ADDI_APCI_3120=m
CONFIG_COMEDI_ADDI_APCI_3501=m
CONFIG_COMEDI_ADDI_APCI_3XXX=m
CONFIG_COMEDI_ADL_PCI6208=m
# CONFIG_COMEDI_ADL_PCI7230 is not set
CONFIG_COMEDI_ADL_PCI7296=m
CONFIG_COMEDI_ADL_PCI7432=m
CONFIG_COMEDI_ADL_PCI8164=m
CONFIG_COMEDI_ADL_PCI9111=m
CONFIG_COMEDI_ADL_PCI9118=m
CONFIG_COMEDI_ADV_PCI1710=m
CONFIG_COMEDI_ADV_PCI1723=m
CONFIG_COMEDI_ADV_PCI_DIO=m
CONFIG_COMEDI_AMPLC_DIO200=m
CONFIG_COMEDI_AMPLC_PC236=m
CONFIG_COMEDI_AMPLC_PC263=m
CONFIG_COMEDI_AMPLC_PCI224=m
CONFIG_COMEDI_AMPLC_PCI230=m
CONFIG_COMEDI_CONTEC_PCI_DIO=m
CONFIG_COMEDI_DT3000=m
CONFIG_COMEDI_UNIOXX5=m
CONFIG_COMEDI_GSC_HPDI=m
CONFIG_COMEDI_ICP_MULTI=m
CONFIG_COMEDI_II_PCI20KC=m
CONFIG_COMEDI_DAQBOARD2000=m
CONFIG_COMEDI_JR3_PCI=m
CONFIG_COMEDI_KE_COUNTER=m
CONFIG_COMEDI_CB_PCIDAS64=m
CONFIG_COMEDI_CB_PCIDAS=m
CONFIG_COMEDI_CB_PCIDDA=m
CONFIG_COMEDI_CB_PCIDIO=m
CONFIG_COMEDI_CB_PCIMDAS=m
CONFIG_COMEDI_CB_PCIMDDA=m
CONFIG_COMEDI_ME4000=m
CONFIG_COMEDI_ME_DAQ=m
CONFIG_COMEDI_NI_6527=m
CONFIG_COMEDI_NI_65XX=m
CONFIG_COMEDI_NI_660X=m
CONFIG_COMEDI_NI_670X=m
CONFIG_COMEDI_NI_PCIDIO=m
CONFIG_COMEDI_NI_PCIMIO=m
CONFIG_COMEDI_RTD520=m
CONFIG_COMEDI_S526=m
CONFIG_COMEDI_S626=m
CONFIG_COMEDI_SSV_DNP=m
CONFIG_COMEDI_PCMCIA_DRIVERS=m
CONFIG_COMEDI_CB_DAS16_CS=m
CONFIG_COMEDI_DAS08_CS=m
CONFIG_COMEDI_NI_DAQ_700_CS=m
CONFIG_COMEDI_NI_DAQ_DIO24_CS=m
CONFIG_COMEDI_NI_LABPC_CS=m
CONFIG_COMEDI_NI_MIO_CS=m
CONFIG_COMEDI_QUATECH_DAQP_CS=m
CONFIG_COMEDI_USB_DRIVERS=m
CONFIG_COMEDI_DT9812=m
CONFIG_COMEDI_USBDUX=m
CONFIG_COMEDI_USBDUXFAST=m
CONFIG_COMEDI_VMK80XX=m
CONFIG_COMEDI_NI_COMMON=m
CONFIG_COMEDI_MITE=m
CONFIG_COMEDI_NI_TIO=m
CONFIG_COMEDI_NI_LABPC=m
CONFIG_COMEDI_8255=m
CONFIG_COMEDI_DAS08=m
CONFIG_COMEDI_FC=m
# CONFIG_ASUS_OLED is not set
# CONFIG_PANEL is not set
CONFIG_R8187SE=m
CONFIG_RTL8192U=m
CONFIG_RTL8192E=m
CONFIG_R8712U=m
# CONFIG_R8712_AP is not set
CONFIG_RTS_PSTOR=m
# CONFIG_RTS_PSTOR_DEBUG is not set
# CONFIG_TRANZPORT is not set
CONFIG_POHMELFS=m
# CONFIG_POHMELFS_DEBUG is not set
CONFIG_POHMELFS_CRYPTO=y
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_NOUVEAU=m
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_NOUVEAU_DEBUG is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_USB_SERIAL_QUATECH_USB2 is not set
# CONFIG_VT6655 is not set
CONFIG_VT6656=m
# CONFIG_HYPERV is not set
# CONFIG_VME_BUS is not set
# CONFIG_DX_SEP is not set
# CONFIG_IIO is not set
CONFIG_XVMALLOC=y
CONFIG_ZRAM=m
# CONFIG_ZRAM_DEBUG is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_VIDEO_DT3155 is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
CONFIG_LIRC_STAGING=y
CONFIG_LIRC_BT829=m
CONFIG_LIRC_IGORPLUGUSB=m
CONFIG_LIRC_IMON=m
# CONFIG_LIRC_PARALLEL is not set
CONFIG_LIRC_SASEM=m
CONFIG_LIRC_SERIAL=m
CONFIG_LIRC_SERIAL_TRANSMITTER=y
CONFIG_LIRC_SIR=m
CONFIG_LIRC_TTUSBIR=m
CONFIG_LIRC_ZILOG=m
CONFIG_EASYCAP=m
CONFIG_EASYCAP_SND=y
# CONFIG_EASYCAP_OSS is not set
# CONFIG_EASYCAP_DEBUG is not set
# CONFIG_SOLO6X10 is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_MACH_NO_WESTBRIDGE=y
# CONFIG_SBE_2T3E3 is not set
# CONFIG_ATH6K_LEGACY is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=m
CONFIG_SPEAKUP_SYNTH_ACNTSA=m
CONFIG_SPEAKUP_SYNTH_ACNTPC=m
CONFIG_SPEAKUP_SYNTH_APOLLO=m
CONFIG_SPEAKUP_SYNTH_AUDPTR=m
CONFIG_SPEAKUP_SYNTH_BNS=m
CONFIG_SPEAKUP_SYNTH_DECTLK=m
CONFIG_SPEAKUP_SYNTH_DECEXT=m
# CONFIG_SPEAKUP_SYNTH_DECPC is not set
CONFIG_SPEAKUP_SYNTH_DTLK=m
CONFIG_SPEAKUP_SYNTH_KEYPC=m
CONFIG_SPEAKUP_SYNTH_LTLK=m
CONFIG_SPEAKUP_SYNTH_SOFT=m
CONFIG_SPEAKUP_SYNTH_SPKOUT=m
CONFIG_SPEAKUP_SYNTH_TXPRT=m
CONFIG_SPEAKUP_SYNTH_DUMMY=m
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_DRM_PSB=m

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ACERHDF=m
CONFIG_ASUS_LAPTOP=m
CONFIG_DELL_LAPTOP=m
CONFIG_DELL_WMI=m
CONFIG_DELL_WMI_AIO=m
CONFIG_FUJITSU_LAPTOP=m
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
CONFIG_HP_ACCEL=m
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
CONFIG_ACPI_WMI=m
CONFIG_MSI_WMI=m
CONFIG_ACPI_ASUS=m
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_ACPI_TOSHIBA=m
CONFIG_TOSHIBA_BT_RFKILL=m
CONFIG_ACPI_CMPC=m
CONFIG_INTEL_IPS=m
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=m
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_SIGMA is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=m
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=m
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=m
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_NILFS2_FS=m
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=m
CONFIG_QFMT_V1=m
CONFIG_QFMT_V2=m
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="utf8"
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=m
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=m
CONFIG_ECRYPT_FS=m
CONFIG_HFS_FS=m
CONFIG_HFSPLUS_FS=m
CONFIG_BEFS_FS=m
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=m
CONFIG_EFS_FS=m
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=m
CONFIG_UBIFS_FS_XATTR=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_FS_DEBUG is not set
CONFIG_LOGFS=m
CONFIG_CRAMFS=m
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=m
CONFIG_MINIX_FS=m
CONFIG_OMFS_FS=m
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=m
CONFIG_ROMFS_FS=m
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_SYSV_FS=m
CONFIG_UFS_FS=m
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=m
# CONFIG_EXOFS_DEBUG is not set
CONFIG_AUFS_FS=m
CONFIG_AUFS_BRANCH_MAX_127=y
# CONFIG_AUFS_BRANCH_MAX_511 is not set
# CONFIG_AUFS_BRANCH_MAX_1023 is not set
# CONFIG_AUFS_BRANCH_MAX_32767 is not set
CONFIG_AUFS_SBILIST=y
# CONFIG_AUFS_HNOTIFY is not set
# CONFIG_AUFS_EXPORT is not set
# CONFIG_AUFS_RDU is not set
# CONFIG_AUFS_PROC_MAP is not set
# CONFIG_AUFS_SP_IATTR is not set
# CONFIG_AUFS_SHWH is not set
# CONFIG_AUFS_BR_RAMFS is not set
# CONFIG_AUFS_BR_FUSE is not set
CONFIG_AUFS_BR_HFSPLUS=y
CONFIG_AUFS_BDEV_LOOP=y
# CONFIG_AUFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFS_USE_NEW_IDMAPPER is not set
CONFIG_NFSD=m
CONFIG_NFSD_DEPRECATED=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_XPRT_RDMA=m
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_CEPH_FS=m
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
CONFIG_CIFS_FSCACHE=y
CONFIG_CIFS_ACL=y
CONFIG_NCP_FS=m
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=m
CONFIG_AFS_FS=m
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=y
CONFIG_9P_FS=m
CONFIG_9P_FSCACHE=y
CONFIG_9P_FS_POSIX_ACL=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=y
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_MASK=0x01b6
CONFIG_STRIP_ASM_SYMS=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_LKDTM is not set
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_SYSCTL_SYSCALL_CHECK=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_KPROBE_EVENT is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
# CONFIG_INTEL_TXT is not set
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=0
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_TOMOYO=y
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_IMA is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=m
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=m
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_SEQIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=m

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=m
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_AES_X86_64=m
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_X86_64=m
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_ZLIB=m
CONFIG_CRYPTO_LZO=m

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_USER_API=m
CONFIG_CRYPTO_USER_API_HASH=m
CONFIG_CRYPTO_USER_API_SKCIPHER=m
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
CONFIG_CRYPTO_DEV_HIFN_795X=m
CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=m
CONFIG_VIRTIO=m
CONFIG_VIRTIO_RING=m
CONFIG_VIRTIO_PCI=m
CONFIG_VIRTIO_BALLOON=m
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_NLATTR=y
CONFIG_LRU_CACHE=m
CONFIG_AVERAGE=y

--nextPart1703242.9C23h8g3pK
Content-Disposition: attachment; filename="lspci"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="lspci"

00:00.0 Host bridge: Intel Corporation Mobile PM965/GM965/GL960 Memory Controller Hub (rev 03)
00:01.0 PCI bridge: Intel Corporation Mobile PM965/GM965/GL960 PCI Express Root Port (rev 03)
00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4 (rev 03)
00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 03)
00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 03)
00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 03)
00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 03)
00:1c.1 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 03)
00:1c.2 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 3 (rev 03)
00:1c.3 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 4 (rev 03)
00:1c.4 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 5 (rev 03)
00:1c.5 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 6 (rev 03)
00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 03)
00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 03)
00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3 (rev 03)
00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 03)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev f3)
00:1f.0 ISA bridge: Intel Corporation 82801HEM (ICH8M) LPC Interface Controller (rev 03)
00:1f.2 IDE interface: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E) SATA IDE Controller (rev 03)
00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 03)
01:00.0 VGA compatible controller: nVidia Corporation G92 [GeForce 8800M GTX] (rev a2)
06:00.0 Network controller: Intel Corporation WiFi Link 5100
08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)
0c:07.0 FLASH memory: ENE Technology Inc ENE PCI Memory Stick Card Reader Controller
0c:07.1 SD Host controller: ENE Technology Inc ENE PCI SmartMedia / xD Card Reader Controller
0c:07.3 FLASH memory: ENE Technology Inc ENE PCI Secure Digital / MMC Card Reader Controller
0c:09.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire II(M)] IEEE 1394 OHCI Controller (rev c0)

--nextPart1703242.9C23h8g3pK
Content-Disposition: attachment; filename="lsmod"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="lsmod"

Module                  Size  Used by
cryptd                 14549  0 
aes_x86_64             16796  2 
aes_generic            33026  1 aes_x86_64
configfs               23862  0 
parport_pc             22395  0 
ppdev                  12763  0 
lp                     17270  0 
parport                31929  3 parport_pc,ppdev,lp
rfcomm                 33848  10 
bnep                   17615  2 
nfsd                  260662  2 
nfs                   259369  0 
lockd                  71503  2 nfsd,nfs
fscache                36721  1 nfs
auth_rpcgss            37204  2 nfsd,nfs
nfs_acl                12511  2 nfsd,nfs
sunrpc                172969  6 nfsd,nfs,lockd,auth_rpcgss,nfs_acl
ext3                  114399  1 
jbd                    43355  1 ext3
loop                   22711  0 
firewire_sbp2          18062  0 
snd_hda_codec_si3054    12758  1 
snd_hda_codec_realtek   278027  1 
snd_hda_intel          26140  2 
snd_hda_codec          72699  3 snd_hda_codec_si3054,snd_hda_codec_realtek,snd_hda_intel
arc4                   12458  2 
btusb                  17462  2 
bluetooth             114376  23 rfcomm,bnep,btusb
snd_hwdep              13186  1 snd_hda_codec
snd_pcm                68104  3 snd_hda_codec_si3054,snd_hda_intel,snd_hda_codec
iwlagn                166455  0 
sg                     25985  0 
snd_seq                45208  0 
snd_timer              22581  2 snd_pcm,snd_seq
snd_seq_device         13137  1 snd_seq
ir_lirc_codec          12715  0 
lirc_dev               17027  1 ir_lirc_codec
nouveau               516733  2 
mac80211              182582  1 iwlagn
cfg80211              132564  2 iwlagn,mac80211
i2c_i801               16870  0 
ttm                    52979  1 nouveau
firewire_ohci          35553  0 
sdhci_pci              13304  0 
drm_kms_helper         27216  1 nouveau
drm                   163280  4 nouveau,ttm,drm_kms_helper
uhci_hcd               26787  0 
sr_mod                 21811  0 
snd                    52823  13 snd_hda_codec_si3054,snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_seq,snd_timer,snd_seq_device
ir_sony_decoder        12435  0 
i2c_algo_bit           12850  1 nouveau
r8169                  42411  0 
soundcore              13152  1 snd
ehci_hcd               40090  0 
usbcore               128338  4 btusb,uhci_hcd,ehci_hcd
cdrom                  35093  1 sr_mod
snd_page_alloc         13043  2 snd_hda_intel,snd_pcm
joydev                 17262  0 
mii                    12675  1 r8169
rfkill                 19080  3 bluetooth,cfg80211
sdhci                  26511  1 sdhci_pci
mmc_core               63601  1 sdhci
i2c_core               23909  5 nouveau,i2c_i801,drm_kms_helper,drm,i2c_algo_bit
mxm_wmi                12473  1 nouveau
firewire_core          48371  2 firewire_sbp2,firewire_ohci
ir_jvc_decoder         12475  0 
battery                13109  0 
ac                     12624  0 
button                 12930  1 nouveau
processor              27942  2 
video                  17707  1 nouveau
ir_rc6_decoder         12466  0 
evdev                  17558  15 
crc_itu_t              12347  1 firewire_core
wmi                    13243  1 mxm_wmi
ir_rc5_decoder         12433  0 
rc_rc6_mce             12396  0 
ir_nec_decoder         12475  0 
pcspkr                 12579  0 
container              12581  0 
ite_cir                18671  0 
rc_core                18320  9 ir_lirc_codec,ir_sony_decoder,ir_jvc_decoder,ir_rc6_decoder,ir_rc5_decoder,rc_rc6_mce,ir_nec_decoder,ite_cir
power_supply           13475  2 battery,ac
psmouse                55656  0 
serio_raw              12846  0 
ext4                  318055  1 
mbcache                13066  2 ext3,ext4
jbd2                   62574  1 ext4
crc16                  12343  2 bluetooth,ext4
sd_mod                 36259  4 
crc_t10dif             12348  1 sd_mod
ata_generic            12479  0 
thermal                17426  0 
thermal_sys            17949  3 processor,video,thermal
ata_piix               25358  3 
libata                149043  2 ata_generic,ata_piix
scsi_mod              162442  5 firewire_sbp2,sg,sr_mod,sd_mod,libata

--nextPart1703242.9C23h8g3pK
Content-Disposition: attachment; filename="iwlagndmesg"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="iwlagndmesg"

[ 4223.625071] r8169 0000:08:00.0: eth0: link down
[ 4243.450094] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 4332.988038] wlan0: authenticate with 00:24:a5:d8:11:d9 (try 1)
[ 4332.990397] wlan0: authenticated
[ 4333.008105] wlan0: associate with 00:24:a5:d8:11:d9 (try 1)
[ 4333.012067] wlan0: RX AssocResp from 00:24:a5:d8:11:d9 (capab=0x411 status=0 aid=1)
[ 4333.012075] wlan0: associated
[ 4333.040365] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 4335.355538] Intel AES-NI instructions are not detected.
[ 4335.400872] padlock_aes: VIA PadLock not detected.
[ 4348.040068] wlan0: no IPv6 routers present
[ 4399.230308] iwlagn 0000:06:00.0: Microcode SW error detected.  Restarting 0x82000000.
[ 4399.230313] iwlagn 0000:06:00.0: Loaded firmware version: 8.83.5.1 build 33692
[ 4399.230390] iwlagn 0000:06:00.0: Start IWL Error Log Dump:
[ 4399.230392] iwlagn 0000:06:00.0: Status: 0x000412E4, count: 5
[ 4399.230394] iwlagn 0000:06:00.0: 0x00000005 | SYSASSERT                   
[ 4399.230397] iwlagn 0000:06:00.0: 0x000024EC | uPc
[ 4399.230398] iwlagn 0000:06:00.0: 0x000024C8 | branchlink1
[ 4399.230400] iwlagn 0000:06:00.0: 0x000024C8 | branchlink2
[ 4399.230402] iwlagn 0000:06:00.0: 0x00000916 | interruptlink1
[ 4399.230404] iwlagn 0000:06:00.0: 0x00000000 | interruptlink2
[ 4399.230406] iwlagn 0000:06:00.0: 0x000000FF | data1
[ 4399.230408] iwlagn 0000:06:00.0: 0x00000489 | data2
[ 4399.230409] iwlagn 0000:06:00.0: 0x00000489 | line
[ 4399.230411] iwlagn 0000:06:00.0: 0x44C04DAD | beacon time
[ 4399.230413] iwlagn 0000:06:00.0: 0xC3628253 | tsf low
[ 4399.230415] iwlagn 0000:06:00.0: 0x00000018 | tsf hi
[ 4399.230417] iwlagn 0000:06:00.0: 0x00000000 | time gp1
[ 4399.230418] iwlagn 0000:06:00.0: 0x0708E4F6 | time gp2
[ 4399.230420] iwlagn 0000:06:00.0: 0x00000000 | time gp3
[ 4399.230422] iwlagn 0000:06:00.0: 0x00010853 | uCode version
[ 4399.230424] iwlagn 0000:06:00.0: 0x00000054 | hw version
[ 4399.230426] iwlagn 0000:06:00.0: 0x00480303 | board version
[ 4399.230427] iwlagn 0000:06:00.0: 0x097F0048 | hcmd
[ 4399.230429] iwlagn 0000:06:00.0: CSR values:
[ 4399.230432] iwlagn 0000:06:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 4399.230437] iwlagn 0000:06:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
[ 4399.230442] iwlagn 0000:06:00.0:          CSR_INT_COALESCING: 0X00000040
[ 4399.230447] iwlagn 0000:06:00.0:                     CSR_INT: 0X00000000
[ 4399.230452] iwlagn 0000:06:00.0:                CSR_INT_MASK: 0X00000000
[ 4399.230457] iwlagn 0000:06:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 4399.230462] iwlagn 0000:06:00.0:                 CSR_GPIO_IN: 0X00000000
[ 4399.230467] iwlagn 0000:06:00.0:                   CSR_RESET: 0X00000000
[ 4399.230472] iwlagn 0000:06:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 4399.230477] iwlagn 0000:06:00.0:                  CSR_HW_REV: 0X00000054
[ 4399.230482] iwlagn 0000:06:00.0:              CSR_EEPROM_REG: 0X00000000
[ 4399.230487] iwlagn 0000:06:00.0:               CSR_EEPROM_GP: 0X90000004
[ 4399.230492] iwlagn 0000:06:00.0:              CSR_OTP_GP_REG: 0X00060000
[ 4399.230497] iwlagn 0000:06:00.0:                 CSR_GIO_REG: 0X00080044
[ 4399.230502] iwlagn 0000:06:00.0:            CSR_GP_UCODE_REG: 0X0000caea
[ 4399.230507] iwlagn 0000:06:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 4399.230512] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 4399.230517] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 4399.230522] iwlagn 0000:06:00.0:                 CSR_LED_REG: 0X00000058
[ 4399.230526] iwlagn 0000:06:00.0:        CSR_DRAM_INT_TBL_REG: 0X8815999a
[ 4399.230531] iwlagn 0000:06:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 4399.230536] iwlagn 0000:06:00.0:             CSR_ANA_PLL_CFG: 0X00880300
[ 4399.230541] iwlagn 0000:06:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 4399.230546] iwlagn 0000:06:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[ 4399.230548] iwlagn 0000:06:00.0: FH register values:
[ 4399.230561] iwlagn 0000:06:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X12fce100
[ 4399.230575] iwlagn 0000:06:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X012fdd20
[ 4399.230588] iwlagn 0000:06:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000c0
[ 4399.230602] iwlagn 0000:06:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
[ 4399.230615] iwlagn 0000:06:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 4399.230629] iwlagn 0000:06:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03630000
[ 4399.230642] iwlagn 0000:06:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 4399.230656] iwlagn 0000:06:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 4399.230669] iwlagn 0000:06:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 4399.230725] iwlagn 0000:06:00.0: Start IWL Event Log Dump: display last 20 entries
[ 4399.230743] iwlagn 0000:06:00.0: EVT_LOGT:0116988554:0x00000000:0302
[ 4399.230755] iwlagn 0000:06:00.0: EVT_LOGT:0116988577:0x00000440:0323
[ 4399.230767] iwlagn 0000:06:00.0: EVT_LOGT:0116988581:0x00000000:0355
[ 4399.230778] iwlagn 0000:06:00.0: EVT_LOGT:0116988582:0x00000480:0367
[ 4399.230789] iwlagn 0000:06:00.0: EVT_LOGT:0116988583:0x000008dc:0353
[ 4399.230800] iwlagn 0000:06:00.0: EVT_LOGT:0117003149:0x00000113:0106
[ 4399.230811] iwlagn 0000:06:00.0: EVT_LOGT:0117003150:0x00000000:0302
[ 4399.230823] iwlagn 0000:06:00.0: EVT_LOGT:0117003173:0x000008dd:0353
[ 4399.230834] iwlagn 0000:06:00.0: EVT_LOGT:0117015209:0x00000113:0106
[ 4399.230845] iwlagn 0000:06:00.0: EVT_LOGT:0117015211:0x00000000:0301
[ 4399.230855] iwlagn 0000:06:00.0: EVT_LOGT:0117015398:0x00000000:0355
[ 4399.230866] iwlagn 0000:06:00.0: EVT_LOGT:0117023110:0x00000113:0106
[ 4399.230877] iwlagn 0000:06:00.0: EVT_LOGT:0117023112:0x00000000:0302
[ 4399.230888] iwlagn 0000:06:00.0: EVT_LOGT:0117023135:0x00000440:0323
[ 4399.230898] iwlagn 0000:06:00.0: EVT_LOGT:0117023138:0x00000000:0355
[ 4399.230911] iwlagn 0000:06:00.0: EVT_LOGT:0117023139:0x00000480:0367
[ 4399.230921] iwlagn 0000:06:00.0: EVT_LOGT:0117023140:0x000008de:0353
[ 4399.230932] iwlagn 0000:06:00.0: EVT_LOGT:0117023406:0x000004b3:0511
[ 4399.230943] iwlagn 0000:06:00.0: EVT_LOGT:0117023407:0x00000006:0512
[ 4399.230953] iwlagn 0000:06:00.0: EVT_LOGT:0118023418:0x00000000:0125
[ 4399.231553] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4399.231555] iwlagn 0000:06:00.0: On demand firmware reload
[ 4399.235785] iwlagn 0000:06:00.0: Error: Response NULL in 'REPLY_ADD_STA'
[ 4399.235792] HW problem - can not stop rx aggregation for tid 0
[ 4399.235865] iwlagn 0000:06:00.0: Request scan called when driver not ready.
[ 4399.236056] ieee80211 phy0: Hardware restart was requested
[ 4463.229493] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4463.229498] iwlagn 0000:06:00.0: On demand firmware reload
[ 4463.231185] iwlagn 0000:06:00.0: fw recovery, no hcmd send
[ 4463.231189] iwlagn 0000:06:00.0: Error sending SENSITIVITY_CMD: enqueue_hcmd failed: -5
[ 4463.231240] ieee80211 phy0: Hardware restart was requested
[ 4527.227588] iwlagn 0000:06:00.0: Microcode SW error detected.  Restarting 0x82000000.
[ 4527.227593] iwlagn 0000:06:00.0: Loaded firmware version: 8.83.5.1 build 33692
[ 4527.227699] iwlagn 0000:06:00.0: Start IWL Error Log Dump:
[ 4527.227701] iwlagn 0000:06:00.0: Status: 0x0004B2E4, count: 5
[ 4527.227703] iwlagn 0000:06:00.0: 0x00000005 | SYSASSERT                   
[ 4527.227706] iwlagn 0000:06:00.0: 0x000024EC | uPc
[ 4527.227707] iwlagn 0000:06:00.0: 0x000024C8 | branchlink1
[ 4527.227709] iwlagn 0000:06:00.0: 0x000024C8 | branchlink2
[ 4527.227711] iwlagn 0000:06:00.0: 0x00000916 | interruptlink1
[ 4527.227713] iwlagn 0000:06:00.0: 0x00000000 | interruptlink2
[ 4527.227715] iwlagn 0000:06:00.0: 0x000000FF | data1
[ 4527.227716] iwlagn 0000:06:00.0: 0x00000489 | data2
[ 4527.227718] iwlagn 0000:06:00.0: 0x00000489 | line
[ 4527.227720] iwlagn 0000:06:00.0: 0x1C804DAB | beacon time
[ 4527.227722] iwlagn 0000:06:00.0: 0xCA2A7255 | tsf low
[ 4527.227724] iwlagn 0000:06:00.0: 0x00000018 | tsf hi
[ 4527.227725] iwlagn 0000:06:00.0: 0x00000000 | time gp1
[ 4527.227727] iwlagn 0000:06:00.0: 0x00B26334 | time gp2
[ 4527.227729] iwlagn 0000:06:00.0: 0x00000000 | time gp3
[ 4527.227731] iwlagn 0000:06:00.0: 0x00010853 | uCode version
[ 4527.227732] iwlagn 0000:06:00.0: 0x00000054 | hw version
[ 4527.227734] iwlagn 0000:06:00.0: 0x00480303 | board version
[ 4527.227736] iwlagn 0000:06:00.0: 0x0000001C | hcmd
[ 4527.227738] iwlagn 0000:06:00.0: CSR values:
[ 4527.227739] iwlagn 0000:06:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 4527.227745] iwlagn 0000:06:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
[ 4527.227750] iwlagn 0000:06:00.0:          CSR_INT_COALESCING: 0X00000040
[ 4527.227755] iwlagn 0000:06:00.0:                     CSR_INT: 0X00000000
[ 4527.227760] iwlagn 0000:06:00.0:                CSR_INT_MASK: 0X00000000
[ 4527.227765] iwlagn 0000:06:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 4527.227770] iwlagn 0000:06:00.0:                 CSR_GPIO_IN: 0X00000000
[ 4527.227775] iwlagn 0000:06:00.0:                   CSR_RESET: 0X00000000
[ 4527.227780] iwlagn 0000:06:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 4527.227785] iwlagn 0000:06:00.0:                  CSR_HW_REV: 0X00000054
[ 4527.227790] iwlagn 0000:06:00.0:              CSR_EEPROM_REG: 0X00000000
[ 4527.227795] iwlagn 0000:06:00.0:               CSR_EEPROM_GP: 0X90000004
[ 4527.227800] iwlagn 0000:06:00.0:              CSR_OTP_GP_REG: 0X00060000
[ 4527.227805] iwlagn 0000:06:00.0:                 CSR_GIO_REG: 0X00080044
[ 4527.227810] iwlagn 0000:06:00.0:            CSR_GP_UCODE_REG: 0X00005fa7
[ 4527.227816] iwlagn 0000:06:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 4527.227820] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 4527.227825] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 4527.227830] iwlagn 0000:06:00.0:                 CSR_LED_REG: 0X00000078
[ 4527.227835] iwlagn 0000:06:00.0:        CSR_DRAM_INT_TBL_REG: 0X8815999a
[ 4527.227840] iwlagn 0000:06:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 4527.227845] iwlagn 0000:06:00.0:             CSR_ANA_PLL_CFG: 0X00880300
[ 4527.227850] iwlagn 0000:06:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 4527.227855] iwlagn 0000:06:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[ 4527.227857] iwlagn 0000:06:00.0: FH register values:
[ 4527.227871] iwlagn 0000:06:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X12fce100
[ 4527.227885] iwlagn 0000:06:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X012fdd20
[ 4527.227899] iwlagn 0000:06:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000068
[ 4527.227913] iwlagn 0000:06:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
[ 4527.227926] iwlagn 0000:06:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 4527.227939] iwlagn 0000:06:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03630000
[ 4527.227954] iwlagn 0000:06:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 4527.227967] iwlagn 0000:06:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 4527.227980] iwlagn 0000:06:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 4527.228041] iwlagn 0000:06:00.0: Start IWL Event Log Dump: display last 20 entries
[ 4527.228059] iwlagn 0000:06:00.0: EVT_LOGT:0010686717:0x00000000:0301
[ 4527.228071] iwlagn 0000:06:00.0: EVT_LOGT:0010686791:0x000014e8:0353
[ 4527.228082] iwlagn 0000:06:00.0: EVT_LOGT:0010686824:0x00000113:0106
[ 4527.228094] iwlagn 0000:06:00.0: EVT_LOGT:0010686826:0x00000000:0301
[ 4527.228106] iwlagn 0000:06:00.0: EVT_LOGT:0010686901:0x000014e9:0353
[ 4527.228118] iwlagn 0000:06:00.0: EVT_LOGT:0010686924:0x00000113:0106
[ 4527.228129] iwlagn 0000:06:00.0: EVT_LOGT:0010686926:0x00000000:0301
[ 4527.228141] iwlagn 0000:06:00.0: EVT_LOGT:0010687030:0x000014ea:0353
[ 4527.228152] iwlagn 0000:06:00.0: EVT_LOGT:0010687073:0x00000113:0106
[ 4527.228163] iwlagn 0000:06:00.0: EVT_LOGT:0010687074:0x00000000:0301
[ 4527.228175] iwlagn 0000:06:00.0: EVT_LOGT:0010687254:0x000014eb:0353
[ 4527.228186] iwlagn 0000:06:00.0: EVT_LOGT:0010687282:0x00000113:0106
[ 4527.228197] iwlagn 0000:06:00.0: EVT_LOGT:0010687284:0x00000000:0301
[ 4527.228209] iwlagn 0000:06:00.0: EVT_LOGT:0010687358:0x000014ec:0353
[ 4527.228220] iwlagn 0000:06:00.0: EVT_LOGT:0010687442:0x00000113:0106
[ 4527.228231] iwlagn 0000:06:00.0: EVT_LOGT:0010687444:0x00000000:0301
[ 4527.228243] iwlagn 0000:06:00.0: EVT_LOGT:0010687520:0x000014ed:0353
[ 4527.228255] iwlagn 0000:06:00.0: EVT_LOGT:0010690795:0x000004b3:0511
[ 4527.228268] iwlagn 0000:06:00.0: EVT_LOGT:0010690796:0x0000000a:0512
[ 4527.228280] iwlagn 0000:06:00.0: EVT_LOGT:0011690808:0x00000000:0125
[ 4527.228996] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4527.228999] iwlagn 0000:06:00.0: On demand firmware reload
[ 4527.230429] ieee80211 phy0: Hardware restart was requested
[ 4554.924991] iwlagn 0000:06:00.0: Microcode SW error detected.  Restarting 0x82000000.
[ 4554.924996] iwlagn 0000:06:00.0: Loaded firmware version: 8.83.5.1 build 33692
[ 4554.925022] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4554.925025] iwlagn 0000:06:00.0: On demand firmware reload
[ 4554.925098] iwlagn 0000:06:00.0: Start IWL Error Log Dump:
[ 4554.925100] iwlagn 0000:06:00.0: Status: 0x00061264, count: 5
[ 4554.925103] iwlagn 0000:06:00.0: 0x00000005 | SYSASSERT                   
[ 4554.925105] iwlagn 0000:06:00.0: 0x000024EC | uPc
[ 4554.925107] iwlagn 0000:06:00.0: 0x000024C8 | branchlink1
[ 4554.925108] iwlagn 0000:06:00.0: 0x000024C8 | branchlink2
[ 4554.925110] iwlagn 0000:06:00.0: 0x00000916 | interruptlink1
[ 4554.925112] iwlagn 0000:06:00.0: 0x00000000 | interruptlink2
[ 4554.925114] iwlagn 0000:06:00.0: 0x000000FF | data1
[ 4554.925116] iwlagn 0000:06:00.0: 0x00000489 | data2
[ 4554.925118] iwlagn 0000:06:00.0: 0x00000489 | line
[ 4554.925119] iwlagn 0000:06:00.0: 0x1F004D85 | beacon time
[ 4554.925121] iwlagn 0000:06:00.0: 0xCE0AA27B | tsf low
[ 4554.925123] iwlagn 0000:06:00.0: 0x00000018 | tsf hi
[ 4554.925125] iwlagn 0000:06:00.0: 0x00000000 | time gp1
[ 4554.925127] iwlagn 0000:06:00.0: 0x00C1DC07 | time gp2
[ 4554.925128] iwlagn 0000:06:00.0: 0x00000000 | time gp3
[ 4554.925130] iwlagn 0000:06:00.0: 0x00010853 | uCode version
[ 4554.925132] iwlagn 0000:06:00.0: 0x00000054 | hw version
[ 4554.925134] iwlagn 0000:06:00.0: 0x00480303 | board version
[ 4554.925136] iwlagn 0000:06:00.0: 0x09560048 | hcmd
[ 4554.925138] iwlagn 0000:06:00.0: CSR values:
[ 4554.925139] iwlagn 0000:06:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 4554.925145] iwlagn 0000:06:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
[ 4554.925149] iwlagn 0000:06:00.0:          CSR_INT_COALESCING: 0X00000040
[ 4554.925154] iwlagn 0000:06:00.0:                     CSR_INT: 0X00000000
[ 4554.925159] iwlagn 0000:06:00.0:                CSR_INT_MASK: 0X00000000
[ 4554.925164] iwlagn 0000:06:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 4554.925169] iwlagn 0000:06:00.0:                 CSR_GPIO_IN: 0X00000000
[ 4554.925174] iwlagn 0000:06:00.0:                   CSR_RESET: 0X00000000
[ 4554.925179] iwlagn 0000:06:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 4554.925184] iwlagn 0000:06:00.0:                  CSR_HW_REV: 0X00000054
[ 4554.925189] iwlagn 0000:06:00.0:              CSR_EEPROM_REG: 0X00000000
[ 4554.925194] iwlagn 0000:06:00.0:               CSR_EEPROM_GP: 0X90000004
[ 4554.925199] iwlagn 0000:06:00.0:              CSR_OTP_GP_REG: 0X00060000
[ 4554.925204] iwlagn 0000:06:00.0:                 CSR_GIO_REG: 0X00080044
[ 4554.925209] iwlagn 0000:06:00.0:            CSR_GP_UCODE_REG: 0X0000dbbb
[ 4554.925214] iwlagn 0000:06:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 4554.925219] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 4554.925223] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 4554.925228] iwlagn 0000:06:00.0:                 CSR_LED_REG: 0X00000058
[ 4554.925233] iwlagn 0000:06:00.0:        CSR_DRAM_INT_TBL_REG: 0X8815999a
[ 4554.925238] iwlagn 0000:06:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 4554.925243] iwlagn 0000:06:00.0:             CSR_ANA_PLL_CFG: 0X00880300
[ 4554.925248] iwlagn 0000:06:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 4554.925253] iwlagn 0000:06:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[ 4554.925255] iwlagn 0000:06:00.0: FH register values:
[ 4554.925269] iwlagn 0000:06:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X12fce100
[ 4554.925283] iwlagn 0000:06:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X012fdd20
[ 4554.925298] iwlagn 0000:06:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000040
[ 4554.925312] iwlagn 0000:06:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
[ 4554.925328] iwlagn 0000:06:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 4554.925341] iwlagn 0000:06:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03630000
[ 4554.925355] iwlagn 0000:06:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 4554.925370] iwlagn 0000:06:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 4554.925383] iwlagn 0000:06:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 4554.925439] iwlagn 0000:06:00.0: Start IWL Event Log Dump: display last 20 entries
[ 4554.925458] iwlagn 0000:06:00.0: EVT_LOGT:0011704571:0x00000000:0355
[ 4554.925470] iwlagn 0000:06:00.0: EVT_LOGT:0011704571:0x00000480:0367
[ 4554.925482] iwlagn 0000:06:00.0: EVT_LOGT:0011704572:0x000006cb:0353
[ 4554.925494] iwlagn 0000:06:00.0: EVT_LOGT:0011704599:0x00000113:0106
[ 4554.925506] iwlagn 0000:06:00.0: EVT_LOGT:0011704601:0x00000000:0302
[ 4554.925518] iwlagn 0000:06:00.0: EVT_LOGT:0011704622:0x00000000:0355
[ 4554.925529] iwlagn 0000:06:00.0: EVT_LOGT:0011704633:0x00000000:0302
[ 4554.925541] iwlagn 0000:06:00.0: EVT_LOGT:0011704654:0x00000440:0323
[ 4554.925553] iwlagn 0000:06:00.0: EVT_LOGT:0011704658:0x00000000:0355
[ 4554.925564] iwlagn 0000:06:00.0: EVT_LOGT:0011704659:0x00000480:0367
[ 4554.925576] iwlagn 0000:06:00.0: EVT_LOGT:0011704660:0x000006cc:0353
[ 4554.925587] iwlagn 0000:06:00.0: EVT_LOGT:0011704721:0x00000113:0106
[ 4554.925598] iwlagn 0000:06:00.0: EVT_LOGT:0011704722:0x00000000:0302
[ 4554.925609] iwlagn 0000:06:00.0: EVT_LOGT:0011704745:0x00000440:0323
[ 4554.925620] iwlagn 0000:06:00.0: EVT_LOGT:0011704748:0x00000000:0355
[ 4554.925632] iwlagn 0000:06:00.0: EVT_LOGT:0011704749:0x00000480:0367
[ 4554.925643] iwlagn 0000:06:00.0: EVT_LOGT:0011704750:0x000006cd:0353
[ 4554.925654] iwlagn 0000:06:00.0: EVT_LOGT:0011704769:0x000004b3:0511
[ 4554.925665] iwlagn 0000:06:00.0: EVT_LOGT:0011704770:0x0000000a:0512
[ 4554.925676] iwlagn 0000:06:00.0: EVT_LOGT:0012704780:0x00000000:0125
[ 4554.926336] iwlagn 0000:06:00.0: fw recovery, no hcmd send
[ 4554.926339] iwlagn 0000:06:00.0: Error sending SENSITIVITY_CMD: enqueue_hcmd failed: -5
[ 4554.926712] ieee80211 phy0: Hardware restart was requested
[ 4618.071517] iwlagn 0000:06:00.0: Microcode SW error detected.  Restarting 0x82000000.
[ 4618.071522] iwlagn 0000:06:00.0: Loaded firmware version: 8.83.5.1 build 33692
[ 4618.071584] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4618.071587] iwlagn 0000:06:00.0: On demand firmware reload
[ 4618.071638] iwlagn 0000:06:00.0: Start IWL Error Log Dump:
[ 4618.071641] iwlagn 0000:06:00.0: Status: 0x00061264, count: 5
[ 4618.071643] iwlagn 0000:06:00.0: 0x00000005 | SYSASSERT                   
[ 4618.071645] iwlagn 0000:06:00.0: 0x000024EC | uPc
[ 4618.071647] iwlagn 0000:06:00.0: 0x000024C8 | branchlink1
[ 4618.071649] iwlagn 0000:06:00.0: 0x000024C8 | branchlink2
[ 4618.071650] iwlagn 0000:06:00.0: 0x00000916 | interruptlink1
[ 4618.071652] iwlagn 0000:06:00.0: 0x00000000 | interruptlink2
[ 4618.071654] iwlagn 0000:06:00.0: 0x000000FF | data1
[ 4618.071656] iwlagn 0000:06:00.0: 0x00000489 | data2
[ 4618.071657] iwlagn 0000:06:00.0: 0x00000489 | line
[ 4618.071659] iwlagn 0000:06:00.0: 0x7A404DAB | beacon time
[ 4618.071661] iwlagn 0000:06:00.0: 0xD1EAD255 | tsf low
[ 4618.071662] iwlagn 0000:06:00.0: 0x00000018 | tsf hi
[ 4618.071664] iwlagn 0000:06:00.0: 0x00000000 | time gp1
[ 4618.071666] iwlagn 0000:06:00.0: 0x02FB7D43 | time gp2
[ 4618.071667] iwlagn 0000:06:00.0: 0x00000000 | time gp3
[ 4618.071669] iwlagn 0000:06:00.0: 0x00010853 | uCode version
[ 4618.071671] iwlagn 0000:06:00.0: 0x00000054 | hw version
[ 4618.071673] iwlagn 0000:06:00.0: 0x00480303 | board version
[ 4618.071675] iwlagn 0000:06:00.0: 0x090A00A8 | hcmd
[ 4618.071676] iwlagn 0000:06:00.0: CSR values:
[ 4618.071678] iwlagn 0000:06:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 4618.071683] iwlagn 0000:06:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
[ 4618.071688] iwlagn 0000:06:00.0:          CSR_INT_COALESCING: 0X00000040
[ 4618.071693] iwlagn 0000:06:00.0:                     CSR_INT: 0X00000000
[ 4618.071698] iwlagn 0000:06:00.0:                CSR_INT_MASK: 0X00000000
[ 4618.071703] iwlagn 0000:06:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 4618.071708] iwlagn 0000:06:00.0:                 CSR_GPIO_IN: 0X00000000
[ 4618.071713] iwlagn 0000:06:00.0:                   CSR_RESET: 0X00000000
[ 4618.071718] iwlagn 0000:06:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 4618.071723] iwlagn 0000:06:00.0:                  CSR_HW_REV: 0X00000054
[ 4618.071728] iwlagn 0000:06:00.0:              CSR_EEPROM_REG: 0X00000000
[ 4618.071733] iwlagn 0000:06:00.0:               CSR_EEPROM_GP: 0X90000004
[ 4618.071738] iwlagn 0000:06:00.0:              CSR_OTP_GP_REG: 0X00060000
[ 4618.071743] iwlagn 0000:06:00.0:                 CSR_GIO_REG: 0X00080044
[ 4618.071748] iwlagn 0000:06:00.0:            CSR_GP_UCODE_REG: 0X00000c18
[ 4618.071753] iwlagn 0000:06:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 4618.071758] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 4618.071763] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 4618.071767] iwlagn 0000:06:00.0:                 CSR_LED_REG: 0X00000058
[ 4618.071773] iwlagn 0000:06:00.0:        CSR_DRAM_INT_TBL_REG: 0X8815999a
[ 4618.071777] iwlagn 0000:06:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 4618.071782] iwlagn 0000:06:00.0:             CSR_ANA_PLL_CFG: 0X00880300
[ 4618.071787] iwlagn 0000:06:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 4618.071792] iwlagn 0000:06:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[ 4618.071794] iwlagn 0000:06:00.0: FH register values:
[ 4618.071807] iwlagn 0000:06:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X12fce100
[ 4618.071821] iwlagn 0000:06:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X012fdd20
[ 4618.071834] iwlagn 0000:06:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000d0
[ 4618.071847] iwlagn 0000:06:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
[ 4618.071861] iwlagn 0000:06:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 4618.071876] iwlagn 0000:06:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03630000
[ 4618.071889] iwlagn 0000:06:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 4618.071902] iwlagn 0000:06:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 4618.071916] iwlagn 0000:06:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 4618.071969] iwlagn 0000:06:00.0: Start IWL Event Log Dump: display last 20 entries
[ 4618.071986] iwlagn 0000:06:00.0: EVT_LOGT:0048963194:0x00000113:0106
[ 4618.071997] iwlagn 0000:06:00.0: EVT_LOGT:0048963196:0x00000000:0302
[ 4618.072009] iwlagn 0000:06:00.0: EVT_LOGT:0048963219:0x00000440:0323
[ 4618.072022] iwlagn 0000:06:00.0: EVT_LOGT:0048963223:0x00000000:0355
[ 4618.072033] iwlagn 0000:06:00.0: EVT_LOGT:0048963224:0x00000480:0367
[ 4618.072045] iwlagn 0000:06:00.0: EVT_LOGT:0048963225:0x0000095d:0353
[ 4618.072055] iwlagn 0000:06:00.0: EVT_LOGT:0048995462:0x00000113:0106
[ 4618.072066] iwlagn 0000:06:00.0: EVT_LOGT:0048995464:0x00000000:0302
[ 4618.072076] iwlagn 0000:06:00.0: EVT_LOGT:0048995487:0x0000095e:0353
[ 4618.072087] iwlagn 0000:06:00.0: EVT_LOGT:0049014184:0x00000113:0106
[ 4618.072097] iwlagn 0000:06:00.0: EVT_LOGT:0049014186:0x00000000:0302
[ 4618.072110] iwlagn 0000:06:00.0: EVT_LOGT:0049014207:0x0000095f:0353
[ 4618.072120] iwlagn 0000:06:00.0: EVT_LOGT:0049027827:0x00000113:0106
[ 4618.072132] iwlagn 0000:06:00.0: EVT_LOGT:0049027829:0x00000000:0301
[ 4618.072159] iwlagn 0000:06:00.0: EVT_LOGT:0049028016:0x00000000:0355
[ 4618.072170] iwlagn 0000:06:00.0: EVT_LOGT:0049031820:0x000001da:0601
[ 4618.072180] iwlagn 0000:06:00.0: EVT_LOGT:0049031821:0x000001df:0632
[ 4618.072192] iwlagn 0000:06:00.0: EVT_LOGT:0049036027:0x000004b3:0511
[ 4618.072203] iwlagn 0000:06:00.0: EVT_LOGT:0049036028:0x00000007:0512
[ 4618.072215] iwlagn 0000:06:00.0: EVT_LOGT:0050036040:0x00000000:0125
[ 4618.072857] iwlagn 0000:06:00.0: fw recovery, no hcmd send
[ 4618.072860] iwlagn 0000:06:00.0: Error sending SENSITIVITY_CMD: enqueue_hcmd failed: -5
[ 4618.072933] ieee80211 phy0: Hardware restart was requested
[ 4618.073773] iwlagn 0000:06:00.0: Request scan called when driver not ready.
[ 4655.133756] iwlagn 0000:06:00.0: Queue 9 stuck for 10000 ms.
[ 4655.133760] iwlagn 0000:06:00.0: On demand firmware reload
[ 4655.135500] ieee80211 phy0: Hardware restart was requested
[ 4719.223633] iwlagn 0000:06:00.0: Microcode SW error detected.  Restarting 0x82000000.
[ 4719.223638] iwlagn 0000:06:00.0: Loaded firmware version: 8.83.5.1 build 33692
[ 4719.223743] iwlagn 0000:06:00.0: Start IWL Error Log Dump:
[ 4719.223746] iwlagn 0000:06:00.0: Status: 0x000412E4, count: 5
[ 4719.223748] iwlagn 0000:06:00.0: 0x00000005 | SYSASSERT                   
[ 4719.223750] iwlagn 0000:06:00.0: 0x000024EC | uPc
[ 4719.223752] iwlagn 0000:06:00.0: 0x000024C8 | branchlink1
[ 4719.223754] iwlagn 0000:06:00.0: 0x000024C8 | branchlink2
[ 4719.223756] iwlagn 0000:06:00.0: 0x00000916 | interruptlink1
[ 4719.223757] iwlagn 0000:06:00.0: 0x00000000 | interruptlink2
[ 4719.223759] iwlagn 0000:06:00.0: 0x000000FF | data1
[ 4719.223761] iwlagn 0000:06:00.0: 0x00000489 | data2
[ 4719.223763] iwlagn 0000:06:00.0: 0x00000489 | line
[ 4719.223765] iwlagn 0000:06:00.0: 0x46404DA9 | beacon time
[ 4719.223766] iwlagn 0000:06:00.0: 0xD6A11257 | tsf low
[ 4719.223768] iwlagn 0000:06:00.0: 0x00000018 | tsf hi
[ 4719.223770] iwlagn 0000:06:00.0: 0x00000000 | time gp1
[ 4719.223772] iwlagn 0000:06:00.0: 0x01B8C086 | time gp2
[ 4719.223774] iwlagn 0000:06:00.0: 0x00000000 | time gp3
[ 4719.223775] iwlagn 0000:06:00.0: 0x00010853 | uCode version
[ 4719.223777] iwlagn 0000:06:00.0: 0x00000054 | hw version
[ 4719.223779] iwlagn 0000:06:00.0: 0x00480303 | board version
[ 4719.223781] iwlagn 0000:06:00.0: 0x096A0048 | hcmd
[ 4719.223783] iwlagn 0000:06:00.0: CSR values:
[ 4719.223785] iwlagn 0000:06:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 4719.223790] iwlagn 0000:06:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
[ 4719.223795] iwlagn 0000:06:00.0:          CSR_INT_COALESCING: 0X00000040
[ 4719.223800] iwlagn 0000:06:00.0:                     CSR_INT: 0X00000000
[ 4719.223805] iwlagn 0000:06:00.0:                CSR_INT_MASK: 0X00000000
[ 4719.223810] iwlagn 0000:06:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 4719.223815] iwlagn 0000:06:00.0:                 CSR_GPIO_IN: 0X00000000
[ 4719.223820] iwlagn 0000:06:00.0:                   CSR_RESET: 0X00000000
[ 4719.223825] iwlagn 0000:06:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 4719.223830] iwlagn 0000:06:00.0:                  CSR_HW_REV: 0X00000054
[ 4719.223835] iwlagn 0000:06:00.0:              CSR_EEPROM_REG: 0X00000000
[ 4719.223840] iwlagn 0000:06:00.0:               CSR_EEPROM_GP: 0X90000004
[ 4719.223845] iwlagn 0000:06:00.0:              CSR_OTP_GP_REG: 0X00060000
[ 4719.223850] iwlagn 0000:06:00.0:                 CSR_GIO_REG: 0X00080044
[ 4719.223855] iwlagn 0000:06:00.0:            CSR_GP_UCODE_REG: 0X0000ccc4
[ 4719.223860] iwlagn 0000:06:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 4719.223865] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 4719.223870] iwlagn 0000:06:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 4719.223875] iwlagn 0000:06:00.0:                 CSR_LED_REG: 0X00000058
[ 4719.223880] iwlagn 0000:06:00.0:        CSR_DRAM_INT_TBL_REG: 0X8815999a
[ 4719.223885] iwlagn 0000:06:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 4719.223890] iwlagn 0000:06:00.0:             CSR_ANA_PLL_CFG: 0X00880300
[ 4719.223895] iwlagn 0000:06:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 4719.223900] iwlagn 0000:06:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[ 4719.223902] iwlagn 0000:06:00.0: FH register values:
[ 4719.223916] iwlagn 0000:06:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X12fce100
[ 4719.223930] iwlagn 0000:06:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X012fdd20
[ 4719.223945] iwlagn 0000:06:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000050
[ 4719.223959] iwlagn 0000:06:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
[ 4719.223973] iwlagn 0000:06:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 4719.223987] iwlagn 0000:06:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03630000
[ 4719.224010] iwlagn 0000:06:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 4719.224023] iwlagn 0000:06:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 4719.224037] iwlagn 0000:06:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 4719.224093] iwlagn 0000:06:00.0: Start IWL Event Log Dump: display last 20 entries
[ 4719.224112] iwlagn 0000:06:00.0: EVT_LOGT:0027857715:0x00000000:0355
[ 4719.224123] iwlagn 0000:06:00.0: EVT_LOGT:0027857716:0x00000480:0367
[ 4719.224134] iwlagn 0000:06:00.0: EVT_LOGT:0027857717:0x00000eb6:0353
[ 4719.224145] iwlagn 0000:06:00.0: EVT_LOGT:0027858498:0x00000113:0106
[ 4719.224156] iwlagn 0000:06:00.0: EVT_LOGT:0027858499:0x00000000:0302
[ 4719.224168] iwlagn 0000:06:00.0: EVT_LOGT:0027858521:0x00000eb7:0353
[ 4719.224180] iwlagn 0000:06:00.0: EVT_LOGT:0027858550:0x00000113:0106
[ 4719.224192] iwlagn 0000:06:00.0: EVT_LOGT:0027858552:0x00000000:0302
[ 4719.224202] iwlagn 0000:06:00.0: EVT_LOGT:0027858574:0x00000eb8:0353
[ 4719.224214] iwlagn 0000:06:00.0: EVT_LOGT:0027875938:0x00000113:0106
[ 4719.224225] iwlagn 0000:06:00.0: EVT_LOGT:0027875939:0x00000000:0302
[ 4719.224237] iwlagn 0000:06:00.0: EVT_LOGT:0027875962:0x00000eb9:0353
[ 4719.224248] iwlagn 0000:06:00.0: EVT_LOGT:0027876916:0x00000113:0106
[ 4719.224271] iwlagn 0000:06:00.0: EVT_LOGT:0027876918:0x00000000:0301
[ 4719.224282] iwlagn 0000:06:00.0: EVT_LOGT:0027877106:0x00000000:0355
[ 4719.224294] iwlagn 0000:06:00.0: EVT_LOGT:0027880908:0x000001da:0601
[ 4719.224305] iwlagn 0000:06:00.0: EVT_LOGT:0027880909:0x0000010f:0632
[ 4719.224316] iwlagn 0000:06:00.0: EVT_LOGT:0027885117:0x000004b3:0511
[ 4719.224328] iwlagn 0000:06:00.0: EVT_LOGT:0027885118:0x00000007:0512
[ 4719.224339] iwlagn 0000:06:00.0: EVT_LOGT:0028885130:0x00000000:0125
[ 4719.225112] iwlagn 0000:06:00.0: fw recovery, no hcmd send
[ 4719.225115] iwlagn 0000:06:00.0: Error sending SENSITIVITY_CMD: enqueue_hcmd failed: -5
[ 4719.225205] ieee80211 phy0: Hardware restart was requested
[ 4719.227271] iwlagn 0000:06:00.0: Request scan called when driver not ready.

--nextPart1703242.9C23h8g3pK--
