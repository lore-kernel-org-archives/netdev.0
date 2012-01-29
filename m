From: Ben Hutchings <ben@decadent.org.uk>
Subject: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Sun, 29 Jan 2012 04:23:09 +0000
Message-ID: <1327810989.5400.290.camel@deadeye>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	,<1327205171.8004.96.camel@deadeye>
	,<SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	,<20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xoD8hCNqPntjDnO3iOLz"
Cc: "Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37827 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752954Ab2A2EXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 23:23:19 -0500
In-Reply-To: <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xoD8hCNqPntjDnO3iOLz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Denis,

It looks like you were working on sundance for a while; are you still
interested in it?

Mike reported that:
> Network traffic on my D-Link DFE-580TX card results in a transmit
> queue timeout and gives endless resets after that untill the interface
> is brought down.
>=20
> The amount of traffic required to generate the error seems to vary but
> sooner rather then later it will occur.

and the messages logged under Linux 3.2.1 are:

> [  430.008026] ------------[ cut here ]------------
> [  430.008100] WARNING:
> at /build/buildd-linux-2.6_3.2.1-2-i386-4wAPNj/linux-2.6-3.2.1/debian/bui=
ld/source_i386_none/net/sched/sch_generic.c:255 dev_watchdog+0xb1/0x104()
> [  430.008200] Hardware name:
> [  430.008251] NETDEV WATCHDOG: eth1 (sundance): transmit queue 0
> timed out
> [  430.008307] Modules linked in: p4_clockmod cpufreq_powersave
> cpufreq_userspace cpufreq_conservative cpufreq_stats speedstep_lib
> mperf fuse w83627ehf hwmon_vid coretemp loop snd_intel8x0
> snd_ac97_codec ac97_bus snd_pcm snd_seq snd_time
> r snd_seq_device ohci_hcd ehci_hcd tpm_tis sis900 sundance tpm usbcore
> tpm_bios pcspkr psmouse snd parport_pc evdev serio_raw parport mii
> button usb_common soundcore processor shpchp pci_hotplug thermal_sys
> snd_page_alloc ext3 jbd mbcach
> e sd_mod crc_t10dif sata_sis ata_generic pata_sis libata scsi_mod
> [  430.010093] Pid: 0, comm: swapper/0 Not tainted 3.2.0-1-686-pae #1
> [  430.010149] Call Trace:
> [  430.010203]  [<c1038280>] ? warn_slowpath_common+0x68/0x79
> [  430.010260]  [<c1229e38>] ? dev_watchdog+0xb1/0x104
> [  430.010314]  [<c10382f9>] ? warn_slowpath_fmt+0x29/0x2d
> [  430.010370]  [<c1229e38>] ? dev_watchdog+0xb1/0x104
> [  430.010428]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
> [  430.010484]  [<c1041e78>] ? run_timer_softirq+0x150/0x1f3
> [  430.010539]  [<c1229d87>] ? netif_tx_unlock+0x3a/0x3a
> [  430.010595]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
> [  430.010649]  [<c103cd49>] ? __do_softirq+0x94/0x12f
> [  430.010704]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
> [  430.010757]  <IRQ>  [<c103cf3a>] ? irq_exit+0x32/0x80
> [  430.010847]  [<c101e6f4>] ? smp_apic_timer_interrupt+0x5b/0x65
> [  430.010906]  [<c12b9b11>] ? apic_timer_interrupt+0x31/0x38
> [  430.010963]  [<c120007b>] ? rtc_proc_show+0x15e/0x22d
> [  430.011020]  [<c1010e5a>] ? mwait_idle+0x65/0x8b
> [  430.011076]  [<c100b234>] ? cpu_idle+0x95/0xaf
> [  430.011132]  [<c1412708>] ? start_kernel+0x32a/0x32f
> [  430.011185] ---[ end trace 4f9c55881a85ddc2 ]---
> [  430.011244] eth1: Transmit timed out, TxStatus 00 TxFrameId 1a,
> resetting...
> [  430.011302] 00 35afc000 35afc010 00008001(00) 34c2d802 800005ea
> [  430.011307] 01 35afc010 35afc020 00000005(01) 34cfc802 800005ea
> [  430.011311] 02 35afc020 35afc030 00008009(02) 357ca802 800005ea
> [  430.011316] 03 35afc030 35afc040 0000000d(03) 34d01802 800005ea
> [  430.011320] 04 35afc040 35afc050 00008011(04) 34d00002 800005ea
> [  430.011324] 05 35afc050 35afc060 00000015(05) 35a9f802 800005ea
> [  430.011328] 06 35afc060 35afc070 00008019(06) 34c75002 800005ea
> [  430.011333] 07 35afc070 35afc080 0000001d(07) 35ac0002 800005ea
> [  430.011337] 08 35afc080 35afc090 00008021(08) 34d4e802 800005ea
> [  430.011341] 09 35afc090 35afc0a0 00000025(09) 357b0002 800005ea
> [  430.011346] 0a 35afc0a0 35afc0b0 00008029(0a) 34d66802 800005ea
> [  430.011350] 0b 35afc0b0 35afc0c0 0000002d(0b) 354f2802 800005ea
> [  430.011354] 0c 35afc0c0 35afc0d0 00008031(0c) 34d04802 800005ea
> [  430.011359] 0d 35afc0d0 35afc0e0 00000035(0d) 34cd1002 800005ea
> [  430.011363] 0e 35afc0e0 35afc0f0 00008039(0e) 34cc9802 800005ea
> [  430.011367] 0f 35afc0f0 35afc100 0000003d(0f) 34d3d002 800005ea
> [  430.011371] 10 35afc100 35afc110 00008041(10) 355d3002 800005ea
> [  430.011376] 11 35afc110 35afc120 00000045(11) 34d02802 800005ea
> [  430.011380] 12 35afc120 35afc130 00008049(12) 34d8b002 800005ea
> [  430.011384] 13 35afc130 35afc140 0000004d(13) 34cc9002 800005ea
> [  430.011389] 14 35afc140 35afc150 00008051(14) 34d51002 800005ea
> [  430.011393] 15 35afc150 35afc160 00000055(15) 357c7802 800005ea
> [  430.011397] 16 35afc160 00000000 00008059(16) 34d4f002 800005ea
> [  430.011401] 17 35afc170 35afc180 0001805d(17) 00000000 00000000
> [  430.011406] 18 35afc180 35afc190 00018061(18) 00000000 00000000
> [  430.011410] 19 35afc190 35afc1a0 00018065(19) 00000000 00000000
> [  430.011414] 1a 35afc1a0 35afc1b0 00018069(1a) 00000000 00000000
> [  430.011419] 1b 35afc1b0 35afc1c0 0000806d(1b) 34eea002 800005ea
> [  430.011423] 1c 35afc1c0 35afc1d0 00008071(1c) 355d9802 800005ea
> [  430.011427] 1d 35afc1d0 35afc1e0 00008075(1d) 34d19002 800005ea
> [  430.011431] 1e 35afc1e0 35afc1f0 00008079(1e) 354e4002 800005ea
> [  430.011436] 1f 35afc1f0 35afc000 0000007d(1f) 354ea002 800005ea
> [  430.011440] TxListPtr=3D35afc1b0 netif_queue_stopped=3D1
> [  430.011444] cur_tx=3D154807(17) dirty_tx=3D154779(1b)
> [  430.011447] cur_rx=3D0 dirty_rx=3D0
> [  430.011449] cur_task=3D154807
> [  438.008046] eth1: Transmit timed out, TxStatus 00 TxFrameId 00,
> resetting...
> [  438.008115] 00 35afc000 35afc010 00010001(00) 00000000 00000000
> [  438.008120] 01 35afc010 35afc020 00008005(01) 34cd3802 800005ea
> [  438.008124] 02 35afc020 35afc030 00000009(02) 34cce802 800005ea
> [  438.008129] 03 35afc030 35afc040 0000800d(03) 34f2b802 800005ea
> [  438.008133] 04 35afc040 35afc050 00000011(04) 34d40002 800005ea
> [  438.008137] 05 35afc050 35afc060 00008015(05) 34eff002 800005ea
> [  438.008142] 06 35afc060 35afc070 00000019(06) 34d5e002 800005ea
> [  438.008146] 07 35afc070 35afc080 0000801d(07) 357c4802 800005ea
> [  438.008150] 08 35afc080 35afc090 00000021(08) 34d8f802 800005ea
> [  438.008155] 09 35afc090 35afc0a0 00000025(09) 34d57802 800005ea
> [  438.008159] 0a 35afc0a0 35afc0b0 00000029(0a) 34ca7802 800005ea
> [  438.008163] 0b 35afc0b0 35afc0c0 0000002d(0b) 34c21802 800005ea
> [  438.008168] 0c 35afc0c0 35afc0d0 00000031(0c) 34d41802 800005ea
> [  438.008172] 0d 35afc0d0 35afc0e0 00000035(0d) 35406402 800001ad
> [  438.008176] 0e 35afc0e0 35afc0f0 00000039(0e) 34d14802 800005ea
> [  438.008181] 0f 35afc0f0 35afc100 0000003d(0f) 34e34002 800005ea
> [  438.008185] 10 35afc100 35afc110 00000041(10) 34cd1802 800005ea
> [  438.008189] 11 35afc110 35afc120 00000045(11) 355db802 800005ea
> [  438.008193] 12 35afc120 35afc130 00000049(12) 3541c802 800005ea
> [  438.008198] 13 35afc130 35afc140 0000004d(13) 34ca5802 800005ea
> [  438.008202] 14 35afc140 35afc150 00000051(14) 34ccb002 800005ea
> [  438.008206] 15 35afc150 35afc160 00000055(15) 34ef4002 800005ea
> [  438.008210] 16 35afc160 35afc170 00000059(16) 34c1a802 800005ea
> [  438.008215] 17 35afc170 35afc180 0000005d(17) 34ef4802 800005ea
> [  438.008219] 18 35afc180 35afc190 00000061(18) 34e25002 800005ea
> [  438.008223] 19 35afc190 35afc1a0 00000065(19) 34d4e002 800005ea
> [  438.008228] 1a 35afc1a0 35afc1b0 00000069(1a) 357b5002 800005ea
> [  438.008232] 1b 35afc1b0 35afc1c0 0000006d(1b) 34ce1002 800005ea
> [  438.008236] 1c 35afc1c0 35afc1d0 00000071(1c) 357bc002 800005ea
> [  438.008241] 1d 35afc1d0 00000000 00008075(1d) 34c73002 800005ea
> [  438.008245] 1e 35afc1e0 00000000 00008079(1e) 354e4002 800005ea
> [  438.008249] 1f 35afc1f0 00000000 0000007d(1f) 354ea002 800005ea
> [  438.008254] TxListPtr=3D35afc010 netif_queue_stopped=3D1
> [  438.008257] cur_tx=3D30(1e) dirty_tx=3D1(01)
> [  438.008260] cur_rx=3D5 dirty_rx=3D5
> [  438.008263] cur_task=3D30

Some more details are at <http://bugs.debian.org/656476>.

Ben.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.

--=-xoD8hCNqPntjDnO3iOLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATyTJree/yOyVhhEJAQoXzxAAmGYJs7MzCgNNz316Te6I8saSGZWF0Gtd
HLfAtZPNW5ipQ+Ho+SvWvq6T6lOUnGYsZkfKd1G+1j6x6TuxlfgjgJxiYyRgI6dT
/RZirHBrCJxfU3/K2PoWev73tm6Ju4jYUmQgWHgXEdYnAtCKbscHEC4IoQjoIoY+
CyVCMShYpe4c5JpKDwIXhTKKIztI8Ls7VmmT0lGq0AeCNMOPSyW/X5Y9uU/tStDs
ik/lgoLFcioXksYs/SNUjNCTAbUezKj3dn+YuS8dHIrWFJpS/VtjBAERU34L4sWR
63tRC4qaCEo8vcSX71jZ4xrwVzq+jW2mbVzy2PqhAwqhqRxPZZN5z6sEGuY4qFnP
vi9CXvdHHaDVFQsaHuK4DRhnIwi9mwrwYoFAS0xNToIPTcjzcF6y/9DcwNgk3+Vs
NYJgaiBx6XzyEsJ3BUbCu+Rd/hw9XkQyxJ7Wq9+FXwo0hGh5qwrjDXQCt3HeF4Sh
UIHmVAG4NGblZp0/PvvlSyKWF2/rnGZK/joGviPf3PrYRx1wsEFjUpehd634CfV2
3TpfotX21Wg5h3usUIs2HFZv0Ki6GmE4U0ced7fSowkGejdr0C2k1pHiYxj1B4Ra
Y7gyryRjAQcoXzPDtz2jd/KOJ2iAv1NvsIp/BV2EgBHNtOHVDa2ZhPJLJaCE+Q/j
HU38QhH7j1g=
=H84E
-----END PGP SIGNATURE-----

--=-xoD8hCNqPntjDnO3iOLz--
