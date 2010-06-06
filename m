From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#584724: linux-image-2.6.32-5-amd64: NETDEV WATCHDOG:
 (via-rhine): transmit queue 0 timed out
Date: Sun, 06 Jun 2010 22:23:45 +0100
Message-ID: <1275859426.10677.69.camel@localhost>
References: <20100606024158.12393.82960.reportbug@buzz.bailey>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-EUKBFHD9tEbeQsSUVs5Q"
Cc: netdev@vger.kernel.org, "R. Scott Bailey" <scott@cartasoft.com>,
	584724@bugs.debian.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34767 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754156Ab0FFVYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 17:24:04 -0400
In-Reply-To: <20100606024158.12393.82960.reportbug@buzz.bailey>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EUKBFHD9tEbeQsSUVs5Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Roger,

There's some kind of TX lock-up bug in via-rhine (or more likely certain
variants of the hardware).

On Sat, 2010-06-05 at 22:41 -0400, R. Scott Bailey wrote:
> Package: linux-2.6
> Version: 2.6.32-15
> Severity: normal
>=20
> This appears to be the same bug as:
>  https://bugzilla.kernel.org/show_bug.cgi?id=3D11663
>=20
> I have attached kernel output; once the timeout occurs, the interface is
> unusable and bounces spastically (without becoming operational) until the
> system is rebooted. This most often is triggered by samba traffic, but th=
at
> could be because that is just the heaviest traffic on my system. ;-)
>=20
> BTW, this interface is reported by lspci as:
> 00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (re=
v 7c)
>=20
> Double-BTW, this is not a new problem with 2.6.32, but our activity level=
s
> have picked up recently and trigger it more frequently.

Here's that attachment inline:

> Jun  5 21:01:57 buzz kernel: [104288.805044] WARNING: at /build/buildd-li=
nux-2.6_2.6.32-15-i386-fb7Hfg/linux-2.6-2.6.32/debian/build/source_i386_non=
e/net/sched/sch_generic.c:261 dev_watchdog+0xd2/0x16f()
> Jun  5 21:01:57 buzz kernel: [104288.805052] Hardware name: MS-7253
> Jun  5 21:01:57 buzz kernel: [104288.805057] NETDEV WATCHDOG: eth0 (via-r=
hine): transmit queue 0 timed out
> Jun  5 21:01:57 buzz kernel: [104288.805062] Modules linked in: tcp_diag =
inet_diag ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs xfs via drm ip=
6_tables ppdev lp xt_multiport iptable_filter ip_tables x_tables kvm_amd kv=
m powernow_k8 cpufreq_stats cpufreq_powersave cpufreq_userspace cpufreq_con=
servative dm_snapshot dm_mirror dm_region_hash dm_log fuse nfsd exportfs nf=
s lockd fscache nfs_acl auth_rpcgss sunrpc ext3 jbd ext2 snd_hda_codec_real=
tek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm=
 snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_devi=
ce snd soundcore snd_page_alloc psmouse i2c_viapro tpm_tis evdev tpm k8temp=
 tpm_bios edac_core pcspkr serio_raw i2c_core edac_mce_amd parport_pc parpo=
rt shpchp pci_hotplug button processor sha256_generic aes_x86_64 aes_generi=
c cbc ext4 mbcache jbd2 crc16 dm_crypt raid1 md_mod reiserfs dm_mod usb_sto=
rage usbhid hid sg sr_mod cdrom st sd_mod crc_t10dif osst ata_generic sata_=
via thermal uhci_
>  hcd via_rhine pata_via atp870u tul
> Jun  5 21:01:57 buzz kernel: p libata ehci_hcd thermal_sys mii usbcore nl=
s_base scsi_mod [last unloaded: scsi_wait_scan]
> Jun  5 21:01:57 buzz kernel: [104288.805243] Pid: 0, comm: swapper Not ta=
inted 2.6.32-5-amd64 #1
> Jun  5 21:01:57 buzz kernel: [104288.805248] Call Trace:
> Jun  5 21:01:57 buzz kernel: [104288.805253]  <IRQ>  [<ffffffff8125defb>]=
 ? dev_watchdog+0xd2/0x16f
> Jun  5 21:01:57 buzz kernel: [104288.805268]  [<ffffffff8125defb>] ? dev_=
watchdog+0xd2/0x16f
> Jun  5 21:01:57 buzz kernel: [104288.805278]  [<ffffffff8104db48>] ? warn=
_slowpath_common+0x77/0xa3
> Jun  5 21:01:57 buzz kernel: [104288.805285]  [<ffffffff8125de29>] ? dev_=
watchdog+0x0/0x16f
> Jun  5 21:01:57 buzz kernel: [104288.805292]  [<ffffffff8104dbd0>] ? warn=
_slowpath_fmt+0x51/0x59
> Jun  5 21:01:57 buzz kernel: [104288.805304]  [<ffffffff8104a046>] ? try_=
to_wake_up+0x249/0x259
> Jun  5 21:01:57 buzz kernel: [104288.805314]  [<ffffffff81064853>] ? auto=
remove_wake_function+0x9/0x2e
> Jun  5 21:01:57 buzz kernel: [104288.805321]  [<ffffffff8125ddfd>] ? neti=
f_tx_lock+0x3d/0x69
> Jun  5 21:01:57 buzz kernel: [104288.805330]  [<ffffffff81248dec>] ? netd=
ev_drivername+0x3b/0x40
> Jun  5 21:01:57 buzz kernel: [104288.805338]  [<ffffffff8125defb>] ? dev_=
watchdog+0xd2/0x16f
> Jun  5 21:01:57 buzz kernel: [104288.805347]  [<ffffffff81030065>] ? amd_=
iommu_map_range+0x13/0x8a
> Jun  5 21:01:57 buzz kernel: [104288.805356]  [<ffffffff81061834>] ? __qu=
eue_work+0x22/0x32
> Jun  5 21:01:57 buzz kernel: [104288.805366]  [<ffffffff8105a05f>] ? run_=
timer_softirq+0x1c9/0x268
> Jun  5 21:01:57 buzz kernel: [104288.805377]  [<ffffffff810538b2>] ? __do=
_softirq+0xdd/0x19f
> Jun  5 21:01:57 buzz kernel: [104288.805387]  [<ffffffff81024c92>] ? lapi=
c_next_event+0x18/0x1d
> Jun  5 21:01:57 buzz kernel: [104288.805396]  [<ffffffff81011cac>] ? call=
_softirq+0x1c/0x30
> Jun  5 21:01:57 buzz kernel: [104288.805403]  [<ffffffff81013903>] ? do_s=
oftirq+0x3f/0x7c
> Jun  5 21:01:57 buzz kernel: [104288.805411]  [<ffffffff81053721>] ? irq_=
exit+0x36/0x76
> Jun  5 21:01:57 buzz kernel: [104288.805419]  [<ffffffff81025757>] ? smp_=
apic_timer_interrupt+0x87/0x95
> Jun  5 21:01:57 buzz kernel: [104288.805426]  [<ffffffff81011673>] ? apic=
_timer_interrupt+0x13/0x20
> Jun  5 21:01:57 buzz kernel: [104288.805431]  <EOI>  [<ffffffff8102c558>]=
 ? native_safe_halt+0x2/0x3
> Jun  5 21:01:57 buzz kernel: [104288.805448]  [<ffffffff81017c6d>] ? defa=
ult_idle+0x34/0x51
> Jun  5 21:01:57 buzz kernel: [104288.805456]  [<ffffffff81017ff9>] ? c1e_=
idle+0xf5/0xfb
> Jun  5 21:01:57 buzz kernel: [104288.805466]  [<ffffffff8100feb1>] ? cpu_=
idle+0xa2/0xda
> Jun  5 21:01:57 buzz kernel: [104288.805472] ---[ end trace 6b516d8045567=
b1e ]---
> Jun  5 21:01:57 buzz kernel: [104288.805621] eth0: Transmit timed out, st=
atus 0003, PHY status 786d, resetting...
> Jun  5 21:01:57 buzz kernel: [104288.806347] eth0: link up, 100Mbps, full=
-duplex, lpa 0x45E1
> Jun  5 21:02:00 buzz kernel: [104292.805163] eth0: Transmit timed out, st=
atus 0003, PHY status 786d, resetting...
> Jun  5 21:02:00 buzz kernel: [104292.805934] eth0: link up, 100Mbps, full=
-duplex, lpa 0x45E1

More system information follows:

> -- Package-specific info:
> ** Version:
> Linux version 2.6.32-5-amd64 (Debian 2.6.32-15) (ben@decadent.org.uk) (gc=
c version 4.3.5 (Debian 4.3.5-1) ) #1 SMP Tue Jun 1 06:11:58 UTC 2010
>=20
> ** Command line:
> BOOT_IMAGE=3D/vmlinuz-2.6.32-5-amd64 root=3D/dev/mapper/vg00-root ro ipv6=
.disable=3D1 rootdelay=3D10
>=20
> ** Not tainted
>=20
> ** Kernel log:
> [   20.917471] shpchp: Standard Hot Plug PCI Controller Driver version: 0=
.4
> [   20.924598] udev: renamed network interface eth0 to eth1
> [   20.953407] udev: renamed network interface eth1_rename to eth0
> [   21.014759] parport_pc 00:0a: reported by Plug and Play ACPI
> [   21.014871] parport0: PC-style at 0x378, irq 7 [PCSPP]
> [   21.018448] input: PC Speaker as /devices/platform/pcspkr/input/input5
> [   21.032277] k8temp 0000:00:18.3: Temperature readouts might be wrong -=
 check erratum #141
> [   21.209202] EDAC MC: Ver: 2.1.0 Jun  1 2010
> [   21.226787] st0: Block limits 2 - 16777214 bytes.
> [   21.229458] EDAC amd64_edac:  Ver: 3.2.0 Jun  1 2010
> [   21.229633] EDAC amd64: This node reports that Memory ECC is currently=
 disabled, set F3x44[22] (0000:00:18.3).
> [   21.229720] EDAC amd64: ECC disabled in the BIOS or no ECC capability,=
 module will not load.
> [   21.229722]  Either enable ECC checking or force module loading by set=
ting 'ecc_enable_override'.
> [   21.229723]  (Note that use of the override may cause unknown side eff=
ects.)
> [   21.229934] amd64_edac: probe of 0000:00:18.2 failed with error -22
> [   21.373141] HDA Intel 0000:04:01.0: PCI INT A -> GSI 17 (level, low) -=
> IRQ 17
> [   21.373280] HDA Intel 0000:04:01.0: setting latency timer to 64
> [   21.373285] HDA Intel 0000:04:01.0: PCI: Disallowing DAC for device
> [   21.461004] hda_codec: ALC883: BIOS auto-probing.
> [   21.462907] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1=
3.0/0000:04:01.0/input/input6
> [   22.156505] Adding 262136k swap on /dev/mapper/vg00-swap.  Priority:-1=
 extents:1 across:262136k=20
> [   32.897030] kjournald starting.  Commit interval 5 seconds
> [   32.909096] EXT3 FS on md0, internal journal
> [   32.909200] EXT3-fs: mounted filesystem with ordered data mode.
> [   33.073055] kjournald starting.  Commit interval 5 seconds
> [   33.156713] EXT3 FS on dm-5, internal journal
> [   33.156817] EXT3-fs: mounted filesystem with ordered data mode.
> [   33.181588] kjournald starting.  Commit interval 5 seconds
> [   33.182243] EXT3 FS on dm-4, internal journal
> [   33.182343] EXT3-fs: mounted filesystem with ordered data mode.
> [   33.232237] EXT4-fs (dm-9): mounted filesystem with ordered data mode
> [   33.287448] EXT4-fs (dm-6): mounted filesystem with ordered data mode
> [   33.348953] EXT4-fs (dm-3): mounted filesystem with ordered data mode
> [   33.414076] EXT4-fs (dm-1): mounted filesystem with ordered data mode
> [   33.497949] EXT4-fs (dm-2): mounted filesystem with ordered data mode
> [   33.672536] EXT4-fs (dm-12): mounted filesystem with ordered data mode
> [   33.725336] EXT4-fs (dm-7): mounted filesystem with ordered data mode
> [   33.791361] EXT4-fs (dm-10): mounted filesystem with ordered data mode
> [   33.865425] EXT4-fs (dm-11): mounted filesystem with ordered data mode
> [   33.964434] EXT4-fs (dm-13): mounted filesystem with ordered data mode
> [   50.233632] RPC: Registered udp transport module.
> [   50.233703] RPC: Registered tcp transport module.
> [   50.233759] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [   50.261049] Slow work thread pool: Starting up
> [   50.261195] Slow work thread pool: Ready
> [   50.261332] FS-Cache: Loaded
> [   50.317395] FS-Cache: Netfs 'nfs' registered for caching
> [   50.349999] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [   50.925510] fuse init (API version 7.13)
> [   52.467290] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core Proces=
sor 4200+ processors (2 cpu cores) (version 2.20.00)
> [   52.467426] powernow-k8:    0 : fid 0xe (2200 MHz), vid 0xc
> [   52.467483] powernow-k8:    1 : fid 0xc (2000 MHz), vid 0xe
> [   52.467541] powernow-k8:    2 : fid 0xa (1800 MHz), vid 0x10
> [   52.467599] powernow-k8:    3 : fid 0x2 (1000 MHz), vid 0x12
> [   52.678554] kvm: Nested Virtualization enabled
> [   53.153019] Clocksource tsc unstable (delta =3D -269844223 ns)
> [   55.712610] st0: Failed to read 64512 byte block with 80 byte transfer=
.
> [   71.320893] ip_tables: (C) 2000-2006 Netfilter Core Team
> [   73.046091] lp0: using parport0 (interrupt-driven).
> [   73.057427] ppdev: user-space parallel port driver
> [   76.243406] ip6_tables: (C) 2000-2006 Netfilter Core Team
> [   78.057768] [drm] Initialized drm 1.1.0 20060810
> [   78.162620]   alloc irq_desc for 16 on node 0
> [   78.162625]   alloc kstat_irqs on node 0
> [   78.162636] pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ =
16
> [   78.164716] [drm] Initialized via 2.11.1 20070202 for 0000:01:00.0 on =
minor 0
> [   78.165039] ioctl32(Xorg:3623): Unknown cmd fd(11) cmd(c0106407){t:'d'=
;sz:16} arg(ff894e10) on /dev/dri/card0
> [   78.165056] ioctl32(Xorg:3623): Unknown cmd fd(11) cmd(c0086401){t:'d'=
;sz:8} arg(ff894e08) on /dev/dri/card0
> [   78.228349] ioctl32(Xorg:3623): Unknown cmd fd(11) cmd(c0246400){t:'d'=
;sz:36} arg(0869c910) on /dev/dri/card0
> [   78.234915] ioctl32(Xorg:3623): Unknown cmd fd(11) cmd(c0246400){t:'d'=
;sz:36} arg(0869c910) on /dev/dri/card0
> [   82.424895] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state rec=
overy directory
> [   82.437939] NFSD: starting 90-second grace period
> [  306.805357] SGI XFS with ACLs, security attributes, realtime, large bl=
ock/inode numbers, no debug enabled
> [  306.807862] SGI XFS Quota Management subsystem
> [  306.825141] JFS: nTxBlock =3D 8192, nTxLock =3D 65536
> [  306.851135] NTFS driver 2.1.29 [Flags: R/W MODULE].
> [  306.872372] QNX4 filesystem 0.2.3 registered.
> [  686.805028] ata4: lost interrupt (Status 0x51)
> [  691.805047] ata4.01: qc timeout (cmd 0xa0)
> [  691.805064] ata4.01: exception Emask 0x0 SAct 0x0 SErr 0x0 action 0x6 =
frozen
> [  691.805092] sr 4:0:1:0: CDB: Test Unit Ready: 00 00 00 00 00 00
> [  691.805105] ata4.01: cmd a0/00:00:00:00:00/00:00:00:00:00/b0 tag 0
> [  691.805106]          res 51/20:03:00:00:00/00:00:00:00:00/b0 Emask 0x5=
 (timeout)
> [  691.805110] ata4.01: status: { DRDY ERR }
> [  691.805136] ata4: soft resetting link
> [  692.193313] ata4.01: configured for UDMA/66
> [  697.193028] ata4.01: qc timeout (cmd 0xa0)
> [  697.193037] ata4.01: TEST_UNIT_READY failed (err_mask=3D0x5)
> [  697.193060] ata4: soft resetting link
> [  697.585251] ata4.01: configured for UDMA/66
> [  702.585058] ata4.01: qc timeout (cmd 0xa0)
> [  702.585071] ata4.01: TEST_UNIT_READY failed (err_mask=3D0x5)
> [  702.585076] ata4.01: limiting speed to UDMA/66:PIO3
> [  702.585103] ata4: soft resetting link
> [  702.977291] ata4.01: configured for UDMA/66
> [  707.977030] ata4.01: qc timeout (cmd 0xa0)
> [  707.977040] ata4.01: TEST_UNIT_READY failed (err_mask=3D0x5)
> [  707.977043] ata4.01: disabled
> [  707.977081] ata4: soft resetting link
> [  708.301095] ata4: EH complete
>=20
> ** Model information
> sys_vendor: MICRO-STAR INTERNATIONAL CO., LTD
> product_name: MS-7253
> product_version: 1.00
> chassis_vendor: =20
> chassis_version: =20
> bios_vendor: Phoenix Technologies, LTD
> bios_version: 6.00 PG
> board_vendor: MICRO-STAR INTERNATIONAL CO., LTD
> board_name: MS-7253
> board_version: 1.00
>=20
> ** Loaded modules:
> Module                  Size  Used by
> ufs                    56458  0=20
> qnx4                    6194  0=20
> hfsplus                64966  0=20
> hfs                    37199  0=20
> minix                  21117  0=20
> ntfs                  162540  0=20
> vfat                    7836  0=20
> msdos                   5914  0=20
> fat                    39990  2 vfat,msdos
> jfs                   140115  0=20
> xfs                   436189  0=20
> via                    32847  0=20
> drm                   142199  1 via
> ip6_tables             14867  0=20
> ppdev                   5030  0=20
> lp                      7462  0=20
> xt_multiport            2267  1=20
> iptable_filter          2258  1=20
> ip_tables              13675  1 iptable_filter
> x_tables               12685  3 ip6_tables,xt_multiport,ip_tables
> kvm_amd                31222  0=20
> kvm                   213448  1 kvm_amd
> powernow_k8            10978  1=20
> cpufreq_stats           2659  0=20
> cpufreq_powersave        902  0=20
> cpufreq_userspace       1992  0=20
> cpufreq_conservative     5162  0=20
> dm_snapshot            18513  0=20
> dm_mirror              10843  0=20
> dm_region_hash          6680  1 dm_mirror
> dm_log                  7381  2 dm_mirror,dm_region_hash
> fuse                   49982  1=20
> nfsd                  253350  13=20
> exportfs                3122  2 xfs,nfsd
> nfs                   239786  0=20
> lockd                  57299  2 nfsd,nfs
> fscache                29818  1 nfs
> nfs_acl                 2031  2 nfsd,nfs
> auth_rpcgss            33428  2 nfsd,nfs
> sunrpc                160117  12 nfsd,nfs,lockd,nfs_acl,auth_rpcgss
> ext3                  106326  3=20
> jbd                    36861  1 ext3
> ext2                   52953  1=20
> snd_hda_codec_realtek   235026  1=20
> snd_hda_intel          19907  0=20
> snd_hda_codec          53892  2 snd_hda_codec_realtek,snd_hda_intel
> snd_hwdep               5236  1 snd_hda_codec
> snd_pcm_oss            32415  0=20
> snd_mixer_oss          12478  1 snd_pcm_oss
> snd_pcm                60119  3 snd_hda_intel,snd_hda_codec,snd_pcm_oss
> snd_seq_midi            4256  0=20
> snd_rawmidi            15323  1 snd_seq_midi
> snd_seq_midi_event      4628  1 snd_seq_midi
> snd_seq                41281  2 snd_seq_midi,snd_seq_midi_event
> snd_timer              15486  2 snd_pcm,snd_seq
> snd_seq_device          4493  3 snd_seq_midi,snd_rawmidi,snd_seq
> snd                    45918  11 snd_hda_codec_realtek,snd_hda_intel,snd_=
hda_codec,snd_hwdep,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_rawmidi,snd_seq,s=
nd_timer,snd_seq_device
> edac_core              29197  0=20
> psmouse                49777  0=20
> soundcore               4566  1 snd
> edac_mce_amd            6433  0=20
> evdev                   7352  14=20
> tpm_tis                 7336  0=20
> snd_page_alloc          6217  2 snd_hda_intel,snd_pcm
> tpm                     9549  1 tpm_tis
> pcspkr                  1699  0=20
> tpm_bios                4489  1 tpm
> serio_raw               3752  0=20
> k8temp                  3139  0=20
> parport_pc             18855  1=20
> i2c_viapro              5483  0=20
> i2c_core               15328  2 drm,i2c_viapro
> parport                27682  3 ppdev,lp,parport_pc
> shpchp                 26232  0=20
> pci_hotplug            21203  1 shpchp
> button                  4650  0=20
> processor              30167  1 powernow_k8
> sha256_generic          8644  2=20
> aes_x86_64              7340  2=20
> aes_generic            25714  1 aes_x86_64
> cbc                     2507  1=20
> ext4                  285387  11=20
> mbcache                 5050  3 ext3,ext2,ext4
> jbd2                   66823  1 ext4
> crc16                   1319  1 ext4
> dm_crypt               10491  1=20
> raid1                  17999  2=20
> md_mod                 73040  3 raid1
> reiserfs              193756  0=20
> dm_mod                 53434  58 dm_snapshot,dm_mirror,dm_log,dm_crypt
> usb_storage            39337  1=20
> usbhid                 33244  2=20
> hid                    62793  1 usbhid
> sg                     18632  0=20
> sr_mod                 12250  0=20
> sd_mod                 29553  8=20
> crc_t10dif              1276  1 sd_mod
> cdrom                  28631  1 sr_mod
> st                     30404  2=20
> ata_generic             2983  0=20
> osst                   44725  0=20
> pata_via                7461  0=20
> uhci_hcd               18521  0=20
> sata_via                7789  4=20
> via_rhine              17371  0=20
> atp870u                24161  1=20
> thermal                11610  0=20
> tulip                  41368  0=20
> thermal_sys            11942  2 processor,thermal
> ehci_hcd               31023  0=20
> libata                133008  3 ata_generic,pata_via,sata_via
> scsi_mod              121717  8 usb_storage,sg,sr_mod,sd_mod,st,osst,atp8=
70u,libata
> mii                     3210  1 via_rhine
> usbcore               121671  7 usb_storage,usbhid,uhci_hcd,ehci_hcd
> nls_base                6361  7 hfsplus,hfs,ntfs,vfat,fat,jfs,usbcore
>=20
> ** PCI devices:
> 00:00.0 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:0336]
>         Subsystem: VIA Technologies, Inc. K8M890CE Host Bridge [1106:0336=
]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 8, Cache Line Size: 32 bytes
>         Region 0: Memory at <ignored> (32-bit, prefetchable)
>         Capabilities: <access denied>
>         Kernel driver in use: agpgart-amd64
>=20
> 00:00.1 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:1336]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:00.2 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:2336]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:00.3 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:3336]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:00.4 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:4336]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:00.5 PIC [0800]: VIA Technologies, Inc. K8M890CE I/O APIC Interrupt Co=
ntroller [1106:5336] (prog-if 20 [IO(X)-APIC])
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:00.7 Host bridge [0600]: VIA Technologies, Inc. K8M890CE Host Bridge [=
1106:7336]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>=20
> 00:01.0 PCI bridge [0604]: VIA Technologies, Inc. VT8237 PCI bridge [K8T8=
00/K8T890 South] [1106:b188] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=
=3D0
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: dd000000-deffffff
>         Prefetchable memory behind bridge: c0000000-cfffffff
>         Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: <access denied>
>=20
> 00:02.0 PCI bridge [0604]: VIA Technologies, Inc. K8T890 PCI to PCI Bridg=
e Controller [1106:a238] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=
=3D0
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: dfc00000-dfcfffff
>         Prefetchable memory behind bridge: 00000000dfb00000-00000000dfbff=
fff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: <access denied>
>         Kernel driver in use: pcieport
>=20
> 00:03.0 PCI bridge [0604]: VIA Technologies, Inc. K8T890 PCI to PCI Bridg=
e Controller [1106:c238] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=
=3D0
>         I/O behind bridge: 0000c000-0000cfff
>         Memory behind bridge: dfe00000-dfefffff
>         Prefetchable memory behind bridge: 00000000dfd00000-00000000dfdff=
fff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: <access denied>
>         Kernel driver in use: pcieport
>=20
> 00:0f.0 IDE interface [0101]: VIA Technologies, Inc. VT8237A SATA 2-Port =
Controller [1106:0591] (rev 80) (prog-if 8f [Master SecP SecO PriP PriO])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64
>         Interrupt: pin B routed to IRQ 21
>         Region 0: I/O ports at ff00 [size=3D8]
>         Region 1: I/O ports at fe00 [size=3D4]
>         Region 2: I/O ports at fd00 [size=3D8]
>         Region 3: I/O ports at fc00 [size=3D4]
>         Region 4: I/O ports at fb00 [size=3D16]
>         Region 5: I/O ports at f400 [size=3D256]
>         Capabilities: <access denied>
>         Kernel driver in use: sata_via
>=20
> 00:0f.1 IDE interface [0101]: VIA Technologies, Inc. VT82C586A/B/VT82C686=
/A/B/VT823x/A/C PIPC Bus Master IDE [1106:0571] (rev 07) (prog-if 8a [Maste=
r SecP PriP])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx+
>         Latency: 64
>         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)=
 [size=3D8]
>         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)=
 [size=3D1]
>         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)=
 [size=3D8]
>         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)=
 [size=3D1]
>         Region 4: I/O ports at fa00 [size=3D16]
>         Capabilities: <access denied>
>         Kernel driver in use: pata_via
>=20
> 00:10.0 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB =
1.1 Controller [1106:3038] (rev a0) (prog-if 00 [UHCI])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 20
>         Region 4: I/O ports at f900 [size=3D32]
>         Capabilities: <access denied>
>         Kernel driver in use: uhci_hcd
>=20
> 00:10.1 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB =
1.1 Controller [1106:3038] (rev a0) (prog-if 00 [UHCI])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin B routed to IRQ 22
>         Region 4: I/O ports at f800 [size=3D32]
>         Capabilities: <access denied>
>         Kernel driver in use: uhci_hcd
>=20
> 00:10.2 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB =
1.1 Controller [1106:3038] (rev a0) (prog-if 00 [UHCI])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin C routed to IRQ 21
>         Region 4: I/O ports at f700 [size=3D32]
>         Capabilities: <access denied>
>         Kernel driver in use: uhci_hcd
>=20
> 00:10.3 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB =
1.1 Controller [1106:3038] (rev a0) (prog-if 00 [UHCI])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64, Cache Line Size: 32 bytes
>         Interrupt: pin D routed to IRQ 23
>         Region 4: I/O ports at f600 [size=3D32]
>         Capabilities: <access denied>
>         Kernel driver in use: uhci_hcd
>=20
> 00:10.4 USB Controller [0c03]: VIA Technologies, Inc. USB 2.0 [1106:3104]=
 (rev 86) (prog-if 20 [EHCI])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64, Cache Line Size: 64 bytes
>         Interrupt: pin C routed to IRQ 21
>         Region 0: Memory at dffff000 (32-bit, non-prefetchable) [size=3D2=
56]
>         Capabilities: <access denied>
>         Kernel driver in use: ehci_hcd
>=20
> 00:11.0 ISA bridge [0601]: VIA Technologies, Inc. VT8237A PCI to ISA Brid=
ge [1106:3337]
>         Subsystem: VIA Technologies, Inc. VT8237A PCI to ISA Bridge [1106=
:3337]
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Capabilities: <access denied>
>=20
> 00:11.7 Host bridge [0600]: VIA Technologies, Inc. VT8251 Ultra VLINK Con=
troller [1106:287e]
>         Subsystem: VIA Technologies, Inc. Device [1106:337e]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 64
>         Capabilities: <access denied>
>=20
> 00:12.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6102 [Rhine-=
II] [1106:3065] (rev 7c)
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (750ns min, 2000ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 23
>         Region 0: I/O ports at f200 [size=3D256]
>         Region 1: Memory at dfffe000 (32-bit, non-prefetchable) [size=3D2=
56]
>         Capabilities: <access denied>
>         Kernel driver in use: via-rhine
>=20
> 00:13.0 PCI bridge [0604]: VIA Technologies, Inc. VT8237A Host Bridge [11=
06:337b] (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 0
>         Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latency=
=3D0
>         I/O behind bridge: 0000b000-0000bfff
>         Memory behind bridge: dfa00000-dfafffff
>         Prefetchable memory behind bridge: 00000000df900000-00000000df9ff=
fff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: <access denied>
>=20
> 00:13.1 PCI bridge [0604]: VIA Technologies, Inc. VT8237A PCI to PCI Brid=
ge [1106:337a] (prog-if 01 [Subtractive decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 0
>         Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latency=
=3D0
>         I/O behind bridge: 0000a000-0000afff
>         Memory behind bridge: df800000-df8fffff
>         Prefetchable memory behind bridge: 00000000df700000-00000000df7ff=
fff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: <access denied>
>=20
> 00:18.0 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opt=
eron] HyperTransport Technology Configuration [1022:1100]
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Capabilities: <access denied>
>=20
> 00:18.1 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opt=
eron] Address Map [1022:1101]
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>=20
> 00:18.2 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opt=
eron] DRAM Controller [1022:1102]
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>=20
> 00:18.3 Host bridge [0600]: Advanced Micro Devices [AMD] K8 [Athlon64/Opt=
eron] Miscellaneous Control [1022:1103]
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Capabilities: <access denied>
>         Kernel driver in use: k8temp
>=20
> 01:00.0 VGA compatible controller [0300]: VIA Technologies, Inc. K8M890CE=
/K8N890CE [Chrome 9] [1106:3230] (rev 11) (prog-if 00 [VGA controller])
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (500ns min)
>         Interrupt: pin A routed to IRQ 16
>         Region 0: Memory at c0000000 (32-bit, prefetchable) [size=3D256M]
>         Region 1: Memory at dd000000 (32-bit, non-prefetchable) [size=3D1=
6M]
>         [virtual] Expansion ROM at de000000 [disabled] [size=3D64K]
>         Capabilities: <access denied>
>=20
> 04:01.0 Audio device [0403]: VIA Technologies, Inc. VT1708/A [Azalia HDAC=
] (VIA High Definition Audio Controller) [1106:3288] (rev 10)
>         Subsystem: Micro-Star International Co., Ltd. Device [1462:7253]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 17
>         Region 0: Memory at dfafc000 (64-bit, non-prefetchable) [size=3D1=
6K]
>         Capabilities: <access denied>
>         Kernel driver in use: HDA Intel
>=20
> 05:04.0 SCSI storage controller [0100]: Artop Electronic Corp AEC6712UW S=
CSI [1191:8010] (rev 01)
>         Subsystem: Artop Electronic Corp AEC6712UW SCSI [1191:8010]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 254
>         Interrupt: pin A routed to IRQ 17
>         Region 0: I/O ports at af00 [size=3D64]
>         [virtual] Expansion ROM at df740000 [disabled] [size=3D64K]
>         Capabilities: <access denied>
>         Kernel driver in use: atp870u
>=20
> 05:05.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip=
 21142/43 [1011:0019] (rev 30)
>         Subsystem: Digital Equipment Corporation DE500B Fast Ethernet [10=
11:500b]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (5000ns min, 10000ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 18
>         Region 0: I/O ports at ae00 [size=3D128]
>         Region 1: Memory at df8ff000 (32-bit, non-prefetchable) [size=3D1=
28]
>         [virtual] Expansion ROM at df700000 [disabled] [size=3D256K]
>         Kernel driver in use: tulip
>=20
>=20
> ** USB devices:
> Bus 005 Device 003: ID 08ec:0010 M-Systems Flash Disk Pioneers DiskOnKey
> Bus 005 Device 002: ID 058f:6362 Alcor Micro Corp. Flash Card Reader/Writ=
er
> Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 003 Device 004: ID 045e:005f Microsoft Corp. Wireless MultiMedia Keyb=
oard
> Bus 003 Device 003: ID 0557:7000 ATEN International Co., Ltd Hub
> Bus 003 Device 002: ID 051d:0002 American Power Conversion Uninterruptibl=
e Power Supply
> Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
>=20
>=20
> -- System Information:
> Debian Release: squeeze/sid
>   APT prefers testing
>   APT policy: (900, 'testing'), (500, 'stable'), (400, 'oldstable'), (50,=
 'unstable')
> Architecture: i386 (x86_64)
>=20
> Kernel: Linux 2.6.32-5-amd64 (SMP w/2 CPU cores)
> Locale: LANG=3DC, LC_CTYPE=3DC (charmap=3DANSI_X3.4-1968)
> Shell: /bin/sh linked to /bin/bash
>=20
> Versions of packages linux-image-2.6.32-5-amd64 depends on:
> ii  debconf [debconf-2.0]        1.5.32      Debian configuration managem=
ent sy
> ii  initramfs-tools [linux-initr 0.94.4      tools for generating an init=
ramfs
> ii  linux-base                   2.6.32-15   Linux image base package
> ii  module-init-tools            3.12~pre2-3 tools for managing Linux ker=
nel mo
>=20
> Versions of packages linux-image-2.6.32-5-amd64 recommends:
> ii  firmware-linux-free           2.6.32-9   Binary firmware for various =
driver
> ii  libc6-i686                    2.10.2-9   GNU C Library: Shared librar=
ies [i
>=20
> Versions of packages linux-image-2.6.32-5-amd64 suggests:
> pn  grub | lilo                   <none>     (no description available)
> pn  linux-doc-2.6.32              <none>     (no description available)
>=20
> Versions of packages linux-image-2.6.32-5-amd64 is related to:
> pn  firmware-bnx2                 <none>     (no description available)
> pn  firmware-bnx2x                <none>     (no description available)
> pn  firmware-ipw2x00              <none>     (no description available)
> pn  firmware-ivtv                 <none>     (no description available)
> pn  firmware-iwlwifi              <none>     (no description available)
> pn  firmware-linux                <none>     (no description available)
> pn  firmware-linux-nonfree        <none>     (no description available)
> pn  firmware-qlogic               <none>     (no description available)
> pn  firmware-ralink               <none>     (no description available)
> pn  xen-hypervisor                <none>     (no description available)
>=20
> -- debconf information:
>   linux-image-2.6.32-5-amd64/postinst/missing-firmware-2.6.32-5-amd64:
>   linux-image-2.6.32-5-amd64/postinst/bootloader-error-2.6.32-5-amd64:
>   linux-image-2.6.32-5-amd64/prerm/would-invalidate-boot-loader-2.6.32-5-=
amd64: true
>   shared/kernel-image/really-run-bootloader: true
>   linux-image-2.6.32-5-amd64/postinst/depmod-error-initrd-2.6.32-5-amd64:=
 false
>   linux-image-2.6.32-5-amd64/prerm/removing-running-kernel-2.6.32-5-amd64=
: true
>   linux-image-2.6.32-5-amd64/postinst/bootloader-test-error-2.6.32-5-amd6=
4:

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-EUKBFHD9tEbeQsSUVs5Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATAwR2Oe/yOyVhhEJAQL6XxAAsBA0Nn7OG3ec3pZTVtORa08o6pi1D+Ul
Qo+GZTgCoH/k/qPreIpFAbeoEiWGTXvlW72atlq0yfnsKfZVXIXN87RWCEiRJ/Jb
tiQlZemMbIx9qw4ipIdQVF+P+aw1rqpH+DxSGQC+bHr5zuDxUjzzrOHe3VWK3M5d
1aCv8w7F7W4Ut6cC2KEPSzCkinGp0uoA+R20xyhQv0ZMuB97HBXQX9EjhOMu2vSa
JB87/XTQnS8R+FwiKnz9nFWvV+RNI4ey2+hocdrr6QtC6lsFqYQ68CcMXxIyMWOJ
Un1Ck5fi8y+4hXugpjljg74cW02dgX1qkXcHHY9T+3VWQn0ui6DoqDuz8kUMNLYQ
2lKQsE/CRUef19El+bDhu6kL1lkCTILI+VcVk/uFlUjuvLg8f1QMKQM9p3s/rNLc
CtX8yfioPBIlpDybyoA/9Fk0kEfqksMLHPsyz5vWXGKMpGtD3oltkuWhw7Rviz2P
HC6pH9QIBlosG5IpmV05eEJ240cRai+knSkh34iSOUuT1kelbaBogcBlMoaUGL0f
VMAOfZvLGsme6C+Y+eNExEu51Yo4WkxxWtd+wV8/12eTTpUa8JdnSWOxLBbChlOc
tYLbDzOocyO3sAjuy8Yot6vfietGpVWeO+4Xae5hH5ehAEZ5A+qNi5W9d5wcVStY
nZOMO6Q4MGQ=
=SSMW
-----END PGP SIGNATURE-----

--=-EUKBFHD9tEbeQsSUVs5Q--
