From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Fri, 22 Jan 2016 20:23:43 +0100
Message-ID: <20160122192343.GL31058@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <55645140.1050209@citrix.com>
 <20150526220312.GA1358@mail-itl>
 <20151021185734.GD31646@mail-itl>
 <20151117024515.GN976@mail-itl>
 <20151201220042.GC22107@char.us.oracle.com>
 <20151201223258.GH1337@mail-itl>
 <20160120215914.GA6384@char.us.oracle.com>
 <56A0CF78.1090901@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="RD6GsZsdEJvsf78O"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Annie Li <annie.li@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: Joao Martins <joao.m.martins@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:37335 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754243AbcAVTXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 14:23:50 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 667E821554
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 14:23:49 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <56A0CF78.1090901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RD6GsZsdEJvsf78O
Content-Type: multipart/mixed; boundary="FCF9ydJxlAJsfRTu"
Content-Disposition: inline


--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 21, 2016 at 12:30:48PM +0000, Joao Martins wrote:
>=20
>=20
> On 01/20/2016 09:59 PM, Konrad Rzeszutek Wilk wrote:
> > On Tue, Dec 01, 2015 at 11:32:58PM +0100, Marek Marczykowski-G=C3=B3rec=
ki wrote:
> >> On Tue, Dec 01, 2015 at 05:00:42PM -0500, Konrad Rzeszutek Wilk wrote:
> >>> On Tue, Nov 17, 2015 at 03:45:15AM +0100, Marek Marczykowski-G=C3=B3r=
ecki wrote:
> >>>> On Wed, Oct 21, 2015 at 08:57:34PM +0200, Marek Marczykowski-G=C3=B3=
recki wrote:
> >>>>> On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=C3=
=B3recki wrote:
> >>>>>> On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> >>>>>>> On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> >>>>>>>> Hi all,
> >>>>>>>>
> >>>>>>>> I'm experiencing xen-netfront crash when doing xl network-detach=
 while
> >>>>>>>> some network activity is going on at the same time. It happens o=
nly when
> >>>>>>>> domU has more than one vcpu. Not sure if this matters, but the b=
ackend
> >>>>>>>> is in another domU (not dom0). I'm using Xen 4.2.2. It happens o=
n kernel
> >>>>>>>> 3.9.4 and 4.1-rc1 as well.
> >>>>>>>>
> >>>>>>>> Steps to reproduce:
> >>>>>>>> 1. Start the domU with some network interface
> >>>>>>>> 2. Call there 'ping -f some-IP'
> >>>>>>>> 3. Call 'xl network-detach NAME 0'
> >>>
> >>> Do you see this all the time or just on occassions?
> >>
> >> Using above procedure - all the time.
> >>
> >>> I tried to reproduce it and couldn't see it. Is your VM an PV or HVM?
> >>
> >> PV, started by libvirt. This may have something to do, the problem did=
n't
> >> existed on older Xen (4.1) and started by xl. I'm not sure about kernel
> >> version there, but I think I've tried there 3.18 too, which has this
> >> problem.
> >>
> >> But I don't see anything special in domU config file (neither backend
> >> nor frontend) - it may be some libvirt default. If that's really the
> >> cause. Can I (and how) get any useful information about that?
> >=20
> > libvirt naturally does some libxl calls, and they may be different.
> >=20
> > Any chance you could give me an idea of:
> >  - What commands you use in libvirt?
> >  - Do you use a bond or bridge?
> >  - What version of libvirt you are using?
> >=20
> > Thanks!
> > CC-ing Joao just in case he has seen this.
> >>
> Hm, So far I couldn't reproduce the issue with upstream Xen/linux/libvirt=
, using
> both libvirt or plain xl (both on a bridge setup) and also irrespective o=
f the
> both load and direction of traffic (be it a ping flood, pktgen with min.
> sized packets or iperf).

I've ran the test again, on vanilla 4.4 and collected some info:
 - xenstore dump of frontend (xs-frontend-before.txt)
 - xenstore dump of backend (xs-backend-before.txt)
 - kernel messages (console output) (console.log)
 - kernel config (config-4.4)
 - libvirt config of that domain (netdebug.conf)

Versions:
 - kernel 4.4 (frontend), 4.2.8 (backend)
 - libvirt 1.2.20
 - xen 4.6.0

In backend domain there is no bridge or anything like that - only
routing. The same in frontend - nothing fancy - just IP set on eth0
there.

Steps to reproduce were the same:
 - start frontend domain (virsh create ...)
 - call ping -f
 - xl network-detach NAME 0

Note that the crash doesn't happen with attached patch applied (as noted
in mail on Oct 21), but I have no idea whether is it a proper fix, or
just prevents the crash by a coincidence.

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="console.log"
Content-Transfer-Encoding: quoted-printable

[    0.000000] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WC  WP  UC  UC=
  =0D
[    0.000000] Initializing cgroup subsys cpuset=0D
[    0.000000] Initializing cgroup subsys cpu=0D
[    0.000000] Initializing cgroup subsys cpuacct=0D
[    0.000000] Linux version 4.4.0-1.pvops.qubes.x86_64 (user@devel-3rdpart=
y) (gcc version 4.9.2 20150212 (Red Hat 4.9.2-6) (GCC) ) #20 SMP Fri Jan 22=
 00:39:29 CET 2016=0D
[    0.000000] Command line: root=3D/dev/mapper/dmroot ro nomodeset console=
=3Dhvc0 rd_NO_PLYMOUTH 3 rd.break=0D
[    0.000000] x86/fpu: Legacy x87 FPU detected.=0D
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.=0D
[    0.000000] ACPI in unprivileged domain disabled=0D
[    0.000000] Released 0 page(s)=0D
[    0.000000] e820: BIOS-provided physical RAM map:=0D
[    0.000000] Xen: [mem 0x0000000000000000-0x000000000009ffff] usable=0D
[    0.000000] Xen: [mem 0x00000000000a0000-0x00000000000fffff] reserved=0D
[    0.000000] Xen: [mem 0x0000000000100000-0x00000000f9ffffff] usable=0D
[    0.000000] NX (Execute Disable) protection: active=0D
[    0.000000] DMI not present or invalid.=0D
[    0.000000] Hypervisor detected: Xen=0D
[    0.000000] e820: last_pfn =3D 0xfa000 max_arch_pfn =3D 0x400000000=0D
[    0.000000] MTRR: Disabled=0D
[    0.000000] RAMDISK: [mem 0x02030000-0x027c6fff]=0D
[    0.000000] NUMA turned off=0D
[    0.000000] Faking a node at [mem 0x0000000000000000-0x00000000f9ffffff]=
=0D
[    0.000000] NODE_DATA(0) allocated [mem 0x18837000-0x18848fff]=0D
[    0.000000] Zone ranges:=0D
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]=0D
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000f9ffffff]=0D
[    0.000000]   Normal   empty=0D
[    0.000000] Movable zone start for each node=0D
[    0.000000] Early memory node ranges=0D
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]=0D
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000f9ffffff]=0D
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x00000000f9fff=
fff]=0D
[    0.000000] p2m virtual area at ffffc90000000000, size is 40000000=0D
[    0.000000] Remapped 0 page(s)=0D
[    0.000000] SFI: Simple Firmware Interface v0.81 http://simplefirmware.o=
rg=0D
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs=0D
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]=0D
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]=0D
[    0.000000] e820: [mem 0xfa000000-0xffffffff] available for PCI devices=
=0D
[    0.000000] Booting paravirtualized kernel on Xen=0D
[    0.000000] Xen version: 4.6.0 (preserve-AD)=0D
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 1910969940391419 ns=0D
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_=
node_ids:1=0D
[    0.000000] PERCPU: Embedded 33 pages/cpu @ffff880013c00000 s98264 r8192=
 d28712 u1048576=0D
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 1007882=0D
[    0.000000] Policy zone: DMA32=0D
[    0.000000] Kernel command line: root=3D/dev/mapper/dmroot ro nomodeset =
console=3Dhvc0 rd_NO_PLYMOUTH 3 rd.break=0D
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)=0D
[    0.000000] Memory: 302592K/4095612K available (6670K kernel code, 1222K=
 rwdata, 2980K rodata, 1452K init, 1424K bss, 3793020K reserved, 0K cma-res=
erved)=0D
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1=0D
[    0.000000] Hierarchical RCU implementation.=0D
[    0.000000] 	Build-time adjustment of leaf fanout to 64.=0D
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D64 to nr_cpu_ids=3D2.=0D
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=
=3D2=0D
[    0.000000] Using NULL legacy PIC=0D
[    0.000000] NR_IRQS:4352 nr_irqs:48 0=0D
[    0.000000] xen:events: Using FIFO-based ABI=0D
[    0.000000] 	Offload RCU callbacks from all CPUs=0D
[    0.000000] 	Offload RCU callbacks from CPUs: 0-1.=0D
[    0.000000] Console: colour dummy device 80x25=0D
[    0.000000] console [tty0] enabled=0D
[    0.000000] console [hvc0] enabled=0D
[    0.000000] clocksource: xen: mask: 0xffffffffffffffff max_cycles: 0x1cd=
42e4dffb, max_idle_ns: 881590591483 ns=0D
[    0.000000] installing Xen timer for CPU 0=0D
[    0.000000] tsc: Detected 1995.104 MHz processor=0D
[    0.001000] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 3990.20 BogoMIPS (lpj=3D1995104)=0D
[    0.001000] pid_max: default: 32768 minimum: 301=0D
[    0.001000] Security Framework initialized=0D
[    0.001611] Dentry cache hash table entries: 524288 (order: 10, 4194304 =
bytes)=0D
[    0.004023] Inode-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)=0D
[    0.005197] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)=
=0D
[    0.005237] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 b=
ytes)=0D
[    0.005788] Initializing cgroup subsys io=0D
[    0.005803] Initializing cgroup subsys memory=0D
[    0.005821] Initializing cgroup subsys devices=0D
[    0.005832] Initializing cgroup subsys freezer=0D
[    0.005843] Initializing cgroup subsys net_cls=0D
[    0.005853] Initializing cgroup subsys perf_event=0D
[    0.005863] Initializing cgroup subsys net_prio=0D
[    0.005873] Initializing cgroup subsys hugetlb=0D
[    0.005956] CPU: Physical Processor ID: 0=0D
[    0.005963] CPU: Processor Core ID: 1=0D
[    0.005977] Last level iTLB entries: 4KB 128, 2MB 4, 4MB 4=0D
[    0.005983] Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32, 1GB 0=0D
[    0.039457] ftrace: allocating 25787 entries in 101 pages=0D
[    0.047128] Could not initialize VPMU for cpu 0, error -95=0D
[    0.047220] Performance Events: unsupported p6 CPU model 15 no PMU drive=
r, software events only.=0D
[    0.047979] NMI watchdog: disabled (cpu0): hardware events not enabled=0D
[    0.047990] NMI watchdog: Shutting down hard lockup detector on all cpus=
=0D
[    0.048139] SMP alternatives: switching to SMP code=0D
[    0.078846] installing Xen timer for CPU 1=0D
[    0.079180] x86: Booted up 1 node, 2 CPUs=0D
[    0.079316] devtmpfs: initialized=0D
[    0.083816] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 1911260446275000 ns=0D
[    0.084096] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE=0D
[    0.084108] pinctrl core: initialized pinctrl subsystem=0D
[    0.104107] RTC time: 165:165:165, date: 165/165/65=0D
[    0.110246] NET: Registered protocol family 16=0D
[    0.110284] xen:grant_table: Grant tables using version 1 layout=0D
[    0.110310] Grant table initialized=0D
[    0.111010] PCI: setting up Xen PCI frontend stub=0D
[    0.115090] ACPI: Interpreter disabled.=0D
[    0.115090] xen:balloon: Initialising balloon driver=0D
[    0.181042] xen_balloon: Initialising balloon driver=0D
[    0.181110] vgaarb: loaded=0D
[    0.182053] SCSI subsystem initialized=0D
[    0.182165] dmi: Firmware registration failed.=0D
[    0.183040] PCI: System does not support PCI=0D
[    0.183050] PCI: System does not support PCI=0D
[    0.183237] NetLabel: Initializing=0D
[    0.183248] NetLabel:  domain hash size =3D 128=0D
[    0.183254] NetLabel:  protocols =3D UNLABELED CIPSOv4=0D
[    0.183279] NetLabel:  unlabeled traffic allowed by default=0D
[    0.185019] clocksource: Switched to clocksource xen=0D
[    0.195845] pnp: PnP ACPI: disabled=0D
[    0.200085] NET: Registered protocol family 2=0D
[    0.200441] TCP established hash table entries: 32768 (order: 6, 262144 =
bytes)=0D
[    0.200691] TCP bind hash table entries: 32768 (order: 7, 524288 bytes)=
=0D
[    0.200901] TCP: Hash tables configured (established 32768 bind 32768)=0D
[    0.200975] UDP hash table entries: 2048 (order: 4, 65536 bytes)=0D
[    0.201057] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)=0D
[    0.201180] NET: Registered protocol family 1=0D
[    0.201284] Unpacking initramfs...=0D
[    0.219827] Freeing initrd memory: 7772K (ffff880002030000 - ffff8800027=
c7000)=0D
[    0.220918] futex hash table entries: 512 (order: 3, 32768 bytes)=0D
[    0.220977] audit: initializing netlink subsys (disabled)=0D
[    0.221036] audit: type=3D2000 audit(1453421870.210:1): initialized=0D
[    0.221566] HugeTLB registered 2 MB page size, pre-allocated 0 pages=0D
[    0.224154] zbud: loaded=0D
[    0.224502] VFS: Disk quotas dquot_6.6.0=0D
[    0.224567] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)=0D
[    0.225281] Key type big_key registered=0D
[    0.230104] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 253)=0D
[    0.230168] io scheduler noop registered=0D
[    0.230177] io scheduler deadline registered=0D
[    0.230239] io scheduler cfq registered (default)=0D
[    0.230356] pci_hotplug: PCI Hot Plug PCI Core version: 0.5=0D
[    0.230371] pciehp: PCI Express Hot Plug Controller Driver version: 0.4=
=0D
[    0.230721] xen:xen_evtchn: Event-channel device installed=0D
[    0.231501] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled=0D
[    0.232242] Non-volatile memory driver v1.3=0D
[    0.232585] loop: module loaded=0D
[    0.283555] blkfront: xvda: flush diskcache: enabled; persistent grants:=
 enabled; indirect descriptors: enabled;=0D
[    0.287743] tun: Universal TUN/TAP device driver, 1.6=0D
[    0.287754] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>=0D
[    0.287959] xen_netfront: Initialising Xen virtual ethernet driver=0D
[    0.291795] blkfront: xvdb: flush diskcache: enabled; persistent grants:=
 enabled; indirect descriptors: enabled;=0D
[    0.295457] i8042: PNP: No PS/2 controller found. Probing ports directly=
=2E=0D
[    1.314402] i8042: No controller found=0D
[    1.314436] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x398=
43a855e2, max_idle_ns: 881590688655 ns=0D
[    1.314792] mousedev: PS/2 mouse device common for all mice=0D
[    1.315247] device-mapper: uevent: version 1.0.3=0D
[    1.315492] device-mapper: ioctl: 4.34.0-ioctl (2015-10-28) initialised:=
 dm-devel@redhat.com=0D
[    1.315696] dmi-sysfs: dmi entry is absent.=0D
[    1.315738] hidraw: raw HID events driver (C) Jiri Kosina=0D
[    1.315852] drop_monitor: Initializing network drop monitor service=0D
[    1.315956] Initializing XFRM netlink socket=0D
[    1.316215] NET: Registered protocol family 10=0D
[    1.316696] mip6: Mobile IPv6=0D
[    1.316710] NET: Registered protocol family 17=0D
[    1.317235] registered taskstats version 1=0D
[    1.317290] zswap: loaded using pool lzo/zbud=0D
[    1.386055] blkfront: xvdc: flush diskcache: enabled; persistent grants:=
 enabled; indirect descriptors: enabled;=0D
[    1.392405] blkfront: xvdd: flush diskcache: enabled; persistent grants:=
 enabled; indirect descriptors: enabled;=0D
[    1.417232]   Magic number: 1:252:3141=0D
[    1.417399] console [netcon0] enabled=0D
[    1.417417] netconsole: network logging started=0D
[    1.417441] hctosys: unable to open rtc device (rtc0)=0D
[    1.420219] Freeing unused kernel memory: 1452K (ffffffff81d33000 - ffff=
ffff81e9e000)=0D
[    1.420258] Write protecting the kernel read-only data: 12288k=0D
[    1.434129] Freeing unused kernel memory: 1508K (ffff880001687000 - ffff=
880001800000)=0D
[    1.435108] Freeing unused kernel memory: 1116K (ffff880001ae9000 - ffff=
880001c00000)=0D
Qubes initramfs script here:=0D
[    1.440455] random: modprobe urandom read with 33 bits of entropy availa=
ble=0D
modprobe: chdir(4.4.0-1.pvops.qubes.x86_64): No such file or directory=0D
modprobe: chdir(4.4.0-1.pvops.qubes.x86_64): No such file or directory=0D
Qubes: Cannot load Xen Block Frontend...=0D
Waiting for /dev/xvda* devices...=0D
Qubes: Doing COW setup for AppVM...=0D
sfdisk: Checking that no-one is using this disk right now ...=0D
sfdisk: OK=0D
sfdisk:  /dev/xvdc: unrecognized partition table type=0D
sfdisk: No partitions found=0D
sfdisk: Warning: partition 1 does not end at a cylinder boundary=0D
sfdisk: Warning: partition 2 does not start at a cylinder boundary=0D
sfdisk: Warning: partition 2 does not end at a cylinder boundary=0D
sfdisk: Warning: no primary partition is marked bootable (active)=0D
This does not matter for LILO, but the DOS MBR will not boot this disk.=0D
[    1.448877]  xvdc: xvdc1 xvdc2=0D
sfdisk: If you created or changed a DOS partition, /dev/foo7, say, then use=
 dd(1)=0D
to zero the first 512 bytes:  dd if=3D/dev/zero of=3D/dev/foo7 bs=3D512 cou=
nt=3D1=0D
(See fdisk(8).)=0D
Setting up swapspace version 1, size =3D 1073737728 bytes=0D
UUID=3Dda20ab8f-e3b2-460f-8ea1-c77204a0f63d=0D
Qubes: done.=0D
modprobe: chdir(4.4.0-1.pvops.qubes.x86_64): No such file or directory=0D
[    1.464947] EXT4-fs (dm-0): couldn't mount as ext3 due to feature incomp=
atibilities=0D
[    1.465108] EXT4-fs (dm-0): couldn't mount as ext2 due to feature incomp=
atibilities=0D
[    1.466566] EXT4-fs (dm-0): mounted filesystem with ordered data mode. O=
pts: (null)=0D
Waiting for /dev/xvdd device...=0D
[    1.471024] EXT4-fs (xvdd): mounting ext3 file system using the ext4 sub=
system=0D
[    1.471931] EXT4-fs (xvdd): mounted filesystem with ordered data mode. O=
pts: (null)=0D
[    1.474541] EXT4-fs (dm-0): re-mounted. Opts: data=3Dordered=0D
[    1.484119] EXT4-fs (dm-0): re-mounted. Opts: data=3Dordered=0D
mount: mounting /tmp/modules/4.4.0-1.pvops.qubes.x86_64 on /sysroot/lib/mod=
ules/4.4.0-1.pvops.qubes.x86_64 failed: No such file or directory=0D
[    1.578686] systemd[1]: systemd 216 running in system mode. (+PAM +AUDIT=
 +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNU=
TLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN)=0D
[    1.578778] systemd[1]: Detected virtualization 'xen'.=0D
[    1.578793] systemd[1]: Detected architecture 'x86-64'.=0D
=0D
Welcome to .[0;34mFedora 21 (Twenty One).[0m!=0D
=0D
[    1.579269] systemd[1]: No hostname configured.=0D
[    1.579287] systemd[1]: Set hostname to <localhost>.=0D
[    1.643346] systemd[1]: Configuration file /usr/lib/systemd/system/audit=
d.service is marked world-inaccessible. This has no effect as configuration=
 data is accessible via APIs without restrictions. Proceeding anyway.=0D
[    1.673346] systemd[1]: Starting Forward Password Requests to Wall Direc=
tory Watch.=0D
[    1.673475] systemd[1]: Started Forward Password Requests to Wall Direct=
ory Watch.=0D
[    1.673505] systemd[1]: Expecting device dev-hvc0.device...=0D
         Expecting device dev-hvc0.device...=0D
[    1.673685] systemd[1]: Starting Remote File Systems.=0D
[.[32m  OK  .[0m] Reached target Remote File Systems.=0D
[    1.673773] systemd[1]: Reached target Remote File Systems.=0D
[    1.673823] systemd[1]: Starting Arbitrary Executable File Formats File =
System Automount Point.=0D
[.[32m  OK  .[0m] Set up automount Arbitrary Executab...ats File System Aut=
omount Point.=0D
[    1.674059] systemd[1]: Set up automount Arbitrary Executable File Forma=
ts File System Automount Point.=0D
[    1.674091] systemd[1]: Starting Encrypted Volumes.=0D
[.[32m  OK  .[0m] Reached target Encrypted Volumes.=0D
[    1.674175] systemd[1]: Reached target Encrypted Volumes.=0D
[    1.674201] systemd[1]: Expecting device dev-xvdc1.device...=0D
         Expecting device dev-xvdc1.device...=0D
[    1.674287] systemd[1]: Starting Root Slice.=0D
[.[32m  OK  .[0m] Created slice Root Slice.=0D
[    1.690630] systemd[1]: Created slice Root Slice.=0D
[    1.690661] systemd[1]: Starting Delayed Shutdown Socket.=0D
[.[32m  OK  .[0m] Listening on Delayed Shutdown Socket.=0D
[    1.690788] systemd[1]: Listening on Delayed Shutdown Socket.=0D
[    1.690813] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.=
=0D
[.[32m  OK  .[0m] Listening on /dev/initctl Compatibility Named Pipe.=0D
[    1.690938] systemd[1]: Listening on /dev/initctl Compatibility Named Pi=
pe.=0D
[    1.690970] systemd[1]: Starting udev Control Socket.=0D
[.[32m  OK  .[0m] Listening on udev Control Socket.=0D
[    1.691101] systemd[1]: Listening on udev Control Socket.=0D
[    1.691130] systemd[1]: Starting udev Kernel Socket.=0D
[.[32m  OK  .[0m] Listening on udev Kernel Socket.=0D
[    1.691234] systemd[1]: Listening on udev Kernel Socket.=0D
[    1.691257] systemd[1]: Starting User and Session Slice.=0D
[.[32m  OK  .[0m] Created slice User and Session Slice.=0D
[    1.691711] systemd[1]: Created slice User and Session Slice.=0D
[    1.691745] systemd[1]: Starting Journal Socket.=0D
[.[32m  OK  .[0m] Listening on Journal Socket.=0D
[    1.691894] systemd[1]: Listening on Journal Socket.=0D
[    1.691942] systemd[1]: Starting System Slice.=0D
[.[32m  OK  .[0m] Created slice System Slice.=0D
[    1.692393] systemd[1]: Created slice System Slice.=0D
[    1.692442] systemd[1]: Mounting Temporary Directory...=0D
         Mounting Temporary Directory...=0D
[    1.692722] systemd[1]: tmp.mount: Directory /tmp to mount over is not e=
mpty, mounting anyway.=0D
[    1.694761] systemd[1]: Starting Journal Socket (/dev/log).=0D
[    1.696712] systemd[1]: Starting udev Coldplug all Devices...=0D
         Starting udev Coldplug all Devices...=0D
[    1.699255] systemd[1]: Mounting Huge Pages File System...=0D
         Mounting Huge Pages File System...=0D
[    1.701608] systemd[1]: Mounting Debug File System...=0D
         Mounting Debug File System...=0D
[    1.704788] systemd[1]: Mounting POSIX Message Queue File System...=0D
         Mounting POSIX Message Queue File System...=0D
[    1.719399] systemd[1]: Started Create list of required static device no=
des for the current kernel.=0D
[    1.719508] systemd[1]: Starting system-serial\x2dgetty.slice.=0D
[.[32m  OK  .[0m] Created slice system-serial\x2dgetty.slice.=0D
[    1.720294] systemd[1]: Created slice system-serial\x2dgetty.slice.=0D
[    1.720357] systemd[1]: Started Collect Read-Ahead Data.=0D
[    1.720401] systemd[1]: Started Replay Read-Ahead Data.=0D
[    1.720437] systemd[1]: Starting File System Check on Root Device...=0D
         Starting File System Check on Root Device...=0D
[    1.727937] systemd[1]: Starting Load Kernel Modules...=0D
         Starting Load Kernel Modules...=0D
[    1.730073] systemd[1]: Starting Setup Virtual Console...=0D
         Starting Setup Virtual Console...=0D
[    1.745613] systemd[1]: Starting Load legacy module configuration...=0D
         Starting Load legacy module configuration...=0D
[    1.764453] systemd[1]: Started Set Up Additional Binary Formats.=0D
[    1.764540] systemd[1]: Starting Slices.=0D
[.[32m  OK  .[0m] Reached target Slices.=0D
[    1.764610] systemd[1]: Reached target Slices.=0D
[.[32m  OK  .[0m] Mounted POSIX Message Queue File System.=0D
[    1.765640] systemd[1]: Mounted POSIX Message Queue File System.=0D
[.[32m  OK  .[0m] Mounted Debug File System.=0D
[    1.765721] systemd[1]: Mounted Debug File System.=0D
[.[32m  OK  .[0m] Mounted Huge Pages File System.=0D
[    1.765779] systemd[1]: Mounted Huge Pages File System.=0D
[.[32m  OK  .[0m] Mounted Temporary Directory.=0D
[    1.765860] systemd[1]: Mounted Temporary Directory.=0D
[.[32m  OK  .[0m] Listening on Journal Socket (/dev/log).=0D
[    1.766401] systemd[1]: Listening on Journal Socket (/dev/log).=0D
[    1.768972] systemd[1]: systemd-modules-load.service: main process exite=
d, code=3Dexited, status=3D1/FAILURE=0D
[.[1;31mFAILED.[0m] Failed to start Load Kernel Modules.=0D
See "systemctl status systemd-modules-load.service" for details.=0D
[    1.769555] systemd[1]: Failed to start Load Kernel Modules.=0D
[    1.769579] systemd[1]: Unit systemd-modules-load.service entered failed=
 state.=0D
[    1.774333] systemd[1]: systemd-modules-load.service failed.=0D
[.[32m  OK  .[0m] Started Setup Virtual Console.=0D
[    1.774886] systemd[1]: Started Setup Virtual Console.=0D
[    1.806920] systemd[1]: Mounting Configuration File System...=0D
         Mounting Configuration File System...=0D
[    1.809565] systemd[1]: Starting Apply Kernel Variables...=0D
         Starting Apply Kernel Variables...=0D
[    1.879402] systemd[1]: Mounted FUSE Control File System.=0D
[    1.879728] systemd[1]: Starting Journal Service...=0D
         Starting Journal Service...=0D
[.[32m  OK  .[0m] Started udev Coldplug all Devices.=0D
[    1.898192] systemd[1]: Started udev Coldplug all Devices.=0D
[    1.923752] systemd[1]: Starting Show Plymouth Boot Screen...=0D
         Starting Show Plymouth Boot Screen...=0D
[.[32m  OK  .[0m] Mounted Configuration File System.=0D
[    1.950124] systemd[1]: Mounted Configuration File System.=0D
[.[32m  OK  .[0m] Started Load legacy module configuration.=0D
[    1.950948] systemd[1]: Started Load legacy module configuration.=0D
[.[32m  OK  .[0m] Started Apply Kernel Variables.=0D
[    1.951688] systemd[1]: Started Apply Kernel Variables.=0D
[    1.982704] systemd-fsck[142]: /dev/mapper/dmroot: clean, 139351/655360 =
files, 1285520/2621440 blocks=0D
[.[32m  OK  .[0m] Started Journal Service.=0D
[    1.984482] systemd[1]: Started Journal Service.=0D
[.[32m  OK  .[0m] Started File System Check on Root Device.=0D
[    2.049986] EXT4-fs (dm-0): re-mounted. Opts: (null)=0D
[    2.118620] systemd-journald[173]: Received request to flush runtime jou=
rnal from PID 1=0D
[    5.367681] Adding 1048572k swap on /dev/xvdc1.  Priority:-1 extents:1 a=
cross:1048572k SSFS=0D
         Starting Remount Root and Kernel File Systems...=0D=0D
[.[32m  OK  .[0m] Started Remount Root and Kernel File Systems.=0D=0D
         Starting Configure read-only root support...=0D=0D
         Starting Flush Journal to Persistent Storage...=0D=0D
         Starting Create Static Device Nodes in /dev...=0D=0D
         Starting Load/Save Random Seed...=0D=0D
[.[32m  OK  .[0m] Started Configure read-only root support.=0D=0D
[.[32m  OK  .[0m] Started Load/Save Random Seed.=0D=0D
[.[32m  OK  .[0m] Started Create Static Device Nodes in /dev.=0D=0D
         Starting udev Kernel Device Manager...=0D=0D
[.[32m  OK  .[0m] Reached target Local File Systems (Pre).=0D=0D
         Mounting /proc/xen...=0D=0D
[.[32m  OK  .[0m] Mounted /proc/xen.=0D=0D
[.[32m  OK  .[0m] Reached target Local File Systems.=0D=0D
         Starting Qubes DB agent...=0D=0D
         Starting Tell Plymouth To Write Out Runtime Data...=0D=0D
[.[32m  OK  .[0m] Started Tell Plymouth To Write Out Runtime Data.=0D=0D
[.[32m  OK  .[0m] Started Qubes DB agent.=0D=0D
         Starting Qubes Random Seed...=0D=0D
         Starting Init Qubes Services settings...=0D=0D
[.[32m  OK  .[0m] Started udev Kernel Device Manager.=0D=0D
[.[32m  OK  .[0m] Started Qubes Random Seed.=0D=0D
[.[32m  OK  .[0m] Started Flush Journal to Persistent Storage.=0D=0D
         Starting Create Volatile Files and Directories...=0D=0D
[.[32m  OK  .[0m] Found device /dev/hvc0.=0D=0D
[.[32m  OK  .[0m] Started Create Volatile Files and Directories.=0D=0D
         Starting Update UTMP about System Boot/Shutdown...=0D=0D
[.[32m  OK  .[0m] Started Update UTMP about System Boot/Shutdown.=0D=0D
=2E%G[.[32m  OK  .[0m] Started Init Qubes Services settings.=0D=0D
[.[32m  OK  .[0m] Found device /dev/xvdc1.=0D=0D
         Activating swap /dev/xvdc1...=0D=0D
[.[32m  OK  .[0m] Activated swap /dev/xvdc1.=0D=0D
[.[32m  OK  .[0m] Reached target Swap.=0D=0D
[.[32m  OK  .[0m] Reached target System Initialization.=0D=0D
[.[32m  OK  .[0m] Listening on CUPS Printing Service Sockets.=0D=0D
         Starting Manage Sound Card State (restore and store)...=0D=0D
[.[32m  OK  .[0m] Started Manage Sound Card State (restore and store).=0D=0D
[.[32m  OK  .[0m] Reached target Timers.=0D=0D
[.[32m  OK  .[0m] Listening on D-Bus System Message Bus Socket.=0D=0D
[.[32m  OK  .[0m] Reached target Sockets.=0D=0D
[.[32m  OK  .[0m] Started Show Plymouth Boot Screen.=0D=0D
[.[32m  OK  .[0m] Reached target Paths.=0D=0D
[.[32m  OK  .[0m] Reached target Basic System.=0D=0D
         Starting ABRT Automated Bug Reporting Tool...=0D=0D
[.[32m  OK  .[0m] Started ABRT Automated Bug Reporting Tool.=0D=0D
         Starting Initialize and mount /rw and /home...=0D=0D
         Starting Initialize and mount /rw and /home...=0D=0D
         Starting ABRT kernel log watcher...=0D=0D
[.[32m  OK  .[0m] Started ABRT kernel log watcher.=0D=0D
         Starting Install ABRT coredump hook...=0D=0D
         Starting Entropy Daemon based on the HAVEGE algorithm...=0D=0D
[.[32m  OK  .[0m] Started Entropy Daemon based on the HAVEGE algorithm.=0D=
=0D
         Starting Machine Check Exception Logging Daemon...=0D=0D
[    5.654686] random: nonblocking pool is initialized=0D
         Starting Qubes memory information reporter...=0D=0D
         Starting Qubes remote exec agent...=0D=0D
         Starting ABRT Xorg log watcher...=0D=0D
[.[32m  OK  .[0m] Started ABRT Xorg log watcher.=0D=0D
         Starting Qubes base firewall settings...=0D=0D
         Starting Login Service...=0D=0D
         Starting Permit User Sessions...=0D=0D
         Starting LSB: Start/stop xen driver domain daemon...=0D=0D
         Starting D-Bus System Message Bus...=0D=0D
[    5.823870] EXT4-fs (xvdb): recovery complete=0D
[.[32m  OK  .[0m] Started D-Bus System Message Bus.=0D=0D
[    5.831639] EXT4-fs (xvdb): mounted filesystem with ordered data mode. O=
pts: discard=0D
[.[32m  OK  .[0m] Started Initialize and mount /rw and /home.=0D=0D
[.[32m  OK  .[0m] Started Initialize and mount /rw and /home.=0D=0D
[.[32m  OK  .[0m] Started Install ABRT coredump hook.=0D=0D
[.[32m  OK  .[0m] Started Machine Check Exception Logging Daemon.=0D=0D
[.[32m  OK  .[0m] Started Qubes memory information reporter.=0D=0D
[.[32m  OK  .[0m] Started Qubes remote exec agent.=0D=0D
[.[1;31mFAILED.[0m] Failed to start Qubes base firewall settings.=0D=0D
See "systemctl status qubes-iptables.service" for details.=0D=0D
[.[32m  OK  .[0m] Started Permit User Sessions.=0D=0D
[.[32m  OK  .[0m] Started LSB: Start/stop xen driver domain daemon.=0D=0D
[.[32m  OK  .[0m] Started Login Service.=0D=0D
         Starting Job spooling tools...=0D=0D
[.[32m  OK  .[0m] Started Job spooling tools.=0D=0D
         Starting Wait for Plymouth Boot Screen to Quit...=0D=0D
         Starting Terminate Plymouth Boot Screen...=0D=0D
         Starting Qubes misc post-boot actions...=0D=0D
         Starting Qubes GUI Agent...=0D=0D
=0D=0D
Fedora release 21 (Twenty One)=0D
Kernel 4.4.0-1.pvops.qubes.x86_64 on an x86_64 (hvc0)=0D
=0D
netdebug login: [A=08 =08=08 =08root=0D=0D
Last login: Fri Jan 22 01:18:08 on =0D
[root@netdebug ~]# ping =08=08=08=08=08.[Kip r=0D
default via 10.137.2.1 dev eth0 =0D
10.137.2.1 dev eth0  scope link =0D
[root@netdebug ~]# ping -f 10.137.2.1=0D
PING 10.137.2.1 (10.137.2.1) 56(84) bytes of data.=0D
(...)=0D
=0D
=2E..........[  111.001689] page:ffffea00004bffc0 count:0 mapcount:0 mappin=
g:          (null) index:0x0=0D
[  111.001710] flags: 0x3fff8000000000()=0D
[  111.001718] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_coun=
t) =3D=3D 0)=0D
[  111.001739] ------------[ cut here ]------------=0D
[  111.001746] kernel BUG at include/linux/mm.h:342!=0D
[  111.001753] invalid opcode: 0000 [#1] SMP =0D
[  111.001761] Modules linked in:=0D
[  111.001769] CPU: 1 PID: 23 Comm: xenwatch Not tainted 4.4.0-1.pvops.qube=
s.x86_64 #20=0D
[  111.001780] task: ffff880012c88000 ti: ffff880012c7c000 task.ti: ffff880=
012c7c000=0D
[  111.001790] RIP: e030:[<ffffffff81174a38>]  [<ffffffff81174a38>] __free_=
pages+0x38/0x40=0D
[  111.001807] RSP: e02b:ffff880012c7fc30  EFLAGS: 00010246=0D
[  111.001814] RAX: 0000000000000044 RBX: 000077ff80000000 RCX: 00000000000=
00044=0D
[  111.001822] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880013d=
0de10=0D
[  111.001829] RBP: ffff880012c7fc30 R08: 0000000000000000 R09: 00000000000=
00000=0D
[  111.001837] R10: ffffea0000453f00 R11: ffffffff81863ec0 R12: 00000000000=
00000=0D
[  111.001844] R13: ffff880012eb9c00 R14: ffff880012fff000 R15: 00000000000=
00000=0D
[  111.001857] FS:  00007f84805fe700(0000) GS:ffff880013d00000(0000) knlGS:=
0000000000000000=0D
[  111.001867] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b=0D
[  111.001874] CR2: 000055af04b6d000 CR3: 00000000008e8000 CR4: 00000000000=
02660=0D
[  111.001882] Stack:=0D
[  111.001887]  ffff880012c7fc50 ffffffff81174a9c 000000000000000e 00000000=
00000004=0D
[  111.001900]  ffff880012c7fc80 ffffffff813f709e ffff87ffffffffff ffff8800=
11528d68=0D
[  111.001912]  ffff880012eb9c00 ffff880011528000 ffff880012c7fce8 ffffffff=
814b58c2=0D
[  111.001924] Call Trace:=0D
[  111.001932]  [<ffffffff81174a9c>] free_pages+0x5c/0x70=0D
[  111.001942]  [<ffffffff813f709e>] gnttab_end_foreign_access+0x12e/0x160=
=0D
[  111.001952]  [<ffffffff814b58c2>] xennet_disconnect_backend.isra.26+0x16=
2/0x3b0=0D
[  111.001963]  [<ffffffff814b5b91>] xennet_remove+0x31/0x80=0D
[  111.001971]  [<ffffffff814011e5>] xenbus_dev_remove+0x55/0xb0=0D
[  111.001980]  [<ffffffff8145d596>] __device_release_driver+0x96/0x130=0D
[  111.002639]  [<ffffffff8145d653>] device_release_driver+0x23/0x30=0D
[  111.002639]  [<ffffffff8145c3a1>] bus_remove_device+0x101/0x170=0D
[  111.002639]  [<ffffffff814586a9>] device_del+0x139/0x270=0D
[  111.002639]  [<ffffffff813ffb60>] ? unregister_xenbus_watch+0x1d0/0x1d0=
=0D
[  111.002639]  [<ffffffff814587fe>] device_unregister+0x1e/0x60=0D
[  111.002639]  [<ffffffff81401053>] xenbus_dev_changed+0xa3/0x1e0=0D
[  111.002639]  [<ffffffff8167f18b>] ? _raw_spin_lock_irqsave+0x1b/0x40=0D
[  111.002639]  [<ffffffff813ffb60>] ? unregister_xenbus_watch+0x1d0/0x1d0=
=0D
[  111.002639]  [<ffffffff81402ea5>] frontend_changed+0x25/0x50=0D
[  111.002639]  [<ffffffff813ffbe7>] xenwatch_thread+0x87/0x140=0D
[  111.002639]  [<ffffffff810b3b60>] ? wait_woken+0x80/0x80=0D
[  111.002639]  [<ffffffff81090838>] kthread+0xd8/0xf0=0D
[  111.002639]  [<ffffffff81090760>] ? kthread_park+0x60/0x60=0D
[  111.002639]  [<ffffffff8167f70f>] ret_from_fork+0x3f/0x70=0D
[  111.002639]  [<ffffffff81090760>] ? kthread_park+0x60/0x60=0D
[  111.002639] Code: c0 74 1c f0 ff 4f 1c 74 02 5d c3 85 f6 74 07 e8 ff f8 =
ff ff 5d c3 31 f6 e8 f6 fd ff ff 5d c3 48 c7 c6 20 27 a2 81 e8 28 47 02 00 =
<0f> 0b 66 0f 1f 44 00 00 66 66 66 66 90 48 85 ff 75 02 f3 c3 55 =0D
[  111.002639] RIP  [<ffffffff81174a38>] __free_pages+0x38/0x40=0D
[  111.002639]  RSP <ffff880012c7fc30>=0D
[  111.003417] ---[ end trace e389324fec932a31 ]---=0D
=2E.............................................................=03=0D
--- 10.137.2.1 ping statistics ---=0D
27465 packets transmitted, 27392 received, 0% packet loss, time 11156ms=0D
rtt min/avg/max/mdev =3D 0.053/0.071/12.598/0.109 ms, pipe 2, ipg/ewma 0.40=
6/0.060 ms=0D

--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="netdebug.conf"

<domain type='xen'>
  <name>netdebug</name>
  <uuid>4e22b40c-e06e-46d1-aaaa-2293487b81b9</uuid>
  <memory unit='MiB'>4000</memory>
  <currentMemory unit='MiB'>400</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='xenpv'>linux</type>
    <kernel>/var/lib/qubes/vm-kernels/4.4-debug/vmlinuz</kernel>
    <initrd>/var/lib/qubes/vm-kernels/4.4-debug/initramfs</initrd>
    <cmdline>root=/dev/mapper/dmroot ro nomodeset console=hvc0 rd_NO_PLYMOUTH 3 rd.break</cmdline>
  </os>
  <clock offset='utc' adjustment='reset'>
    <timer name="tsc" mode="native"/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>destroy</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <disk type='block' device='disk'>
      <driver name='phy'/>
      <source dev='/var/lib/qubes/vm-templates/fedora-21/root.img:/var/lib/qubes/vm-templates/fedora-21/root-cow.img'/>
      <target dev='xvda' bus='xen'/>
      <readonly/>
      <script path='block-snapshot'/>
    </disk>

    <disk type='block' device='disk'>
      <driver name='phy'/>
      <source dev='/var/lib/qubes/appvms/netdebug/private.img'/>
      <target dev='xvdb' bus='xen'/>
    </disk>

    <disk type='block' device='disk'>
      <driver name='phy'/>
      <source dev='/var/lib/qubes/appvms/netdebug/volatile.img'/>
      <target dev='xvdc' bus='xen'/>
    </disk>

    <disk type='block' device='disk'>
      <driver name='phy'/>
      <source dev='/var/lib/qubes/vm-kernels/4.4-debug/modules.img'/>
      <target dev='xvdd' bus='xen'/>
      <readonly/>
    </disk>

    <interface type='ethernet'>
      <mac address='00:16:3E:5E:6C:1B'/>
      <ip address='10.137.2.29'/>
      <script path='vif-route-qubes'/>
      <backenddomain name='sys-firewall'/>
    </interface>


    <console type='pty'>
      <target type='xen' port='0'/>
    </console>
  </devices>
</domain>


--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="xs-backend-before.txt"

/local/domain/2/backend/vif/49/0/frontend = "/local/domain/49/device/vif/0"   (n2,r49)
/local/domain/2/backend/vif/49/0/frontend-id = "49"   (n2,r49)
/local/domain/2/backend/vif/49/0/online = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/state = "4"   (n2,r49)
/local/domain/2/backend/vif/49/0/script = "/etc/xen/scripts/vif-route-qubes"   (n2,r49)
/local/domain/2/backend/vif/49/0/mac = "00:16:3e:5e:6c:1b"   (n2,r49)
/local/domain/2/backend/vif/49/0/ip = "10.137.2.29"   (n2,r49)
/local/domain/2/backend/vif/49/0/handle = "0"   (n2,r49)
/local/domain/2/backend/vif/49/0/type = "vif"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-sg = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-gso-tcpv4 = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-gso-tcpv6 = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-ipv6-csum-offload = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-rx-copy = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-rx-flip = "0"   (n2,r49)
/local/domain/2/backend/vif/49/0/feature-split-event-channels = "1"   (n2,r49)
/local/domain/2/backend/vif/49/0/multi-queue-max-queues = "2"   (n2,r49)
/local/domain/2/backend/vif/49/0/hotplug-status = "connected"   (n2,r49)

--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="xs-frontend-before.txt"

/local/domain/49/device/vif/0 = ""   (n49,r2)
/local/domain/49/device/vif/0/backend = "/local/domain/2/backend/vif/49/0"   (n49,r2)
/local/domain/49/device/vif/0/backend-id = "2"   (n49,r2)
/local/domain/49/device/vif/0/state = "4"   (n49,r2)
/local/domain/49/device/vif/0/handle = "0"   (n49,r2)
/local/domain/49/device/vif/0/mac = "00:16:3e:5e:6c:1b"   (n49,r2)
/local/domain/49/device/vif/0/multi-queue-num-queues = "2"   (n49,r2)
/local/domain/49/device/vif/0/queue-0 = ""   (n49,r2)
/local/domain/49/device/vif/0/queue-0/tx-ring-ref = "1280"   (n49,r2)
/local/domain/49/device/vif/0/queue-0/rx-ring-ref = "1281"   (n49,r2)
/local/domain/49/device/vif/0/queue-0/event-channel-tx = "19"   (n49,r2)
/local/domain/49/device/vif/0/queue-0/event-channel-rx = "20"   (n49,r2)
/local/domain/49/device/vif/0/queue-1 = ""   (n49,r2)
/local/domain/49/device/vif/0/queue-1/tx-ring-ref = "1282"   (n49,r2)
/local/domain/49/device/vif/0/queue-1/rx-ring-ref = "1283"   (n49,r2)
/local/domain/49/device/vif/0/queue-1/event-channel-tx = "21"   (n49,r2)
/local/domain/49/device/vif/0/queue-1/event-channel-rx = "22"   (n49,r2)
/local/domain/49/device/vif/0/request-rx-copy = "1"   (n49,r2)
/local/domain/49/device/vif/0/feature-rx-notify = "1"   (n49,r2)
/local/domain/49/device/vif/0/feature-sg = "1"   (n49,r2)
/local/domain/49/device/vif/0/feature-gso-tcpv4 = "1"   (n49,r2)
/local/domain/49/device/vif/0/feature-gso-tcpv6 = "1"   (n49,r2)
/local/domain/49/device/vif/0/feature-ipv6-csum-offload = "1"   (n49,r2)

--FCF9ydJxlAJsfRTu
Content-Type: application/x-troff-man
Content-Disposition: attachment; filename="config-4.4"
Content-Transfer-Encoding: quoted-printable

#=0A# Automatically generated file; DO NOT EDIT.=0A# Linux/x86 4.4.0-rc5 Ke=
rnel Configuration=0A#=0ACONFIG_64BIT=3Dy=0ACONFIG_X86_64=3Dy=0ACONFIG_X86=
=3Dy=0ACONFIG_INSTRUCTION_DECODER=3Dy=0ACONFIG_PERF_EVENTS_INTEL_UNCORE=3Dy=
=0ACONFIG_OUTPUT_FORMAT=3D"elf64-x86-64"=0ACONFIG_ARCH_DEFCONFIG=3D"arch/x8=
6/configs/x86_64_defconfig"=0ACONFIG_LOCKDEP_SUPPORT=3Dy=0ACONFIG_STACKTRAC=
E_SUPPORT=3Dy=0ACONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy=0ACONFIG_MMU=3Dy=0ACONFI=
G_NEED_DMA_MAP_STATE=3Dy=0ACONFIG_NEED_SG_DMA_LENGTH=3Dy=0ACONFIG_GENERIC_I=
SA_DMA=3Dy=0ACONFIG_GENERIC_BUG=3Dy=0ACONFIG_GENERIC_BUG_RELATIVE_POINTERS=
=3Dy=0ACONFIG_GENERIC_HWEIGHT=3Dy=0ACONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy=0ACONFI=
G_RWSEM_XCHGADD_ALGORITHM=3Dy=0ACONFIG_GENERIC_CALIBRATE_DELAY=3Dy=0ACONFIG=
_ARCH_HAS_CPU_RELAX=3Dy=0ACONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy=0ACONFIG_HAVE=
_SETUP_PER_CPU_AREA=3Dy=0ACONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy=0ACONFI=
G_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy=0ACONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy=
=0ACONFIG_ARCH_SUSPEND_POSSIBLE=3Dy=0ACONFIG_ARCH_WANT_HUGE_PMD_SHARE=3Dy=
=0ACONFIG_ARCH_WANT_GENERAL_HUGETLB=3Dy=0ACONFIG_ZONE_DMA32=3Dy=0ACONFIG_AU=
DIT_ARCH=3Dy=0ACONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy=0ACONFIG_ARCH_SU=
PPORTS_DEBUG_PAGEALLOC=3Dy=0ACONFIG_HAVE_INTEL_TXT=3Dy=0ACONFIG_X86_64_SMP=
=3Dy=0ACONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-rdi -fcall-saved-rsi -fca=
ll-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-=
r10 -fcall-saved-r11"=0ACONFIG_ARCH_SUPPORTS_UPROBES=3Dy=0ACONFIG_FIX_EARLY=
CON_MEM=3Dy=0ACONFIG_PGTABLE_LEVELS=3D4=0ACONFIG_DEFCONFIG_LIST=3D"/lib/mod=
ules/$UNAME_RELEASE/.config"=0ACONFIG_IRQ_WORK=3Dy=0ACONFIG_BUILDTIME_EXTAB=
LE_SORT=3Dy=0A=0A#=0A# General setup=0A#=0ACONFIG_INIT_ENV_ARG_LIMIT=3D32=
=0ACONFIG_CROSS_COMPILE=3D""=0A# CONFIG_COMPILE_TEST is not set=0ACONFIG_LO=
CALVERSION=3D"-1.pvops.qubes.x86_64"=0A# CONFIG_LOCALVERSION_AUTO is not se=
t=0ACONFIG_HAVE_KERNEL_GZIP=3Dy=0ACONFIG_HAVE_KERNEL_BZIP2=3Dy=0ACONFIG_HAV=
E_KERNEL_LZMA=3Dy=0ACONFIG_HAVE_KERNEL_XZ=3Dy=0ACONFIG_HAVE_KERNEL_LZO=3Dy=
=0ACONFIG_HAVE_KERNEL_LZ4=3Dy=0ACONFIG_KERNEL_GZIP=3Dy=0A# CONFIG_KERNEL_BZ=
IP2 is not set=0A# CONFIG_KERNEL_LZMA is not set=0A# CONFIG_KERNEL_XZ is no=
t set=0A# CONFIG_KERNEL_LZO is not set=0A# CONFIG_KERNEL_LZ4 is not set=0AC=
ONFIG_DEFAULT_HOSTNAME=3D"(none)"=0ACONFIG_SWAP=3Dy=0ACONFIG_SYSVIPC=3Dy=0A=
CONFIG_SYSVIPC_SYSCTL=3Dy=0ACONFIG_POSIX_MQUEUE=3Dy=0ACONFIG_POSIX_MQUEUE_S=
YSCTL=3Dy=0ACONFIG_CROSS_MEMORY_ATTACH=3Dy=0ACONFIG_FHANDLE=3Dy=0A# CONFIG_=
USELIB is not set=0ACONFIG_AUDIT=3Dy=0ACONFIG_HAVE_ARCH_AUDITSYSCALL=3Dy=0A=
CONFIG_AUDITSYSCALL=3Dy=0ACONFIG_AUDIT_WATCH=3Dy=0ACONFIG_AUDIT_TREE=3Dy=0A=
=0A#=0A# IRQ subsystem=0A#=0ACONFIG_GENERIC_IRQ_PROBE=3Dy=0ACONFIG_GENERIC_=
IRQ_SHOW=3Dy=0ACONFIG_GENERIC_PENDING_IRQ=3Dy=0ACONFIG_IRQ_DOMAIN=3Dy=0ACON=
FIG_IRQ_DOMAIN_HIERARCHY=3Dy=0ACONFIG_GENERIC_MSI_IRQ=3Dy=0ACONFIG_GENERIC_=
MSI_IRQ_DOMAIN=3Dy=0A# CONFIG_IRQ_DOMAIN_DEBUG is not set=0ACONFIG_IRQ_FORC=
ED_THREADING=3Dy=0ACONFIG_SPARSE_IRQ=3Dy=0ACONFIG_CLOCKSOURCE_WATCHDOG=3Dy=
=0ACONFIG_ARCH_CLOCKSOURCE_DATA=3Dy=0ACONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCL=
E=3Dy=0ACONFIG_GENERIC_TIME_VSYSCALL=3Dy=0ACONFIG_GENERIC_CLOCKEVENTS=3Dy=
=0ACONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy=0ACONFIG_GENERIC_CLOCKEVENTS_MI=
N_ADJUST=3Dy=0ACONFIG_GENERIC_CMOS_UPDATE=3Dy=0A=0A#=0A# Timers subsystem=
=0A#=0ACONFIG_TICK_ONESHOT=3Dy=0ACONFIG_NO_HZ_COMMON=3Dy=0A# CONFIG_HZ_PERI=
ODIC is not set=0A# CONFIG_NO_HZ_IDLE is not set=0ACONFIG_NO_HZ_FULL=3Dy=0A=
# CONFIG_NO_HZ_FULL_ALL is not set=0A# CONFIG_NO_HZ_FULL_SYSIDLE is not set=
=0ACONFIG_NO_HZ=3Dy=0ACONFIG_HIGH_RES_TIMERS=3Dy=0A=0A#=0A# CPU/Task time a=
nd stats accounting=0A#=0ACONFIG_VIRT_CPU_ACCOUNTING=3Dy=0ACONFIG_VIRT_CPU_=
ACCOUNTING_GEN=3Dy=0ACONFIG_BSD_PROCESS_ACCT=3Dy=0ACONFIG_BSD_PROCESS_ACCT_=
V3=3Dy=0ACONFIG_TASKSTATS=3Dy=0ACONFIG_TASK_DELAY_ACCT=3Dy=0ACONFIG_TASK_XA=
CCT=3Dy=0ACONFIG_TASK_IO_ACCOUNTING=3Dy=0A=0A#=0A# RCU Subsystem=0A#=0ACONF=
IG_TREE_RCU=3Dy=0A# CONFIG_RCU_EXPERT is not set=0ACONFIG_SRCU=3Dy=0ACONFIG=
_TASKS_RCU=3Dy=0ACONFIG_RCU_STALL_COMMON=3Dy=0ACONFIG_CONTEXT_TRACKING=3Dy=
=0A# CONFIG_CONTEXT_TRACKING_FORCE is not set=0A# CONFIG_TREE_RCU_TRACE is =
not set=0ACONFIG_RCU_NOCB_CPU=3Dy=0A# CONFIG_RCU_NOCB_CPU_NONE is not set=
=0A# CONFIG_RCU_NOCB_CPU_ZERO is not set=0ACONFIG_RCU_NOCB_CPU_ALL=3Dy=0A# =
CONFIG_RCU_EXPEDITE_BOOT is not set=0ACONFIG_BUILD_BIN2C=3Dy=0A# CONFIG_IKC=
ONFIG is not set=0ACONFIG_LOG_BUF_SHIFT=3D18=0ACONFIG_LOG_CPU_MAX_BUF_SHIFT=
=3D12=0ACONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy=0ACONFIG_ARCH_SUPPORTS_NUMA_BA=
LANCING=3Dy=0ACONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=3Dy=0ACONFIG_ARCH_SU=
PPORTS_INT128=3Dy=0ACONFIG_NUMA_BALANCING=3Dy=0ACONFIG_NUMA_BALANCING_DEFAU=
LT_ENABLED=3Dy=0ACONFIG_CGROUPS=3Dy=0A# CONFIG_CGROUP_DEBUG is not set=0ACO=
NFIG_CGROUP_FREEZER=3Dy=0A# CONFIG_CGROUP_PIDS is not set=0ACONFIG_CGROUP_D=
EVICE=3Dy=0ACONFIG_CPUSETS=3Dy=0ACONFIG_PROC_PID_CPUSET=3Dy=0ACONFIG_CGROUP=
_CPUACCT=3Dy=0ACONFIG_PAGE_COUNTER=3Dy=0ACONFIG_MEMCG=3Dy=0ACONFIG_MEMCG_SW=
AP=3Dy=0ACONFIG_MEMCG_SWAP_ENABLED=3Dy=0ACONFIG_MEMCG_KMEM=3Dy=0ACONFIG_CGR=
OUP_HUGETLB=3Dy=0ACONFIG_CGROUP_PERF=3Dy=0ACONFIG_CGROUP_SCHED=3Dy=0ACONFIG=
_FAIR_GROUP_SCHED=3Dy=0ACONFIG_CFS_BANDWIDTH=3Dy=0ACONFIG_RT_GROUP_SCHED=3D=
y=0ACONFIG_BLK_CGROUP=3Dy=0A# CONFIG_DEBUG_BLK_CGROUP is not set=0ACONFIG_C=
GROUP_WRITEBACK=3Dy=0A# CONFIG_CHECKPOINT_RESTORE is not set=0ACONFIG_NAMES=
PACES=3Dy=0ACONFIG_UTS_NS=3Dy=0ACONFIG_IPC_NS=3Dy=0ACONFIG_USER_NS=3Dy=0ACO=
NFIG_PID_NS=3Dy=0ACONFIG_NET_NS=3Dy=0ACONFIG_SCHED_AUTOGROUP=3Dy=0A# CONFIG=
_SYSFS_DEPRECATED is not set=0ACONFIG_RELAY=3Dy=0ACONFIG_BLK_DEV_INITRD=3Dy=
=0ACONFIG_INITRAMFS_SOURCE=3D""=0ACONFIG_RD_GZIP=3Dy=0ACONFIG_RD_BZIP2=3Dy=
=0ACONFIG_RD_LZMA=3Dy=0ACONFIG_RD_XZ=3Dy=0ACONFIG_RD_LZO=3Dy=0ACONFIG_RD_LZ=
4=3Dy=0A# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set=0ACONFIG_SYSCTL=3Dy=0ACONF=
IG_ANON_INODES=3Dy=0ACONFIG_HAVE_UID16=3Dy=0ACONFIG_SYSCTL_EXCEPTION_TRACE=
=3Dy=0ACONFIG_HAVE_PCSPKR_PLATFORM=3Dy=0ACONFIG_BPF=3Dy=0A# CONFIG_EXPERT i=
s not set=0ACONFIG_UID16=3Dy=0ACONFIG_MULTIUSER=3Dy=0ACONFIG_SGETMASK_SYSCA=
LL=3Dy=0ACONFIG_SYSFS_SYSCALL=3Dy=0A# CONFIG_SYSCTL_SYSCALL is not set=0ACO=
NFIG_KALLSYMS=3Dy=0ACONFIG_KALLSYMS_ALL=3Dy=0ACONFIG_PRINTK=3Dy=0ACONFIG_BU=
G=3Dy=0ACONFIG_ELF_CORE=3Dy=0ACONFIG_PCSPKR_PLATFORM=3Dy=0ACONFIG_BASE_FULL=
=3Dy=0ACONFIG_FUTEX=3Dy=0ACONFIG_EPOLL=3Dy=0ACONFIG_SIGNALFD=3Dy=0ACONFIG_T=
IMERFD=3Dy=0ACONFIG_EVENTFD=3Dy=0A# CONFIG_BPF_SYSCALL is not set=0ACONFIG_=
SHMEM=3Dy=0ACONFIG_AIO=3Dy=0ACONFIG_ADVISE_SYSCALLS=3Dy=0A# CONFIG_USERFAUL=
TFD is not set=0ACONFIG_PCI_QUIRKS=3Dy=0ACONFIG_MEMBARRIER=3Dy=0A# CONFIG_E=
MBEDDED is not set=0ACONFIG_HAVE_PERF_EVENTS=3Dy=0A=0A#=0A# Kernel Performa=
nce Events And Counters=0A#=0ACONFIG_PERF_EVENTS=3Dy=0A# CONFIG_DEBUG_PERF_=
USE_VMALLOC is not set=0ACONFIG_VM_EVENT_COUNTERS=3Dy=0ACONFIG_SLUB_DEBUG=
=3Dy=0A# CONFIG_COMPAT_BRK is not set=0A# CONFIG_SLAB is not set=0ACONFIG_S=
LUB=3Dy=0ACONFIG_SLUB_CPU_PARTIAL=3Dy=0A# CONFIG_SYSTEM_DATA_VERIFICATION i=
s not set=0ACONFIG_PROFILING=3Dy=0ACONFIG_TRACEPOINTS=3Dy=0ACONFIG_KEXEC_CO=
RE=3Dy=0ACONFIG_OPROFILE=3Dm=0ACONFIG_OPROFILE_EVENT_MULTIPLEX=3Dy=0ACONFIG=
_HAVE_OPROFILE=3Dy=0ACONFIG_OPROFILE_NMI_TIMER=3Dy=0ACONFIG_KPROBES=3Dy=0AC=
ONFIG_JUMP_LABEL=3Dy=0A# CONFIG_STATIC_KEYS_SELFTEST is not set=0ACONFIG_OP=
TPROBES=3Dy=0ACONFIG_KPROBES_ON_FTRACE=3Dy=0ACONFIG_UPROBES=3Dy=0A# CONFIG_=
HAVE_64BIT_ALIGNED_ACCESS is not set=0ACONFIG_HAVE_EFFICIENT_UNALIGNED_ACCE=
SS=3Dy=0ACONFIG_ARCH_USE_BUILTIN_BSWAP=3Dy=0ACONFIG_KRETPROBES=3Dy=0ACONFIG=
_USER_RETURN_NOTIFIER=3Dy=0ACONFIG_HAVE_IOREMAP_PROT=3Dy=0ACONFIG_HAVE_KPRO=
BES=3Dy=0ACONFIG_HAVE_KRETPROBES=3Dy=0ACONFIG_HAVE_OPTPROBES=3Dy=0ACONFIG_H=
AVE_KPROBES_ON_FTRACE=3Dy=0ACONFIG_HAVE_ARCH_TRACEHOOK=3Dy=0ACONFIG_HAVE_DM=
A_ATTRS=3Dy=0ACONFIG_HAVE_DMA_CONTIGUOUS=3Dy=0ACONFIG_GENERIC_SMP_IDLE_THRE=
AD=3Dy=0ACONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=3Dy=0ACONFIG_HAVE_REGS_AND_S=
TACK_ACCESS_API=3Dy=0ACONFIG_HAVE_CLK=3Dy=0ACONFIG_HAVE_DMA_API_DEBUG=3Dy=
=0ACONFIG_HAVE_HW_BREAKPOINT=3Dy=0ACONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy=
=0ACONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy=0ACONFIG_HAVE_PERF_EVENTS_NMI=3Dy=
=0ACONFIG_HAVE_PERF_REGS=3Dy=0ACONFIG_HAVE_PERF_USER_STACK_DUMP=3Dy=0ACONFI=
G_HAVE_ARCH_JUMP_LABEL=3Dy=0ACONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy=0ACONFIG=
_HAVE_ALIGNED_STRUCT_PAGE=3Dy=0ACONFIG_HAVE_CMPXCHG_LOCAL=3Dy=0ACONFIG_HAVE=
_CMPXCHG_DOUBLE=3Dy=0ACONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=3Dy=0ACONFI=
G_ARCH_WANT_OLD_COMPAT_IPC=3Dy=0ACONFIG_HAVE_ARCH_SECCOMP_FILTER=3Dy=0ACONF=
IG_SECCOMP_FILTER=3Dy=0ACONFIG_HAVE_CC_STACKPROTECTOR=3Dy=0ACONFIG_CC_STACK=
PROTECTOR=3Dy=0A# CONFIG_CC_STACKPROTECTOR_NONE is not set=0A# CONFIG_CC_ST=
ACKPROTECTOR_REGULAR is not set=0ACONFIG_CC_STACKPROTECTOR_STRONG=3Dy=0ACON=
FIG_HAVE_CONTEXT_TRACKING=3Dy=0ACONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=3Dy=0AC=
ONFIG_HAVE_IRQ_TIME_ACCOUNTING=3Dy=0ACONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=
=3Dy=0ACONFIG_HAVE_ARCH_HUGE_VMAP=3Dy=0ACONFIG_HAVE_ARCH_SOFT_DIRTY=3Dy=0AC=
ONFIG_MODULES_USE_ELF_RELA=3Dy=0ACONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=3Dy=0ACO=
NFIG_ARCH_HAS_ELF_RANDOMIZE=3Dy=0ACONFIG_HAVE_COPY_THREAD_TLS=3Dy=0ACONFIG_=
OLD_SIGSUSPEND3=3Dy=0ACONFIG_COMPAT_OLD_SIGACTION=3Dy=0A=0A#=0A# GCOV-based=
 kernel profiling=0A#=0A# CONFIG_GCOV_KERNEL is not set=0ACONFIG_ARCH_HAS_G=
COV_PROFILE_ALL=3Dy=0A# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set=0ACONFI=
G_SLABINFO=3Dy=0ACONFIG_RT_MUTEXES=3Dy=0ACONFIG_BASE_SMALL=3D0=0ACONFIG_MOD=
ULES=3Dy=0A# CONFIG_MODULE_FORCE_LOAD is not set=0ACONFIG_MODULE_UNLOAD=3Dy=
=0A# CONFIG_MODULE_FORCE_UNLOAD is not set=0A# CONFIG_MODVERSIONS is not se=
t=0A# CONFIG_MODULE_SRCVERSION_ALL is not set=0A# CONFIG_MODULE_SIG is not =
set=0A# CONFIG_MODULE_COMPRESS is not set=0ACONFIG_MODULES_TREE_LOOKUP=3Dy=
=0ACONFIG_BLOCK=3Dy=0ACONFIG_BLK_DEV_BSG=3Dy=0ACONFIG_BLK_DEV_BSGLIB=3Dy=0A=
CONFIG_BLK_DEV_INTEGRITY=3Dy=0ACONFIG_BLK_DEV_THROTTLING=3Dy=0A# CONFIG_BLK=
_CMDLINE_PARSER is not set=0A=0A#=0A# Partition Types=0A#=0ACONFIG_PARTITIO=
N_ADVANCED=3Dy=0A# CONFIG_ACORN_PARTITION is not set=0ACONFIG_AIX_PARTITION=
=3Dy=0ACONFIG_OSF_PARTITION=3Dy=0ACONFIG_AMIGA_PARTITION=3Dy=0A# CONFIG_ATA=
RI_PARTITION is not set=0ACONFIG_MAC_PARTITION=3Dy=0ACONFIG_MSDOS_PARTITION=
=3Dy=0ACONFIG_BSD_DISKLABEL=3Dy=0ACONFIG_MINIX_SUBPARTITION=3Dy=0ACONFIG_SO=
LARIS_X86_PARTITION=3Dy=0ACONFIG_UNIXWARE_DISKLABEL=3Dy=0ACONFIG_LDM_PARTIT=
ION=3Dy=0A# CONFIG_LDM_DEBUG is not set=0ACONFIG_SGI_PARTITION=3Dy=0A# CONF=
IG_ULTRIX_PARTITION is not set=0ACONFIG_SUN_PARTITION=3Dy=0ACONFIG_KARMA_PA=
RTITION=3Dy=0ACONFIG_EFI_PARTITION=3Dy=0A# CONFIG_SYSV68_PARTITION is not s=
et=0A# CONFIG_CMDLINE_PARTITION is not set=0ACONFIG_BLOCK_COMPAT=3Dy=0A=0A#=
=0A# IO Schedulers=0A#=0ACONFIG_IOSCHED_NOOP=3Dy=0ACONFIG_IOSCHED_DEADLINE=
=3Dy=0ACONFIG_IOSCHED_CFQ=3Dy=0ACONFIG_CFQ_GROUP_IOSCHED=3Dy=0A# CONFIG_DEF=
AULT_DEADLINE is not set=0ACONFIG_DEFAULT_CFQ=3Dy=0A# CONFIG_DEFAULT_NOOP i=
s not set=0ACONFIG_DEFAULT_IOSCHED=3D"cfq"=0ACONFIG_PREEMPT_NOTIFIERS=3Dy=
=0ACONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy=0ACONFIG_INLINE_READ_UNLOCK=3Dy=0ACONF=
IG_INLINE_READ_UNLOCK_IRQ=3Dy=0ACONFIG_INLINE_WRITE_UNLOCK=3Dy=0ACONFIG_INL=
INE_WRITE_UNLOCK_IRQ=3Dy=0ACONFIG_ARCH_SUPPORTS_ATOMIC_RMW=3Dy=0ACONFIG_MUT=
EX_SPIN_ON_OWNER=3Dy=0ACONFIG_RWSEM_SPIN_ON_OWNER=3Dy=0ACONFIG_LOCK_SPIN_ON=
_OWNER=3Dy=0ACONFIG_ARCH_USE_QUEUED_SPINLOCKS=3Dy=0ACONFIG_QUEUED_SPINLOCKS=
=3Dy=0ACONFIG_ARCH_USE_QUEUED_RWLOCKS=3Dy=0ACONFIG_QUEUED_RWLOCKS=3Dy=0ACON=
FIG_FREEZER=3Dy=0A=0A#=0A# Processor type and features=0A#=0ACONFIG_ZONE_DM=
A=3Dy=0ACONFIG_SMP=3Dy=0ACONFIG_X86_FEATURE_NAMES=3Dy=0ACONFIG_X86_X2APIC=
=3Dy=0ACONFIG_X86_MPPARSE=3Dy=0ACONFIG_X86_EXTENDED_PLATFORM=3Dy=0A# CONFIG=
_X86_NUMACHIP is not set=0A# CONFIG_X86_VSMP is not set=0ACONFIG_X86_UV=3Dy=
=0A# CONFIG_X86_GOLDFISH is not set=0ACONFIG_X86_INTEL_LPSS=3Dy=0A# CONFIG_=
X86_AMD_PLATFORM_DEVICE is not set=0ACONFIG_IOSF_MBI=3Dm=0A# CONFIG_IOSF_MB=
I_DEBUG is not set=0ACONFIG_SCHED_OMIT_FRAME_POINTER=3Dy=0ACONFIG_HYPERVISO=
R_GUEST=3Dy=0ACONFIG_PARAVIRT=3Dy=0A# CONFIG_PARAVIRT_DEBUG is not set=0A# =
CONFIG_PARAVIRT_SPINLOCKS is not set=0ACONFIG_XEN=3Dy=0ACONFIG_XEN_DOM0=3Dy=
=0ACONFIG_XEN_PVHVM=3Dy=0ACONFIG_XEN_512GB=3Dy=0ACONFIG_XEN_SAVE_RESTORE=3D=
y=0ACONFIG_XEN_DEBUG_FS=3Dy=0A# CONFIG_XEN_PVH is not set=0ACONFIG_KVM_GUES=
T=3Dy=0A# CONFIG_KVM_DEBUG_FS is not set=0ACONFIG_PARAVIRT_TIME_ACCOUNTING=
=3Dy=0ACONFIG_PARAVIRT_CLOCK=3Dy=0ACONFIG_NO_BOOTMEM=3Dy=0A# CONFIG_MK8 is =
not set=0A# CONFIG_MPSC is not set=0A# CONFIG_MCORE2 is not set=0A# CONFIG_=
MATOM is not set=0ACONFIG_GENERIC_CPU=3Dy=0ACONFIG_X86_INTERNODE_CACHE_SHIF=
T=3D6=0ACONFIG_X86_L1_CACHE_SHIFT=3D6=0ACONFIG_X86_TSC=3Dy=0ACONFIG_X86_CMP=
XCHG64=3Dy=0ACONFIG_X86_CMOV=3Dy=0ACONFIG_X86_MINIMUM_CPU_FAMILY=3D64=0ACON=
FIG_X86_DEBUGCTLMSR=3Dy=0ACONFIG_CPU_SUP_INTEL=3Dy=0ACONFIG_CPU_SUP_AMD=3Dy=
=0ACONFIG_CPU_SUP_CENTAUR=3Dy=0ACONFIG_HPET_TIMER=3Dy=0ACONFIG_HPET_EMULATE=
_RTC=3Dy=0ACONFIG_DMI=3Dy=0A# CONFIG_GART_IOMMU is not set=0A# CONFIG_CALGA=
RY_IOMMU is not set=0ACONFIG_SWIOTLB=3Dy=0ACONFIG_IOMMU_HELPER=3Dy=0A# CONF=
IG_MAXSMP is not set=0ACONFIG_NR_CPUS=3D64=0ACONFIG_SCHED_SMT=3Dy=0ACONFIG_=
SCHED_MC=3Dy=0A# CONFIG_PREEMPT_NONE is not set=0ACONFIG_PREEMPT_VOLUNTARY=
=3Dy=0A# CONFIG_PREEMPT is not set=0ACONFIG_X86_LOCAL_APIC=3Dy=0ACONFIG_X86=
_IO_APIC=3Dy=0ACONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=3Dy=0A# CONFIG_X86_M=
CE is not set=0A# CONFIG_VM86 is not set=0ACONFIG_X86_16BIT=3Dy=0ACONFIG_X8=
6_ESPFIX64=3Dy=0ACONFIG_X86_VSYSCALL_EMULATION=3Dy=0ACONFIG_I8K=3Dm=0ACONFI=
G_MICROCODE=3Dy=0ACONFIG_MICROCODE_INTEL=3Dy=0ACONFIG_MICROCODE_AMD=3Dy=0AC=
ONFIG_MICROCODE_OLD_INTERFACE=3Dy=0ACONFIG_X86_MSR=3Dy=0ACONFIG_X86_CPUID=
=3Dy=0ACONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy=0ACONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy=
=0ACONFIG_X86_DIRECT_GBPAGES=3Dy=0ACONFIG_NUMA=3Dy=0ACONFIG_AMD_NUMA=3Dy=0A=
CONFIG_X86_64_ACPI_NUMA=3Dy=0ACONFIG_NODES_SPAN_OTHER_NODES=3Dy=0A# CONFIG_=
NUMA_EMU is not set=0ACONFIG_NODES_SHIFT=3D9=0ACONFIG_ARCH_SPARSEMEM_ENABLE=
=3Dy=0ACONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy=0ACONFIG_ARCH_SELECT_MEMORY_MODEL=
=3Dy=0A# CONFIG_ARCH_MEMORY_PROBE is not set=0ACONFIG_ARCH_PROC_KCORE_TEXT=
=3Dy=0ACONFIG_ILLEGAL_POINTER_VALUE=3D0xdead000000000000=0ACONFIG_SELECT_ME=
MORY_MODEL=3Dy=0ACONFIG_SPARSEMEM_MANUAL=3Dy=0ACONFIG_SPARSEMEM=3Dy=0ACONFI=
G_NEED_MULTIPLE_NODES=3Dy=0ACONFIG_HAVE_MEMORY_PRESENT=3Dy=0ACONFIG_SPARSEM=
EM_EXTREME=3Dy=0ACONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy=0ACONFIG_SPARSEMEM_ALL=
OC_MEM_MAP_TOGETHER=3Dy=0ACONFIG_SPARSEMEM_VMEMMAP=3Dy=0ACONFIG_HAVE_MEMBLO=
CK=3Dy=0ACONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy=0ACONFIG_ARCH_DISCARD_MEMBLOCK=
=3Dy=0A# CONFIG_MOVABLE_NODE is not set=0A# CONFIG_HAVE_BOOTMEM_INFO_NODE i=
s not set=0ACONFIG_MEMORY_HOTPLUG=3Dy=0ACONFIG_MEMORY_HOTPLUG_SPARSE=3Dy=0A=
# CONFIG_MEMORY_HOTREMOVE is not set=0ACONFIG_SPLIT_PTLOCK_CPUS=3D4=0ACONFI=
G_ARCH_ENABLE_SPLIT_PMD_PTLOCK=3Dy=0ACONFIG_MEMORY_BALLOON=3Dy=0ACONFIG_BAL=
LOON_COMPACTION=3Dy=0ACONFIG_COMPACTION=3Dy=0ACONFIG_MIGRATION=3Dy=0ACONFIG=
_ARCH_ENABLE_HUGEPAGE_MIGRATION=3Dy=0ACONFIG_PHYS_ADDR_T_64BIT=3Dy=0ACONFIG=
_ZONE_DMA_FLAG=3D1=0ACONFIG_BOUNCE=3Dy=0ACONFIG_VIRT_TO_BUS=3Dy=0ACONFIG_MM=
U_NOTIFIER=3Dy=0ACONFIG_KSM=3Dy=0ACONFIG_DEFAULT_MMAP_MIN_ADDR=3D65536=0ACO=
NFIG_TRANSPARENT_HUGEPAGE=3Dy=0A# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not=
 set=0ACONFIG_TRANSPARENT_HUGEPAGE_MADVISE=3Dy=0ACONFIG_CLEANCACHE=3Dy=0ACO=
NFIG_FRONTSWAP=3Dy=0A# CONFIG_CMA is not set=0ACONFIG_ZSWAP=3Dy=0ACONFIG_ZP=
OOL=3Dy=0ACONFIG_ZBUD=3Dy=0ACONFIG_ZSMALLOC=3Dy=0A# CONFIG_PGTABLE_MAPPING =
is not set=0A# CONFIG_ZSMALLOC_STAT is not set=0ACONFIG_GENERIC_EARLY_IOREM=
AP=3Dy=0ACONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=3Dy=0A# CONFIG_DEFE=
RRED_STRUCT_PAGE_INIT is not set=0A# CONFIG_IDLE_PAGE_TRACKING is not set=
=0A# CONFIG_X86_PMEM_LEGACY is not set=0ACONFIG_X86_CHECK_BIOS_CORRUPTION=
=3Dy=0A# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set=0ACONFIG_X=
86_RESERVE_LOW=3D64=0ACONFIG_MTRR=3Dy=0ACONFIG_MTRR_SANITIZER=3Dy=0ACONFIG_=
MTRR_SANITIZER_ENABLE_DEFAULT=3D0=0ACONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFA=
ULT=3D1=0ACONFIG_X86_PAT=3Dy=0ACONFIG_ARCH_USES_PG_UNCACHED=3Dy=0ACONFIG_AR=
CH_RANDOM=3Dy=0ACONFIG_X86_SMAP=3Dy=0A# CONFIG_X86_INTEL_MPX is not set=0AC=
ONFIG_EFI=3Dy=0ACONFIG_EFI_STUB=3Dy=0A# CONFIG_EFI_MIXED is not set=0ACONFI=
G_SECCOMP=3Dy=0A# CONFIG_HZ_100 is not set=0A# CONFIG_HZ_250 is not set=0A#=
 CONFIG_HZ_300 is not set=0ACONFIG_HZ_1000=3Dy=0ACONFIG_HZ=3D1000=0ACONFIG_=
SCHED_HRTICK=3Dy=0ACONFIG_KEXEC=3Dy=0ACONFIG_KEXEC_FILE=3Dy=0ACONFIG_KEXEC_=
VERIFY_SIG=3Dy=0ACONFIG_CRASH_DUMP=3Dy=0ACONFIG_KEXEC_JUMP=3Dy=0ACONFIG_PHY=
SICAL_START=3D0x1000000=0ACONFIG_RELOCATABLE=3Dy=0A# CONFIG_RANDOMIZE_BASE =
is not set=0ACONFIG_PHYSICAL_ALIGN=3D0x1000000=0ACONFIG_HOTPLUG_CPU=3Dy=0A#=
 CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set=0A# CONFIG_DEBUG_HOTPLUG_CPU0 is =
not set=0A# CONFIG_COMPAT_VDSO is not set=0A# CONFIG_LEGACY_VSYSCALL_NATIVE=
 is not set=0ACONFIG_LEGACY_VSYSCALL_EMULATE=3Dy=0A# CONFIG_LEGACY_VSYSCALL=
_NONE is not set=0A# CONFIG_CMDLINE_BOOL is not set=0ACONFIG_MODIFY_LDT_SYS=
CALL=3Dy=0ACONFIG_HAVE_LIVEPATCH=3Dy=0A# CONFIG_LIVEPATCH is not set=0ACONF=
IG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy=0ACONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=3Dy=
=0ACONFIG_USE_PERCPU_NUMA_NODE_ID=3Dy=0A=0A#=0A# Power management and ACPI =
options=0A#=0ACONFIG_ARCH_HIBERNATION_HEADER=3Dy=0ACONFIG_SUSPEND=3Dy=0ACON=
FIG_SUSPEND_FREEZER=3Dy=0ACONFIG_HIBERNATE_CALLBACKS=3Dy=0ACONFIG_HIBERNATI=
ON=3Dy=0ACONFIG_PM_STD_PARTITION=3D""=0ACONFIG_PM_SLEEP=3Dy=0ACONFIG_PM_SLE=
EP_SMP=3Dy=0A# CONFIG_PM_AUTOSLEEP is not set=0A# CONFIG_PM_WAKELOCKS is no=
t set=0ACONFIG_PM=3Dy=0ACONFIG_PM_DEBUG=3Dy=0ACONFIG_PM_ADVANCED_DEBUG=3Dy=
=0A# CONFIG_PM_TEST_SUSPEND is not set=0ACONFIG_PM_SLEEP_DEBUG=3Dy=0A# CONF=
IG_DPM_WATCHDOG is not set=0ACONFIG_PM_TRACE=3Dy=0ACONFIG_PM_TRACE_RTC=3Dy=
=0ACONFIG_PM_CLK=3Dy=0A# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set=0ACON=
FIG_ACPI=3Dy=0ACONFIG_ACPI_LEGACY_TABLES_LOOKUP=3Dy=0ACONFIG_ARCH_MIGHT_HAV=
E_ACPI_PDC=3Dy=0ACONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=3Dy=0A# CONFIG_ACP=
I_DEBUGGER is not set=0ACONFIG_ACPI_SLEEP=3Dy=0A# CONFIG_ACPI_PROCFS_POWER =
is not set=0ACONFIG_ACPI_REV_OVERRIDE_POSSIBLE=3Dy=0ACONFIG_ACPI_EC_DEBUGFS=
=3Dm=0ACONFIG_ACPI_AC=3Dy=0ACONFIG_ACPI_BATTERY=3Dy=0ACONFIG_ACPI_BUTTON=3D=
y=0ACONFIG_ACPI_VIDEO=3Dm=0ACONFIG_ACPI_FAN=3Dy=0ACONFIG_ACPI_DOCK=3Dy=0ACO=
NFIG_ACPI_CPU_FREQ_PSS=3Dy=0ACONFIG_ACPI_PROCESSOR_IDLE=3Dy=0ACONFIG_ACPI_P=
ROCESSOR=3Dy=0ACONFIG_ACPI_IPMI=3Dm=0ACONFIG_ACPI_HOTPLUG_CPU=3Dy=0ACONFIG_=
ACPI_PROCESSOR_AGGREGATOR=3Dm=0ACONFIG_ACPI_THERMAL=3Dy=0ACONFIG_ACPI_NUMA=
=3Dy=0A# CONFIG_ACPI_CUSTOM_DSDT is not set=0ACONFIG_ACPI_INITRD_TABLE_OVER=
RIDE=3Dy=0A# CONFIG_ACPI_DEBUG is not set=0ACONFIG_ACPI_PCI_SLOT=3Dy=0ACONF=
IG_X86_PM_TIMER=3Dy=0ACONFIG_ACPI_CONTAINER=3Dy=0ACONFIG_ACPI_HOTPLUG_MEMOR=
Y=3Dy=0ACONFIG_ACPI_HOTPLUG_IOAPIC=3Dy=0ACONFIG_ACPI_SBS=3Dm=0ACONFIG_ACPI_=
HED=3Dy=0ACONFIG_ACPI_CUSTOM_METHOD=3Dm=0ACONFIG_ACPI_BGRT=3Dy=0A# CONFIG_A=
CPI_REDUCED_HARDWARE_ONLY is not set=0A# CONFIG_ACPI_NFIT is not set=0ACONF=
IG_HAVE_ACPI_APEI=3Dy=0ACONFIG_HAVE_ACPI_APEI_NMI=3Dy=0ACONFIG_ACPI_APEI=3D=
y=0ACONFIG_ACPI_APEI_GHES=3Dy=0ACONFIG_ACPI_APEI_PCIEAER=3Dy=0A# CONFIG_ACP=
I_APEI_EINJ is not set=0A# CONFIG_ACPI_APEI_ERST_DEBUG is not set=0A# CONFI=
G_PMIC_OPREGION is not set=0ACONFIG_SFI=3Dy=0A=0A#=0A# CPU Frequency scalin=
g=0A#=0ACONFIG_CPU_FREQ=3Dy=0ACONFIG_CPU_FREQ_GOV_COMMON=3Dy=0ACONFIG_CPU_F=
REQ_STAT=3Dm=0ACONFIG_CPU_FREQ_STAT_DETAILS=3Dy=0A# CONFIG_CPU_FREQ_DEFAULT=
_GOV_PERFORMANCE is not set=0A# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is no=
t set=0A# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set=0ACONFIG_CPU_FRE=
Q_DEFAULT_GOV_ONDEMAND=3Dy=0A# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is =
not set=0ACONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy=0ACONFIG_CPU_FREQ_GOV_POWERSA=
VE=3Dy=0ACONFIG_CPU_FREQ_GOV_USERSPACE=3Dy=0ACONFIG_CPU_FREQ_GOV_ONDEMAND=
=3Dy=0ACONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy=0A=0A#=0A# CPU frequency scalin=
g drivers=0A#=0ACONFIG_X86_INTEL_PSTATE=3Dy=0ACONFIG_X86_PCC_CPUFREQ=3Dm=0A=
CONFIG_X86_ACPI_CPUFREQ=3Dm=0ACONFIG_X86_ACPI_CPUFREQ_CPB=3Dy=0ACONFIG_X86_=
POWERNOW_K8=3Dm=0ACONFIG_X86_AMD_FREQ_SENSITIVITY=3Dm=0A# CONFIG_X86_SPEEDS=
TEP_CENTRINO is not set=0ACONFIG_X86_P4_CLOCKMOD=3Dm=0A=0A#=0A# shared opti=
ons=0A#=0ACONFIG_X86_SPEEDSTEP_LIB=3Dm=0A=0A#=0A# CPU Idle=0A#=0ACONFIG_CPU=
_IDLE=3Dy=0A# CONFIG_CPU_IDLE_GOV_LADDER is not set=0ACONFIG_CPU_IDLE_GOV_M=
ENU=3Dy=0A# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set=0ACONFIG_INTEL_ID=
LE=3Dy=0A=0A#=0A# Memory power savings=0A#=0ACONFIG_I7300_IDLE_IOAT_CHANNEL=
=3Dy=0ACONFIG_I7300_IDLE=3Dm=0A=0A#=0A# Bus options (PCI etc.)=0A#=0ACONFIG=
_PCI=3Dy=0ACONFIG_PCI_DIRECT=3Dy=0ACONFIG_PCI_MMCONFIG=3Dy=0ACONFIG_PCI_XEN=
=3Dy=0ACONFIG_PCI_DOMAINS=3Dy=0ACONFIG_PCIEPORTBUS=3Dy=0ACONFIG_HOTPLUG_PCI=
_PCIE=3Dy=0ACONFIG_PCIEAER=3Dy=0ACONFIG_PCIE_ECRC=3Dy=0ACONFIG_PCIEAER_INJE=
CT=3Dm=0ACONFIG_PCIEASPM=3Dy=0A# CONFIG_PCIEASPM_DEBUG is not set=0ACONFIG_=
PCIEASPM_DEFAULT=3Dy=0A# CONFIG_PCIEASPM_POWERSAVE is not set=0A# CONFIG_PC=
IEASPM_PERFORMANCE is not set=0ACONFIG_PCIE_PME=3Dy=0ACONFIG_PCI_BUS_ADDR_T=
_64BIT=3Dy=0ACONFIG_PCI_MSI=3Dy=0ACONFIG_PCI_MSI_IRQ_DOMAIN=3Dy=0A# CONFIG_=
PCI_DEBUG is not set=0A# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set=0ACONFIG=
_PCI_STUB=3Dy=0ACONFIG_XEN_PCIDEV_FRONTEND=3Dm=0ACONFIG_HT_IRQ=3Dy=0ACONFIG=
_PCI_ATS=3Dy=0ACONFIG_PCI_IOV=3Dy=0ACONFIG_PCI_PRI=3Dy=0ACONFIG_PCI_PASID=
=3Dy=0ACONFIG_PCI_LABEL=3Dy=0A=0A#=0A# PCI host controller drivers=0A#=0ACO=
NFIG_ISA_DMA_API=3Dy=0ACONFIG_AMD_NB=3Dy=0ACONFIG_PCCARD=3Dy=0ACONFIG_PCMCI=
A=3Dy=0ACONFIG_PCMCIA_LOAD_CIS=3Dy=0ACONFIG_CARDBUS=3Dy=0A=0A#=0A# PC-card =
bridges=0A#=0ACONFIG_YENTA=3Dm=0ACONFIG_YENTA_O2=3Dy=0ACONFIG_YENTA_RICOH=
=3Dy=0ACONFIG_YENTA_TI=3Dy=0ACONFIG_YENTA_ENE_TUNE=3Dy=0ACONFIG_YENTA_TOSHI=
BA=3Dy=0ACONFIG_PD6729=3Dm=0ACONFIG_I82092=3Dm=0ACONFIG_PCCARD_NONSTATIC=3D=
y=0ACONFIG_HOTPLUG_PCI=3Dy=0ACONFIG_HOTPLUG_PCI_ACPI=3Dy=0ACONFIG_HOTPLUG_P=
CI_ACPI_IBM=3Dm=0A# CONFIG_HOTPLUG_PCI_CPCI is not set=0ACONFIG_HOTPLUG_PCI=
_SHPC=3Dm=0A# CONFIG_RAPIDIO is not set=0A# CONFIG_X86_SYSFB is not set=0A=
=0A#=0A# Executable file formats / Emulations=0A#=0ACONFIG_BINFMT_ELF=3Dy=
=0ACONFIG_COMPAT_BINFMT_ELF=3Dy=0ACONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=3Dy=
=0ACONFIG_BINFMT_SCRIPT=3Dy=0A# CONFIG_HAVE_AOUT is not set=0ACONFIG_BINFMT=
_MISC=3Dm=0ACONFIG_COREDUMP=3Dy=0ACONFIG_IA32_EMULATION=3Dy=0A# CONFIG_IA32=
_AOUT is not set=0A# CONFIG_X86_X32 is not set=0ACONFIG_COMPAT=3Dy=0ACONFIG=
_COMPAT_FOR_U64_ALIGNMENT=3Dy=0ACONFIG_SYSVIPC_COMPAT=3Dy=0ACONFIG_KEYS_COM=
PAT=3Dy=0ACONFIG_X86_DEV_DMA_OPS=3Dy=0ACONFIG_PMC_ATOM=3Dy=0ACONFIG_NET=3Dy=
=0ACONFIG_NET_INGRESS=3Dy=0A=0A#=0A# Networking options=0A#=0ACONFIG_PACKET=
=3Dy=0ACONFIG_PACKET_DIAG=3Dm=0ACONFIG_UNIX=3Dy=0ACONFIG_UNIX_DIAG=3Dm=0ACO=
NFIG_XFRM=3Dy=0ACONFIG_XFRM_ALGO=3Dy=0ACONFIG_XFRM_USER=3Dy=0ACONFIG_XFRM_S=
UB_POLICY=3Dy=0ACONFIG_XFRM_MIGRATE=3Dy=0ACONFIG_XFRM_STATISTICS=3Dy=0ACONF=
IG_XFRM_IPCOMP=3Dm=0ACONFIG_NET_KEY=3Dm=0ACONFIG_NET_KEY_MIGRATE=3Dy=0ACONF=
IG_INET=3Dy=0ACONFIG_IP_MULTICAST=3Dy=0ACONFIG_IP_ADVANCED_ROUTER=3Dy=0ACON=
FIG_IP_FIB_TRIE_STATS=3Dy=0ACONFIG_IP_MULTIPLE_TABLES=3Dy=0ACONFIG_IP_ROUTE=
_MULTIPATH=3Dy=0ACONFIG_IP_ROUTE_VERBOSE=3Dy=0ACONFIG_IP_ROUTE_CLASSID=3Dy=
=0A# CONFIG_IP_PNP is not set=0ACONFIG_NET_IPIP=3Dm=0ACONFIG_NET_IPGRE_DEMU=
X=3Dm=0ACONFIG_NET_IP_TUNNEL=3Dm=0ACONFIG_NET_IPGRE=3Dm=0ACONFIG_NET_IPGRE_=
BROADCAST=3Dy=0ACONFIG_IP_MROUTE=3Dy=0ACONFIG_IP_MROUTE_MULTIPLE_TABLES=3Dy=
=0ACONFIG_IP_PIMSM_V1=3Dy=0ACONFIG_IP_PIMSM_V2=3Dy=0ACONFIG_SYN_COOKIES=3Dy=
=0ACONFIG_NET_IPVTI=3Dm=0ACONFIG_NET_UDP_TUNNEL=3Dm=0ACONFIG_NET_FOU=3Dm=0A=
# CONFIG_NET_FOU_IP_TUNNELS is not set=0ACONFIG_INET_AH=3Dm=0ACONFIG_INET_E=
SP=3Dm=0ACONFIG_INET_IPCOMP=3Dm=0ACONFIG_INET_XFRM_TUNNEL=3Dm=0ACONFIG_INET=
_TUNNEL=3Dm=0ACONFIG_INET_XFRM_MODE_TRANSPORT=3Dm=0ACONFIG_INET_XFRM_MODE_T=
UNNEL=3Dm=0ACONFIG_INET_XFRM_MODE_BEET=3Dm=0ACONFIG_INET_LRO=3Dy=0ACONFIG_I=
NET_DIAG=3Dm=0ACONFIG_INET_TCP_DIAG=3Dm=0ACONFIG_INET_UDP_DIAG=3Dm=0ACONFIG=
_TCP_CONG_ADVANCED=3Dy=0ACONFIG_TCP_CONG_BIC=3Dm=0ACONFIG_TCP_CONG_CUBIC=3D=
y=0ACONFIG_TCP_CONG_WESTWOOD=3Dm=0ACONFIG_TCP_CONG_HTCP=3Dm=0ACONFIG_TCP_CO=
NG_HSTCP=3Dm=0ACONFIG_TCP_CONG_HYBLA=3Dm=0ACONFIG_TCP_CONG_VEGAS=3Dm=0ACONF=
IG_TCP_CONG_SCALABLE=3Dm=0ACONFIG_TCP_CONG_LP=3Dm=0ACONFIG_TCP_CONG_VENO=3D=
m=0ACONFIG_TCP_CONG_YEAH=3Dm=0ACONFIG_TCP_CONG_ILLINOIS=3Dm=0ACONFIG_TCP_CO=
NG_DCTCP=3Dm=0A# CONFIG_TCP_CONG_CDG is not set=0ACONFIG_DEFAULT_CUBIC=3Dy=
=0A# CONFIG_DEFAULT_RENO is not set=0ACONFIG_DEFAULT_TCP_CONG=3D"cubic"=0AC=
ONFIG_TCP_MD5SIG=3Dy=0ACONFIG_IPV6=3Dy=0ACONFIG_IPV6_ROUTER_PREF=3Dy=0ACONF=
IG_IPV6_ROUTE_INFO=3Dy=0ACONFIG_IPV6_OPTIMISTIC_DAD=3Dy=0ACONFIG_INET6_AH=
=3Dm=0ACONFIG_INET6_ESP=3Dm=0ACONFIG_INET6_IPCOMP=3Dm=0ACONFIG_IPV6_MIP6=3D=
y=0A# CONFIG_IPV6_ILA is not set=0ACONFIG_INET6_XFRM_TUNNEL=3Dm=0ACONFIG_IN=
ET6_TUNNEL=3Dm=0ACONFIG_INET6_XFRM_MODE_TRANSPORT=3Dm=0ACONFIG_INET6_XFRM_M=
ODE_TUNNEL=3Dm=0ACONFIG_INET6_XFRM_MODE_BEET=3Dm=0ACONFIG_INET6_XFRM_MODE_R=
OUTEOPTIMIZATION=3Dm=0ACONFIG_IPV6_VTI=3Dm=0ACONFIG_IPV6_SIT=3Dm=0ACONFIG_I=
PV6_SIT_6RD=3Dy=0ACONFIG_IPV6_NDISC_NODETYPE=3Dy=0ACONFIG_IPV6_TUNNEL=3Dm=
=0A# CONFIG_IPV6_GRE is not set=0ACONFIG_IPV6_MULTIPLE_TABLES=3Dy=0ACONFIG_=
IPV6_SUBTREES=3Dy=0ACONFIG_IPV6_MROUTE=3Dy=0ACONFIG_IPV6_MROUTE_MULTIPLE_TA=
BLES=3Dy=0ACONFIG_IPV6_PIMSM_V2=3Dy=0ACONFIG_NETLABEL=3Dy=0ACONFIG_NETWORK_=
SECMARK=3Dy=0ACONFIG_NET_PTP_CLASSIFY=3Dy=0ACONFIG_NETWORK_PHY_TIMESTAMPING=
=3Dy=0A# CONFIG_NETFILTER is not set=0A# CONFIG_IP_DCCP is not set=0ACONFIG=
_IP_SCTP=3Dm=0ACONFIG_NET_SCTPPROBE=3Dm=0A# CONFIG_SCTP_DBG_OBJCNT is not s=
et=0A# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set=0ACONFIG_SCTP_DEFAULT=
_COOKIE_HMAC_SHA1=3Dy=0A# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set=
=0ACONFIG_SCTP_COOKIE_HMAC_MD5=3Dy=0ACONFIG_SCTP_COOKIE_HMAC_SHA1=3Dy=0A# C=
ONFIG_RDS is not set=0A# CONFIG_TIPC is not set=0A# CONFIG_ATM is not set=
=0A# CONFIG_L2TP is not set=0A# CONFIG_BRIDGE is not set=0ACONFIG_HAVE_NET_=
DSA=3Dy=0A# CONFIG_VLAN_8021Q is not set=0A# CONFIG_DECNET is not set=0A# C=
ONFIG_LLC2 is not set=0A# CONFIG_IPX is not set=0A# CONFIG_ATALK is not set=
=0A# CONFIG_X25 is not set=0A# CONFIG_LAPB is not set=0A# CONFIG_PHONET is =
not set=0A# CONFIG_6LOWPAN is not set=0A# CONFIG_IEEE802154 is not set=0ACO=
NFIG_NET_SCHED=3Dy=0A=0A#=0A# Queueing/Scheduling=0A#=0ACONFIG_NET_SCH_CBQ=
=3Dm=0ACONFIG_NET_SCH_HTB=3Dm=0ACONFIG_NET_SCH_HFSC=3Dm=0ACONFIG_NET_SCH_PR=
IO=3Dm=0ACONFIG_NET_SCH_MULTIQ=3Dm=0ACONFIG_NET_SCH_RED=3Dm=0ACONFIG_NET_SC=
H_SFB=3Dm=0ACONFIG_NET_SCH_SFQ=3Dm=0ACONFIG_NET_SCH_TEQL=3Dm=0ACONFIG_NET_S=
CH_TBF=3Dm=0ACONFIG_NET_SCH_GRED=3Dm=0ACONFIG_NET_SCH_DSMARK=3Dm=0ACONFIG_N=
ET_SCH_NETEM=3Dm=0ACONFIG_NET_SCH_DRR=3Dm=0ACONFIG_NET_SCH_MQPRIO=3Dm=0ACON=
FIG_NET_SCH_CHOKE=3Dm=0ACONFIG_NET_SCH_QFQ=3Dm=0ACONFIG_NET_SCH_CODEL=3Dm=
=0ACONFIG_NET_SCH_FQ_CODEL=3Dy=0ACONFIG_NET_SCH_FQ=3Dm=0ACONFIG_NET_SCH_HHF=
=3Dm=0ACONFIG_NET_SCH_PIE=3Dm=0ACONFIG_NET_SCH_INGRESS=3Dm=0ACONFIG_NET_SCH=
_PLUG=3Dm=0A=0A#=0A# Classification=0A#=0ACONFIG_NET_CLS=3Dy=0ACONFIG_NET_C=
LS_BASIC=3Dm=0ACONFIG_NET_CLS_TCINDEX=3Dm=0ACONFIG_NET_CLS_ROUTE4=3Dm=0ACON=
FIG_NET_CLS_FW=3Dm=0ACONFIG_NET_CLS_U32=3Dm=0ACONFIG_CLS_U32_PERF=3Dy=0ACON=
FIG_CLS_U32_MARK=3Dy=0ACONFIG_NET_CLS_RSVP=3Dm=0ACONFIG_NET_CLS_RSVP6=3Dm=
=0ACONFIG_NET_CLS_FLOW=3Dm=0ACONFIG_NET_CLS_CGROUP=3Dy=0ACONFIG_NET_CLS_BPF=
=3Dm=0A# CONFIG_NET_CLS_FLOWER is not set=0ACONFIG_NET_EMATCH=3Dy=0ACONFIG_=
NET_EMATCH_STACK=3D32=0ACONFIG_NET_EMATCH_CMP=3Dm=0ACONFIG_NET_EMATCH_NBYTE=
=3Dm=0ACONFIG_NET_EMATCH_U32=3Dm=0ACONFIG_NET_EMATCH_META=3Dm=0ACONFIG_NET_=
EMATCH_TEXT=3Dm=0ACONFIG_NET_CLS_ACT=3Dy=0ACONFIG_NET_ACT_POLICE=3Dm=0ACONF=
IG_NET_ACT_GACT=3Dm=0ACONFIG_GACT_PROB=3Dy=0ACONFIG_NET_ACT_MIRRED=3Dm=0ACO=
NFIG_NET_ACT_NAT=3Dm=0ACONFIG_NET_ACT_PEDIT=3Dm=0ACONFIG_NET_ACT_SIMP=3Dm=
=0ACONFIG_NET_ACT_SKBEDIT=3Dm=0ACONFIG_NET_ACT_CSUM=3Dm=0A# CONFIG_NET_ACT_=
VLAN is not set=0A# CONFIG_NET_ACT_BPF is not set=0ACONFIG_NET_CLS_IND=3Dy=
=0ACONFIG_NET_SCH_FIFO=3Dy=0ACONFIG_DCB=3Dy=0ACONFIG_DNS_RESOLVER=3Dm=0ACON=
FIG_BATMAN_ADV=3Dm=0ACONFIG_BATMAN_ADV_BLA=3Dy=0ACONFIG_BATMAN_ADV_DAT=3Dy=
=0ACONFIG_BATMAN_ADV_NC=3Dy=0ACONFIG_BATMAN_ADV_MCAST=3Dy=0A# CONFIG_BATMAN=
_ADV_DEBUG is not set=0ACONFIG_OPENVSWITCH=3Dm=0ACONFIG_OPENVSWITCH_GRE=3Dm=
=0ACONFIG_OPENVSWITCH_GENEVE=3Dm=0ACONFIG_VSOCKETS=3Dm=0ACONFIG_VMWARE_VMCI=
_VSOCKETS=3Dm=0ACONFIG_NETLINK_MMAP=3Dy=0ACONFIG_NETLINK_DIAG=3Dm=0ACONFIG_=
MPLS=3Dy=0ACONFIG_NET_MPLS_GSO=3Dm=0A# CONFIG_MPLS_ROUTING is not set=0A# C=
ONFIG_HSR is not set=0A# CONFIG_NET_SWITCHDEV is not set=0A# CONFIG_NET_L3_=
MASTER_DEV is not set=0ACONFIG_RPS=3Dy=0ACONFIG_RFS_ACCEL=3Dy=0ACONFIG_XPS=
=3Dy=0ACONFIG_CGROUP_NET_PRIO=3Dy=0ACONFIG_CGROUP_NET_CLASSID=3Dy=0ACONFIG_=
NET_RX_BUSY_POLL=3Dy=0ACONFIG_BQL=3Dy=0ACONFIG_BPF_JIT=3Dy=0ACONFIG_NET_FLO=
W_LIMIT=3Dy=0A=0A#=0A# Network testing=0A#=0ACONFIG_NET_PKTGEN=3Dm=0A# CONF=
IG_NET_TCPPROBE is not set=0ACONFIG_NET_DROP_MONITOR=3Dy=0A# CONFIG_HAMRADI=
O is not set=0A# CONFIG_CAN is not set=0A# CONFIG_IRDA is not set=0A# CONFI=
G_BT is not set=0A# CONFIG_AF_RXRPC is not set=0ACONFIG_FIB_RULES=3Dy=0ACON=
FIG_WIRELESS=3Dy=0ACONFIG_CFG80211=3Dm=0A# CONFIG_NL80211_TESTMODE is not s=
et=0A# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set=0A# CONFIG_CFG80211_RE=
G_DEBUG is not set=0ACONFIG_CFG80211_DEFAULT_PS=3Dy=0ACONFIG_CFG80211_DEBUG=
FS=3Dy=0A# CONFIG_CFG80211_INTERNAL_REGDB is not set=0ACONFIG_CFG80211_CRDA=
_SUPPORT=3Dy=0A# CONFIG_CFG80211_WEXT is not set=0A# CONFIG_LIB80211 is not=
 set=0ACONFIG_MAC80211=3Dm=0ACONFIG_MAC80211_HAS_RC=3Dy=0ACONFIG_MAC80211_R=
C_MINSTREL=3Dy=0ACONFIG_MAC80211_RC_MINSTREL_HT=3Dy=0A# CONFIG_MAC80211_RC_=
MINSTREL_VHT is not set=0ACONFIG_MAC80211_RC_DEFAULT_MINSTREL=3Dy=0ACONFIG_=
MAC80211_RC_DEFAULT=3D"minstrel_ht"=0ACONFIG_MAC80211_MESH=3Dy=0ACONFIG_MAC=
80211_LEDS=3Dy=0ACONFIG_MAC80211_DEBUGFS=3Dy=0A# CONFIG_MAC80211_MESSAGE_TR=
ACING is not set=0A# CONFIG_MAC80211_DEBUG_MENU is not set=0ACONFIG_MAC8021=
1_STA_HASH_MAX_SIZE=3D0=0A# CONFIG_WIMAX is not set=0A# CONFIG_RFKILL is no=
t set=0A# CONFIG_NET_9P is not set=0A# CONFIG_CAIF is not set=0ACONFIG_CEPH=
_LIB=3Dm=0A# CONFIG_CEPH_LIB_PRETTYDEBUG is not set=0A# CONFIG_CEPH_LIB_USE=
_DNS_RESOLVER is not set=0A# CONFIG_NFC is not set=0A# CONFIG_LWTUNNEL is n=
ot set=0ACONFIG_HAVE_BPF_JIT=3Dy=0A=0A#=0A# Device Drivers=0A#=0A=0A#=0A# G=
eneric Driver Options=0A#=0A# CONFIG_UEVENT_HELPER is not set=0ACONFIG_DEVT=
MPFS=3Dy=0ACONFIG_DEVTMPFS_MOUNT=3Dy=0ACONFIG_STANDALONE=3Dy=0ACONFIG_PREVE=
NT_FIRMWARE_BUILD=3Dy=0ACONFIG_FW_LOADER=3Dy=0A# CONFIG_FIRMWARE_IN_KERNEL =
is not set=0ACONFIG_EXTRA_FIRMWARE=3D""=0A# CONFIG_FW_LOADER_USER_HELPER_FA=
LLBACK is not set=0ACONFIG_ALLOW_DEV_COREDUMP=3Dy=0A# CONFIG_DEBUG_DRIVER i=
s not set=0ACONFIG_DEBUG_DEVRES=3Dy=0ACONFIG_SYS_HYPERVISOR=3Dy=0A# CONFIG_=
GENERIC_CPU_DEVICES is not set=0ACONFIG_GENERIC_CPU_AUTOPROBE=3Dy=0ACONFIG_=
REGMAP=3Dy=0ACONFIG_REGMAP_I2C=3Dm=0ACONFIG_DMA_SHARED_BUFFER=3Dy=0A# CONFI=
G_FENCE_TRACE is not set=0A=0A#=0A# Bus devices=0A#=0ACONFIG_CONNECTOR=3Dy=
=0ACONFIG_PROC_EVENTS=3Dy=0A# CONFIG_MTD is not set=0A# CONFIG_OF is not se=
t=0ACONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=3Dy=0A# CONFIG_PARPORT is not set=0AC=
ONFIG_PNP=3Dy=0A# CONFIG_PNP_DEBUG_MESSAGES is not set=0A=0A#=0A# Protocols=
=0A#=0ACONFIG_PNPACPI=3Dy=0ACONFIG_BLK_DEV=3Dy=0A# CONFIG_BLK_DEV_NULL_BLK =
is not set=0A# CONFIG_BLK_DEV_FD is not set=0A# CONFIG_BLK_DEV_PCIESSD_MTIP=
32XX is not set=0A# CONFIG_ZRAM is not set=0A# CONFIG_BLK_CPQ_CISS_DA is no=
t set=0A# CONFIG_BLK_DEV_DAC960 is not set=0A# CONFIG_BLK_DEV_UMEM is not s=
et=0A# CONFIG_BLK_DEV_COW_COMMON is not set=0ACONFIG_BLK_DEV_LOOP=3Dy=0ACON=
FIG_BLK_DEV_LOOP_MIN_COUNT=3D0=0A# CONFIG_BLK_DEV_CRYPTOLOOP is not set=0A#=
 CONFIG_BLK_DEV_DRBD is not set=0A# CONFIG_BLK_DEV_NBD is not set=0A# CONFI=
G_BLK_DEV_SKD is not set=0A# CONFIG_BLK_DEV_OSD is not set=0A# CONFIG_BLK_D=
EV_SX8 is not set=0A# CONFIG_BLK_DEV_RAM is not set=0A# CONFIG_CDROM_PKTCDV=
D is not set=0A# CONFIG_ATA_OVER_ETH is not set=0ACONFIG_XEN_BLKDEV_FRONTEN=
D=3Dy=0ACONFIG_XEN_BLKDEV_BACKEND=3Dy=0A# CONFIG_VIRTIO_BLK is not set=0A# =
CONFIG_BLK_DEV_HD is not set=0A# CONFIG_BLK_DEV_RBD is not set=0A# CONFIG_B=
LK_DEV_RSXX is not set=0A# CONFIG_BLK_DEV_NVME is not set=0A=0A#=0A# Misc d=
evices=0A#=0ACONFIG_SENSORS_LIS3LV02D=3Dm=0A# CONFIG_AD525X_DPOT is not set=
=0A# CONFIG_DUMMY_IRQ is not set=0A# CONFIG_IBM_ASM is not set=0A# CONFIG_P=
HANTOM is not set=0ACONFIG_SGI_IOC4=3Dm=0ACONFIG_TIFM_CORE=3Dm=0ACONFIG_TIF=
M_7XX1=3Dm=0A# CONFIG_ICS932S401 is not set=0ACONFIG_ENCLOSURE_SERVICES=3Dm=
=0ACONFIG_SGI_XP=3Dm=0ACONFIG_HP_ILO=3Dm=0ACONFIG_SGI_GRU=3Dm=0A# CONFIG_SG=
I_GRU_DEBUG is not set=0ACONFIG_APDS9802ALS=3Dm=0ACONFIG_ISL29003=3Dm=0ACON=
FIG_ISL29020=3Dm=0ACONFIG_SENSORS_TSL2550=3Dm=0A# CONFIG_SENSORS_BH1780 is =
not set=0ACONFIG_SENSORS_BH1770=3Dm=0ACONFIG_SENSORS_APDS990X=3Dm=0A# CONFI=
G_HMC6352 is not set=0A# CONFIG_DS1682 is not set=0ACONFIG_VMWARE_BALLOON=
=3Dm=0A# CONFIG_BMP085_I2C is not set=0A# CONFIG_USB_SWITCH_FSA9480 is not =
set=0A# CONFIG_SRAM is not set=0A# CONFIG_C2PORT is not set=0A=0A#=0A# EEPR=
OM support=0A#=0ACONFIG_EEPROM_AT24=3Dm=0ACONFIG_EEPROM_LEGACY=3Dm=0ACONFIG=
_EEPROM_MAX6875=3Dm=0ACONFIG_EEPROM_93CX6=3Dm=0ACONFIG_CB710_CORE=3Dm=0A# C=
ONFIG_CB710_DEBUG is not set=0ACONFIG_CB710_DEBUG_ASSUMPTIONS=3Dy=0A=0A#=0A=
# Texas Instruments shared transport line discipline=0A#=0ACONFIG_SENSORS_L=
IS3_I2C=3Dm=0A=0A#=0A# Altera FPGA firmware download module=0A#=0ACONFIG_AL=
TERA_STAPL=3Dm=0ACONFIG_VMWARE_VMCI=3Dm=0A=0A#=0A# Intel MIC Bus Driver=0A#=
=0ACONFIG_INTEL_MIC_BUS=3Dm=0A=0A#=0A# SCIF Bus Driver=0A#=0A# CONFIG_SCIF_=
BUS is not set=0A=0A#=0A# Intel MIC Host Driver=0A#=0A=0A#=0A# Intel MIC Ca=
rd Driver=0A#=0A=0A#=0A# SCIF Driver=0A#=0A=0A#=0A# Intel MIC Coprocessor S=
tate Management (COSM) Drivers=0A#=0A# CONFIG_GENWQE is not set=0A# CONFIG_=
ECHO is not set=0A# CONFIG_CXL_BASE is not set=0A# CONFIG_CXL_KERNEL_API is=
 not set=0A# CONFIG_CXL_EEH is not set=0ACONFIG_HAVE_IDE=3Dy=0A# CONFIG_IDE=
 is not set=0A=0A#=0A# SCSI device support=0A#=0ACONFIG_SCSI_MOD=3Dy=0ACONF=
IG_RAID_ATTRS=3Dm=0ACONFIG_SCSI=3Dy=0ACONFIG_SCSI_DMA=3Dy=0ACONFIG_SCSI_NET=
LINK=3Dy=0A# CONFIG_SCSI_MQ_DEFAULT is not set=0ACONFIG_SCSI_PROC_FS=3Dy=0A=
=0A#=0A# SCSI support type (disk, tape, CD-ROM)=0A#=0ACONFIG_BLK_DEV_SD=3Dy=
=0ACONFIG_CHR_DEV_ST=3Dm=0ACONFIG_CHR_DEV_OSST=3Dm=0ACONFIG_BLK_DEV_SR=3Dy=
=0ACONFIG_BLK_DEV_SR_VENDOR=3Dy=0ACONFIG_CHR_DEV_SG=3Dy=0ACONFIG_CHR_DEV_SC=
H=3Dm=0ACONFIG_SCSI_ENCLOSURE=3Dm=0ACONFIG_SCSI_CONSTANTS=3Dy=0ACONFIG_SCSI=
_LOGGING=3Dy=0ACONFIG_SCSI_SCAN_ASYNC=3Dy=0A=0A#=0A# SCSI Transports=0A#=0A=
CONFIG_SCSI_SPI_ATTRS=3Dm=0ACONFIG_SCSI_FC_ATTRS=3Dm=0ACONFIG_SCSI_ISCSI_AT=
TRS=3Dm=0ACONFIG_SCSI_SAS_ATTRS=3Dm=0ACONFIG_SCSI_SAS_LIBSAS=3Dm=0ACONFIG_S=
CSI_SAS_HOST_SMP=3Dy=0ACONFIG_SCSI_SRP_ATTRS=3Dm=0A# CONFIG_SCSI_LOWLEVEL i=
s not set=0A# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set=0ACONFIG_SCSI_DH=3Dy=
=0ACONFIG_SCSI_DH_RDAC=3Dm=0ACONFIG_SCSI_DH_HP_SW=3Dm=0ACONFIG_SCSI_DH_EMC=
=3Dm=0ACONFIG_SCSI_DH_ALUA=3Dm=0ACONFIG_SCSI_OSD_INITIATOR=3Dm=0ACONFIG_SCS=
I_OSD_ULD=3Dm=0ACONFIG_SCSI_OSD_DPRINT_SENSE=3D1=0A# CONFIG_SCSI_OSD_DEBUG =
is not set=0A# CONFIG_ATA is not set=0ACONFIG_MD=3Dy=0ACONFIG_BLK_DEV_MD=3D=
y=0ACONFIG_MD_AUTODETECT=3Dy=0ACONFIG_MD_LINEAR=3Dm=0ACONFIG_MD_RAID0=3Dm=
=0ACONFIG_MD_RAID1=3Dm=0ACONFIG_MD_RAID10=3Dm=0ACONFIG_MD_RAID456=3Dm=0ACON=
FIG_MD_MULTIPATH=3Dm=0ACONFIG_MD_FAULTY=3Dm=0ACONFIG_BCACHE=3Dm=0A# CONFIG_=
BCACHE_DEBUG is not set=0A# CONFIG_BCACHE_CLOSURES_DEBUG is not set=0ACONFI=
G_BLK_DEV_DM_BUILTIN=3Dy=0ACONFIG_BLK_DEV_DM=3Dy=0A# CONFIG_DM_MQ_DEFAULT i=
s not set=0ACONFIG_DM_DEBUG=3Dy=0ACONFIG_DM_BUFIO=3Dy=0ACONFIG_DM_BIO_PRISO=
N=3Dm=0ACONFIG_DM_PERSISTENT_DATA=3Dm=0A# CONFIG_DM_DEBUG_BLOCK_STACK_TRACI=
NG is not set=0ACONFIG_DM_CRYPT=3Dm=0ACONFIG_DM_SNAPSHOT=3Dy=0ACONFIG_DM_TH=
IN_PROVISIONING=3Dm=0ACONFIG_DM_CACHE=3Dm=0ACONFIG_DM_CACHE_MQ=3Dm=0ACONFIG=
_DM_CACHE_SMQ=3Dm=0ACONFIG_DM_CACHE_CLEANER=3Dm=0A# CONFIG_DM_ERA is not se=
t=0ACONFIG_DM_MIRROR=3Dy=0ACONFIG_DM_LOG_USERSPACE=3Dm=0ACONFIG_DM_RAID=3Dm=
=0ACONFIG_DM_ZERO=3Dy=0ACONFIG_DM_MULTIPATH=3Dm=0ACONFIG_DM_MULTIPATH_QL=3D=
m=0ACONFIG_DM_MULTIPATH_ST=3Dm=0ACONFIG_DM_DELAY=3Dm=0ACONFIG_DM_UEVENT=3Dy=
=0ACONFIG_DM_FLAKEY=3Dm=0ACONFIG_DM_VERITY=3Dm=0ACONFIG_DM_SWITCH=3Dm=0A# C=
ONFIG_DM_LOG_WRITES is not set=0ACONFIG_TARGET_CORE=3Dm=0ACONFIG_TCM_IBLOCK=
=3Dm=0ACONFIG_TCM_FILEIO=3Dm=0ACONFIG_TCM_PSCSI=3Dm=0A# CONFIG_TCM_USER2 is=
 not set=0ACONFIG_LOOPBACK_TARGET=3Dm=0ACONFIG_ISCSI_TARGET=3Dm=0A# CONFIG_=
FUSION is not set=0A=0A#=0A# IEEE 1394 (FireWire) support=0A#=0A# CONFIG_FI=
REWIRE is not set=0A# CONFIG_FIREWIRE_NOSY is not set=0A# CONFIG_MACINTOSH_=
DRIVERS is not set=0ACONFIG_NETDEVICES=3Dy=0ACONFIG_NET_CORE=3Dy=0A# CONFIG=
_BONDING is not set=0ACONFIG_DUMMY=3Dy=0A# CONFIG_EQUALIZER is not set=0ACO=
NFIG_NET_FC=3Dy=0A# CONFIG_IFB is not set=0A# CONFIG_NET_TEAM is not set=0A=
# CONFIG_MACVLAN is not set=0A# CONFIG_IPVLAN is not set=0A# CONFIG_VXLAN i=
s not set=0ACONFIG_GENEVE=3Dm=0ACONFIG_NETCONSOLE=3Dy=0ACONFIG_NETCONSOLE_D=
YNAMIC=3Dy=0ACONFIG_NETPOLL=3Dy=0ACONFIG_NET_POLL_CONTROLLER=3Dy=0ACONFIG_T=
UN=3Dy=0A# CONFIG_TUN_VNET_CROSS_LE is not set=0ACONFIG_VETH=3Dy=0A# CONFIG=
_VIRTIO_NET is not set=0ACONFIG_NLMON=3Dy=0A# CONFIG_ARCNET is not set=0A=
=0A#=0A# CAIF transport drivers=0A#=0ACONFIG_VHOST_NET=3Dm=0ACONFIG_VHOST_S=
CSI=3Dm=0ACONFIG_VHOST_RING=3Dm=0ACONFIG_VHOST=3Dm=0A# CONFIG_VHOST_CROSS_E=
NDIAN_LEGACY is not set=0A=0A#=0A# Distributed Switch Architecture drivers=
=0A#=0A# CONFIG_NET_DSA_MV88E6XXX is not set=0A# CONFIG_NET_DSA_MV88E6XXX_N=
EED_PPU is not set=0ACONFIG_ETHERNET=3Dy=0ACONFIG_MDIO=3Dm=0A# CONFIG_NET_V=
ENDOR_3COM is not set=0A# CONFIG_NET_VENDOR_ADAPTEC is not set=0A# CONFIG_N=
ET_VENDOR_AGERE is not set=0A# CONFIG_NET_VENDOR_ALTEON is not set=0A# CONF=
IG_ALTERA_TSE is not set=0A# CONFIG_NET_VENDOR_AMD is not set=0A# CONFIG_NE=
T_VENDOR_ARC is not set=0A# CONFIG_NET_VENDOR_ATHEROS is not set=0A# CONFIG=
_NET_VENDOR_AURORA is not set=0A# CONFIG_NET_CADENCE is not set=0ACONFIG_NE=
T_VENDOR_BROADCOM=3Dy=0A# CONFIG_B44 is not set=0A# CONFIG_BCMGENET is not =
set=0ACONFIG_BNX2=3Dm=0ACONFIG_CNIC=3Dm=0A# CONFIG_TIGON3 is not set=0A# CO=
NFIG_BNX2X is not set=0A# CONFIG_BNXT is not set=0A# CONFIG_NET_VENDOR_BROC=
ADE is not set=0ACONFIG_NET_VENDOR_CAVIUM=3Dy=0A# CONFIG_THUNDER_NIC_PF is =
not set=0A# CONFIG_THUNDER_NIC_VF is not set=0A# CONFIG_THUNDER_NIC_BGX is =
not set=0A# CONFIG_LIQUIDIO is not set=0ACONFIG_NET_VENDOR_CHELSIO=3Dy=0A# =
CONFIG_CHELSIO_T1 is not set=0ACONFIG_CHELSIO_T3=3Dm=0ACONFIG_CHELSIO_T4=3D=
m=0A# CONFIG_CHELSIO_T4_DCB is not set=0A# CONFIG_CHELSIO_T4VF is not set=
=0A# CONFIG_NET_VENDOR_CISCO is not set=0A# CONFIG_CX_ECAT is not set=0A# C=
ONFIG_DNET is not set=0A# CONFIG_NET_VENDOR_DEC is not set=0A# CONFIG_NET_V=
ENDOR_DLINK is not set=0A# CONFIG_NET_VENDOR_EMULEX is not set=0ACONFIG_NET=
_VENDOR_EZCHIP=3Dy=0A# CONFIG_NET_VENDOR_EXAR is not set=0A# CONFIG_NET_VEN=
DOR_FUJITSU is not set=0A# CONFIG_NET_VENDOR_HP is not set=0A# CONFIG_NET_V=
ENDOR_INTEL is not set=0A# CONFIG_JME is not set=0A# CONFIG_NET_VENDOR_MARV=
ELL is not set=0A# CONFIG_NET_VENDOR_MELLANOX is not set=0A# CONFIG_NET_VEN=
DOR_MICREL is not set=0A# CONFIG_NET_VENDOR_MYRI is not set=0A# CONFIG_FEAL=
NX is not set=0A# CONFIG_NET_VENDOR_NATSEMI is not set=0A# CONFIG_NET_VENDO=
R_NVIDIA is not set=0A# CONFIG_NET_VENDOR_OKI is not set=0A# CONFIG_ETHOC i=
s not set=0A# CONFIG_NET_PACKET_ENGINE is not set=0A# CONFIG_NET_VENDOR_QLO=
GIC is not set=0A# CONFIG_NET_VENDOR_QUALCOMM is not set=0A# CONFIG_NET_VEN=
DOR_REALTEK is not set=0ACONFIG_NET_VENDOR_RENESAS=3Dy=0A# CONFIG_NET_VENDO=
R_RDC is not set=0A# CONFIG_NET_VENDOR_ROCKER is not set=0A# CONFIG_NET_VEN=
DOR_SAMSUNG is not set=0A# CONFIG_NET_VENDOR_SEEQ is not set=0A# CONFIG_NET=
_VENDOR_SILAN is not set=0A# CONFIG_NET_VENDOR_SIS is not set=0A# CONFIG_SF=
C is not set=0A# CONFIG_NET_VENDOR_SMSC is not set=0A# CONFIG_NET_VENDOR_ST=
MICRO is not set=0A# CONFIG_NET_VENDOR_SUN is not set=0ACONFIG_NET_VENDOR_S=
YNOPSYS=3Dy=0A# CONFIG_NET_VENDOR_TEHUTI is not set=0A# CONFIG_NET_VENDOR_T=
I is not set=0A# CONFIG_NET_VENDOR_VIA is not set=0A# CONFIG_NET_VENDOR_WIZ=
NET is not set=0A# CONFIG_NET_VENDOR_XIRCOM is not set=0A# CONFIG_FDDI is n=
ot set=0A# CONFIG_HIPPI is not set=0A# CONFIG_NET_SB1000 is not set=0A# CON=
FIG_PHYLIB is not set=0ACONFIG_PPP=3Dm=0A# CONFIG_PPP_BSDCOMP is not set=0A=
# CONFIG_PPP_DEFLATE is not set=0A# CONFIG_PPP_FILTER is not set=0A# CONFIG=
_PPP_MPPE is not set=0A# CONFIG_PPP_MULTILINK is not set=0A# CONFIG_PPPOE i=
s not set=0A# CONFIG_PPTP is not set=0A# CONFIG_PPP_ASYNC is not set=0A# CO=
NFIG_PPP_SYNC_TTY is not set=0A# CONFIG_SLIP is not set=0ACONFIG_SLHC=3Dm=
=0A=0A#=0A# Host-side USB support is needed for USB Network Adapter support=
=0A#=0A# CONFIG_WLAN is not set=0A=0A#=0A# Enable WiMAX (Networking options=
) to see the WiMAX drivers=0A#=0A# CONFIG_WAN is not set=0ACONFIG_XEN_NETDE=
V_FRONTEND=3Dy=0ACONFIG_XEN_NETDEV_BACKEND=3Dy=0A# CONFIG_VMXNET3 is not se=
t=0A# CONFIG_FUJITSU_ES is not set=0A# CONFIG_HYPERV_NET is not set=0A# CON=
FIG_ISDN is not set=0A# CONFIG_NVM is not set=0A=0A#=0A# Input device suppo=
rt=0A#=0ACONFIG_INPUT=3Dy=0ACONFIG_INPUT_LEDS=3Dy=0ACONFIG_INPUT_FF_MEMLESS=
=3Dy=0ACONFIG_INPUT_POLLDEV=3Dm=0ACONFIG_INPUT_SPARSEKMAP=3Dm=0A# CONFIG_IN=
PUT_MATRIXKMAP is not set=0A=0A#=0A# Userland interfaces=0A#=0ACONFIG_INPUT=
_MOUSEDEV=3Dy=0A# CONFIG_INPUT_MOUSEDEV_PSAUX is not set=0ACONFIG_INPUT_MOU=
SEDEV_SCREEN_X=3D1024=0ACONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768=0ACONFIG_INPUT=
_JOYDEV=3Dm=0ACONFIG_INPUT_EVDEV=3Dy=0A# CONFIG_INPUT_EVBUG is not set=0A=
=0A#=0A# Input Device Drivers=0A#=0ACONFIG_INPUT_KEYBOARD=3Dy=0A# CONFIG_KE=
YBOARD_ADP5588 is not set=0A# CONFIG_KEYBOARD_ADP5589 is not set=0ACONFIG_K=
EYBOARD_ATKBD=3Dy=0A# CONFIG_KEYBOARD_QT1070 is not set=0A# CONFIG_KEYBOARD=
_QT2160 is not set=0A# CONFIG_KEYBOARD_LKKBD is not set=0A# CONFIG_KEYBOARD=
_TCA6416 is not set=0A# CONFIG_KEYBOARD_TCA8418 is not set=0A# CONFIG_KEYBO=
ARD_LM8323 is not set=0A# CONFIG_KEYBOARD_LM8333 is not set=0A# CONFIG_KEYB=
OARD_MAX7359 is not set=0A# CONFIG_KEYBOARD_MCS is not set=0A# CONFIG_KEYBO=
ARD_MPR121 is not set=0A# CONFIG_KEYBOARD_NEWTON is not set=0A# CONFIG_KEYB=
OARD_OPENCORES is not set=0A# CONFIG_KEYBOARD_SAMSUNG is not set=0A# CONFIG=
_KEYBOARD_STOWAWAY is not set=0A# CONFIG_KEYBOARD_SUNKBD is not set=0A# CON=
FIG_KEYBOARD_XTKBD is not set=0ACONFIG_INPUT_MOUSE=3Dy=0ACONFIG_MOUSE_PS2=
=3Dy=0ACONFIG_MOUSE_PS2_ALPS=3Dy=0ACONFIG_MOUSE_PS2_LOGIPS2PP=3Dy=0ACONFIG_=
MOUSE_PS2_SYNAPTICS=3Dy=0ACONFIG_MOUSE_PS2_CYPRESS=3Dy=0ACONFIG_MOUSE_PS2_L=
IFEBOOK=3Dy=0ACONFIG_MOUSE_PS2_TRACKPOINT=3Dy=0ACONFIG_MOUSE_PS2_ELANTECH=
=3Dy=0ACONFIG_MOUSE_PS2_SENTELIC=3Dy=0A# CONFIG_MOUSE_PS2_TOUCHKIT is not s=
et=0ACONFIG_MOUSE_PS2_FOCALTECH=3Dy=0A# CONFIG_MOUSE_PS2_VMMOUSE is not set=
=0ACONFIG_MOUSE_SERIAL=3Dm=0ACONFIG_MOUSE_CYAPA=3Dm=0A# CONFIG_MOUSE_ELAN_I=
2C is not set=0ACONFIG_MOUSE_VSXXXAA=3Dm=0ACONFIG_MOUSE_SYNAPTICS_I2C=3Dm=
=0ACONFIG_INPUT_JOYSTICK=3Dy=0ACONFIG_JOYSTICK_ANALOG=3Dm=0ACONFIG_JOYSTICK=
_A3D=3Dm=0ACONFIG_JOYSTICK_ADI=3Dm=0ACONFIG_JOYSTICK_COBRA=3Dm=0ACONFIG_JOY=
STICK_GF2K=3Dm=0ACONFIG_JOYSTICK_GRIP=3Dm=0ACONFIG_JOYSTICK_GRIP_MP=3Dm=0AC=
ONFIG_JOYSTICK_GUILLEMOT=3Dm=0ACONFIG_JOYSTICK_INTERACT=3Dm=0ACONFIG_JOYSTI=
CK_SIDEWINDER=3Dm=0ACONFIG_JOYSTICK_TMDC=3Dm=0ACONFIG_JOYSTICK_IFORCE=3Dm=
=0ACONFIG_JOYSTICK_IFORCE_232=3Dy=0ACONFIG_JOYSTICK_WARRIOR=3Dm=0ACONFIG_JO=
YSTICK_MAGELLAN=3Dm=0ACONFIG_JOYSTICK_SPACEORB=3Dm=0ACONFIG_JOYSTICK_SPACEB=
ALL=3Dm=0ACONFIG_JOYSTICK_STINGER=3Dm=0ACONFIG_JOYSTICK_TWIDJOY=3Dm=0ACONFI=
G_JOYSTICK_ZHENHUA=3Dm=0A# CONFIG_JOYSTICK_AS5011 is not set=0ACONFIG_JOYST=
ICK_JOYDUMP=3Dm=0ACONFIG_INPUT_TABLET=3Dy=0ACONFIG_TABLET_SERIAL_WACOM4=3Dm=
=0ACONFIG_INPUT_TOUCHSCREEN=3Dy=0ACONFIG_TOUCHSCREEN_PROPERTIES=3Dy=0A# CON=
FIG_TOUCHSCREEN_AD7879 is not set=0ACONFIG_TOUCHSCREEN_ATMEL_MXT=3Dm=0A# CO=
NFIG_TOUCHSCREEN_BU21013 is not set=0A# CONFIG_TOUCHSCREEN_CYTTSP_CORE is n=
ot set=0A# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set=0ACONFIG_TOUCHSCREEN_=
DYNAPRO=3Dm=0A# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set=0ACONFIG_TOUCHSCREE=
N_EETI=3Dm=0ACONFIG_TOUCHSCREEN_FUJITSU=3Dm=0A# CONFIG_TOUCHSCREEN_GOODIX i=
s not set=0ACONFIG_TOUCHSCREEN_ILI210X=3Dm=0ACONFIG_TOUCHSCREEN_GUNZE=3Dm=
=0A# CONFIG_TOUCHSCREEN_ELAN is not set=0ACONFIG_TOUCHSCREEN_ELO=3Dm=0ACONF=
IG_TOUCHSCREEN_WACOM_W8001=3Dm=0ACONFIG_TOUCHSCREEN_WACOM_I2C=3Dm=0A# CONFI=
G_TOUCHSCREEN_MAX11801 is not set=0ACONFIG_TOUCHSCREEN_MCS5000=3Dm=0ACONFIG=
_TOUCHSCREEN_MMS114=3Dm=0ACONFIG_TOUCHSCREEN_MTOUCH=3Dm=0ACONFIG_TOUCHSCREE=
N_INEXIO=3Dm=0ACONFIG_TOUCHSCREEN_MK712=3Dm=0ACONFIG_TOUCHSCREEN_PENMOUNT=
=3Dm=0ACONFIG_TOUCHSCREEN_EDT_FT5X06=3Dm=0ACONFIG_TOUCHSCREEN_TOUCHRIGHT=3D=
m=0ACONFIG_TOUCHSCREEN_TOUCHWIN=3Dm=0ACONFIG_TOUCHSCREEN_PIXCIR=3Dm=0A# CON=
FIG_TOUCHSCREEN_WDT87XX_I2C is not set=0ACONFIG_TOUCHSCREEN_TOUCHIT213=3Dm=
=0ACONFIG_TOUCHSCREEN_TSC_SERIO=3Dm=0A# CONFIG_TOUCHSCREEN_TSC2004 is not s=
et=0ACONFIG_TOUCHSCREEN_TSC2007=3Dm=0ACONFIG_TOUCHSCREEN_ST1232=3Dm=0A# CON=
FIG_TOUCHSCREEN_SX8654 is not set=0A# CONFIG_TOUCHSCREEN_TPS6507X is not se=
t=0A# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set=0ACONFIG_INPUT_MISC=3Dy=0A=
# CONFIG_INPUT_AD714X is not set=0A# CONFIG_INPUT_BMA150 is not set=0A# CON=
FIG_INPUT_E3X0_BUTTON is not set=0ACONFIG_INPUT_PCSPKR=3Dm=0ACONFIG_INPUT_M=
MA8450=3Dm=0ACONFIG_INPUT_MPU3050=3Dm=0ACONFIG_INPUT_APANEL=3Dm=0ACONFIG_IN=
PUT_ATLAS_BTNS=3Dm=0ACONFIG_INPUT_KXTJ9=3Dm=0A# CONFIG_INPUT_KXTJ9_POLLED_M=
ODE is not set=0ACONFIG_INPUT_UINPUT=3Dm=0A# CONFIG_INPUT_PCF8574 is not se=
t=0A# CONFIG_INPUT_ADXL34X is not set=0ACONFIG_INPUT_CMA3000=3Dm=0ACONFIG_I=
NPUT_CMA3000_I2C=3Dm=0ACONFIG_INPUT_XEN_KBDDEV_FRONTEND=3Dy=0ACONFIG_INPUT_=
IDEAPAD_SLIDEBAR=3Dm=0A# CONFIG_INPUT_DRV2665_HAPTICS is not set=0A# CONFIG=
_INPUT_DRV2667_HAPTICS is not set=0A=0A#=0A# Hardware I/O ports=0A#=0ACONFI=
G_SERIO=3Dy=0ACONFIG_ARCH_MIGHT_HAVE_PC_SERIO=3Dy=0ACONFIG_SERIO_I8042=3Dy=
=0ACONFIG_SERIO_SERPORT=3Dy=0A# CONFIG_SERIO_CT82C710 is not set=0A# CONFIG=
_SERIO_PCIPS2 is not set=0ACONFIG_SERIO_LIBPS2=3Dy=0ACONFIG_SERIO_RAW=3Dm=
=0ACONFIG_SERIO_ALTERA_PS2=3Dm=0A# CONFIG_SERIO_PS2MULT is not set=0ACONFIG=
_SERIO_ARC_PS2=3Dm=0ACONFIG_HYPERV_KEYBOARD=3Dm=0A# CONFIG_USERIO is not se=
t=0ACONFIG_GAMEPORT=3Dm=0ACONFIG_GAMEPORT_NS558=3Dm=0ACONFIG_GAMEPORT_L4=3D=
m=0ACONFIG_GAMEPORT_EMU10K1=3Dm=0ACONFIG_GAMEPORT_FM801=3Dm=0A=0A#=0A# Char=
acter devices=0A#=0ACONFIG_TTY=3Dy=0ACONFIG_VT=3Dy=0ACONFIG_CONSOLE_TRANSLA=
TIONS=3Dy=0ACONFIG_VT_CONSOLE=3Dy=0ACONFIG_VT_CONSOLE_SLEEP=3Dy=0ACONFIG_HW=
_CONSOLE=3Dy=0ACONFIG_VT_HW_CONSOLE_BINDING=3Dy=0ACONFIG_UNIX98_PTYS=3Dy=0A=
CONFIG_DEVPTS_MULTIPLE_INSTANCES=3Dy=0A# CONFIG_LEGACY_PTYS is not set=0ACO=
NFIG_SERIAL_NONSTANDARD=3Dy=0ACONFIG_ROCKETPORT=3Dm=0ACONFIG_CYCLADES=3Dm=
=0A# CONFIG_CYZ_INTR is not set=0A# CONFIG_MOXA_INTELLIO is not set=0A# CON=
FIG_MOXA_SMARTIO is not set=0ACONFIG_SYNCLINK=3Dm=0ACONFIG_SYNCLINKMP=3Dm=
=0ACONFIG_SYNCLINK_GT=3Dm=0ACONFIG_NOZOMI=3Dm=0A# CONFIG_ISI is not set=0AC=
ONFIG_N_HDLC=3Dm=0ACONFIG_N_GSM=3Dm=0A# CONFIG_TRACE_SINK is not set=0ACONF=
IG_DEVMEM=3Dy=0A# CONFIG_DEVKMEM is not set=0A=0A#=0A# Serial drivers=0A#=
=0ACONFIG_SERIAL_EARLYCON=3Dy=0ACONFIG_SERIAL_8250=3Dy=0A# CONFIG_SERIAL_82=
50_DEPRECATED_OPTIONS is not set=0ACONFIG_SERIAL_8250_PNP=3Dy=0ACONFIG_SERI=
AL_8250_CONSOLE=3Dy=0ACONFIG_SERIAL_8250_DMA=3Dy=0ACONFIG_SERIAL_8250_PCI=
=3Dy=0ACONFIG_SERIAL_8250_CS=3Dm=0ACONFIG_SERIAL_8250_NR_UARTS=3D32=0ACONFI=
G_SERIAL_8250_RUNTIME_UARTS=3D4=0ACONFIG_SERIAL_8250_EXTENDED=3Dy=0ACONFIG_=
SERIAL_8250_MANY_PORTS=3Dy=0ACONFIG_SERIAL_8250_SHARE_IRQ=3Dy=0A# CONFIG_SE=
RIAL_8250_DETECT_IRQ is not set=0ACONFIG_SERIAL_8250_RSA=3Dy=0A# CONFIG_SER=
IAL_8250_FSL is not set=0A# CONFIG_SERIAL_8250_DW is not set=0A# CONFIG_SER=
IAL_8250_RT288X is not set=0A# CONFIG_SERIAL_8250_FINTEK is not set=0A# CON=
FIG_SERIAL_8250_MID is not set=0A=0A#=0A# Non-8250 serial port support=0A#=
=0A# CONFIG_SERIAL_KGDB_NMI is not set=0A# CONFIG_SERIAL_UARTLITE is not se=
t=0ACONFIG_SERIAL_CORE=3Dy=0ACONFIG_SERIAL_CORE_CONSOLE=3Dy=0ACONFIG_CONSOL=
E_POLL=3Dy=0ACONFIG_SERIAL_JSM=3Dm=0A# CONFIG_SERIAL_SCCNXP is not set=0A# =
CONFIG_SERIAL_SC16IS7XX is not set=0A# CONFIG_SERIAL_ALTERA_JTAGUART is not=
 set=0A# CONFIG_SERIAL_ALTERA_UART is not set=0ACONFIG_SERIAL_ARC=3Dm=0ACON=
FIG_SERIAL_ARC_NR_PORTS=3D1=0A# CONFIG_SERIAL_RP2 is not set=0A# CONFIG_SER=
IAL_FSL_LPUART is not set=0ACONFIG_HVC_DRIVER=3Dy=0ACONFIG_HVC_IRQ=3Dy=0ACO=
NFIG_HVC_XEN=3Dy=0ACONFIG_HVC_XEN_FRONTEND=3Dy=0ACONFIG_VIRTIO_CONSOLE=3Dm=
=0ACONFIG_IPMI_HANDLER=3Dm=0A# CONFIG_IPMI_PANIC_EVENT is not set=0ACONFIG_=
IPMI_DEVICE_INTERFACE=3Dm=0ACONFIG_IPMI_SI=3Dm=0A# CONFIG_IPMI_SI_PROBE_DEF=
AULTS is not set=0A# CONFIG_IPMI_SSIF is not set=0ACONFIG_IPMI_WATCHDOG=3Dm=
=0ACONFIG_IPMI_POWEROFF=3Dm=0ACONFIG_HW_RANDOM=3Dy=0ACONFIG_HW_RANDOM_TIMER=
IOMEM=3Dm=0ACONFIG_HW_RANDOM_INTEL=3Dm=0ACONFIG_HW_RANDOM_AMD=3Dm=0ACONFIG_=
HW_RANDOM_VIA=3Dm=0ACONFIG_HW_RANDOM_VIRTIO=3Dm=0ACONFIG_HW_RANDOM_TPM=3Dm=
=0ACONFIG_NVRAM=3Dy=0ACONFIG_R3964=3Dm=0A# CONFIG_APPLICOM is not set=0A=0A=
#=0A# PCMCIA character devices=0A#=0A# CONFIG_SYNCLINK_CS is not set=0ACONF=
IG_CARDMAN_4000=3Dm=0ACONFIG_CARDMAN_4040=3Dm=0ACONFIG_IPWIRELESS=3Dm=0ACON=
FIG_MWAVE=3Dm=0ACONFIG_RAW_DRIVER=3Dy=0ACONFIG_MAX_RAW_DEVS=3D8192=0ACONFIG=
_HPET=3Dy=0A# CONFIG_HPET_MMAP is not set=0ACONFIG_HANGCHECK_TIMER=3Dm=0ACO=
NFIG_UV_MMTIMER=3Dm=0ACONFIG_TCG_TPM=3Dm=0ACONFIG_TCG_TIS=3Dm=0A# CONFIG_TC=
G_TIS_I2C_ATMEL is not set=0A# CONFIG_TCG_TIS_I2C_INFINEON is not set=0A# C=
ONFIG_TCG_TIS_I2C_NUVOTON is not set=0ACONFIG_TCG_NSC=3Dm=0ACONFIG_TCG_ATME=
L=3Dm=0ACONFIG_TCG_INFINEON=3Dm=0A# CONFIG_TCG_XEN is not set=0A# CONFIG_TC=
G_CRB is not set=0ACONFIG_TELCLOCK=3Dm=0ACONFIG_DEVPORT=3Dy=0A# CONFIG_XILL=
YBUS is not set=0A=0A#=0A# I2C support=0A#=0ACONFIG_I2C=3Dy=0ACONFIG_ACPI_I=
2C_OPREGION=3Dy=0ACONFIG_I2C_BOARDINFO=3Dy=0ACONFIG_I2C_COMPAT=3Dy=0ACONFIG=
_I2C_CHARDEV=3Dm=0ACONFIG_I2C_MUX=3Dm=0A=0A#=0A# Multiplexer I2C Chip suppo=
rt=0A#=0A# CONFIG_I2C_MUX_PCA9541 is not set=0A# CONFIG_I2C_MUX_PINCTRL is =
not set=0A# CONFIG_I2C_MUX_REG is not set=0ACONFIG_I2C_HELPER_AUTO=3Dy=0ACO=
NFIG_I2C_SMBUS=3Dm=0ACONFIG_I2C_ALGOBIT=3Dm=0ACONFIG_I2C_ALGOPCA=3Dm=0A=0A#=
=0A# I2C Hardware Bus support=0A#=0A=0A#=0A# PC SMBus host controller drive=
rs=0A#=0A# CONFIG_I2C_ALI1535 is not set=0A# CONFIG_I2C_ALI1563 is not set=
=0A# CONFIG_I2C_ALI15X3 is not set=0ACONFIG_I2C_AMD756=3Dm=0ACONFIG_I2C_AMD=
756_S4882=3Dm=0ACONFIG_I2C_AMD8111=3Dm=0ACONFIG_I2C_I801=3Dm=0ACONFIG_I2C_I=
SCH=3Dm=0ACONFIG_I2C_ISMT=3Dm=0ACONFIG_I2C_PIIX4=3Dm=0ACONFIG_I2C_NFORCE2=
=3Dm=0ACONFIG_I2C_NFORCE2_S4985=3Dm=0A# CONFIG_I2C_SIS5595 is not set=0A# C=
ONFIG_I2C_SIS630 is not set=0ACONFIG_I2C_SIS96X=3Dm=0ACONFIG_I2C_VIA=3Dm=0A=
CONFIG_I2C_VIAPRO=3Dm=0A=0A#=0A# ACPI drivers=0A#=0ACONFIG_I2C_SCMI=3Dm=0A=
=0A#=0A# I2C system bus drivers (mostly embedded / system-on-chip)=0A#=0ACO=
NFIG_I2C_DESIGNWARE_CORE=3Dm=0ACONFIG_I2C_DESIGNWARE_PLATFORM=3Dm=0ACONFIG_=
I2C_DESIGNWARE_PCI=3Dm=0A# CONFIG_I2C_EMEV2 is not set=0A# CONFIG_I2C_OCORE=
S is not set=0ACONFIG_I2C_PCA_PLATFORM=3Dm=0A# CONFIG_I2C_PXA_PCI is not se=
t=0ACONFIG_I2C_SIMTEC=3Dm=0A# CONFIG_I2C_XILINX is not set=0A=0A#=0A# Exter=
nal I2C/SMBus adapter drivers=0A#=0ACONFIG_I2C_PARPORT_LIGHT=3Dm=0A# CONFIG=
_I2C_TAOS_EVM is not set=0A=0A#=0A# Other I2C/SMBus bus drivers=0A#=0ACONFI=
G_I2C_STUB=3Dm=0A# CONFIG_I2C_SLAVE is not set=0A# CONFIG_I2C_DEBUG_CORE is=
 not set=0A# CONFIG_I2C_DEBUG_ALGO is not set=0A# CONFIG_I2C_DEBUG_BUS is n=
ot set=0A# CONFIG_SPI is not set=0A# CONFIG_SPMI is not set=0A# CONFIG_HSI =
is not set=0A=0A#=0A# PPS support=0A#=0ACONFIG_PPS=3Dm=0A# CONFIG_PPS_DEBUG=
 is not set=0A=0A#=0A# PPS clients support=0A#=0A# CONFIG_PPS_CLIENT_KTIMER=
 is not set=0ACONFIG_PPS_CLIENT_LDISC=3Dm=0ACONFIG_PPS_CLIENT_GPIO=3Dm=0A=
=0A#=0A# PPS generators support=0A#=0A=0A#=0A# PTP clock support=0A#=0ACONF=
IG_PTP_1588_CLOCK=3Dm=0A=0A#=0A# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING=
 to see the additional clocks.=0A#=0ACONFIG_PINCTRL=3Dy=0A=0A#=0A# Pin cont=
rollers=0A#=0A# CONFIG_DEBUG_PINCTRL is not set=0A# CONFIG_PINCTRL_CHERRYVI=
EW is not set=0A# CONFIG_PINCTRL_BROXTON is not set=0A# CONFIG_PINCTRL_SUNR=
ISEPOINT is not set=0ACONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy=0A# CONFIG_GPIO=
LIB is not set=0A# CONFIG_W1 is not set=0ACONFIG_POWER_SUPPLY=3Dy=0A# CONFI=
G_POWER_SUPPLY_DEBUG is not set=0A# CONFIG_PDA_POWER is not set=0A# CONFIG_=
TEST_POWER is not set=0A# CONFIG_BATTERY_DS2780 is not set=0A# CONFIG_BATTE=
RY_DS2781 is not set=0A# CONFIG_BATTERY_DS2782 is not set=0A# CONFIG_BATTER=
Y_SBS is not set=0A# CONFIG_BATTERY_BQ27XXX is not set=0A# CONFIG_BATTERY_M=
AX17040 is not set=0A# CONFIG_BATTERY_MAX17042 is not set=0A# CONFIG_CHARGE=
R_MAX8903 is not set=0A# CONFIG_CHARGER_LP8727 is not set=0A# CONFIG_CHARGE=
R_BQ2415X is not set=0ACONFIG_CHARGER_SMB347=3Dm=0A# CONFIG_BATTERY_GAUGE_L=
TC2941 is not set=0ACONFIG_POWER_RESET=3Dy=0A# CONFIG_POWER_RESET_RESTART i=
s not set=0A# CONFIG_POWER_AVS is not set=0ACONFIG_HWMON=3Dy=0A# CONFIG_HWM=
ON_VID is not set=0A# CONFIG_HWMON_DEBUG_CHIP is not set=0A=0A#=0A# Native =
drivers=0A#=0A# CONFIG_SENSORS_ABITUGURU is not set=0A# CONFIG_SENSORS_ABIT=
UGURU3 is not set=0A# CONFIG_SENSORS_AD7414 is not set=0A# CONFIG_SENSORS_A=
D7418 is not set=0A# CONFIG_SENSORS_ADM1021 is not set=0A# CONFIG_SENSORS_A=
DM1025 is not set=0A# CONFIG_SENSORS_ADM1026 is not set=0A# CONFIG_SENSORS_=
ADM1029 is not set=0A# CONFIG_SENSORS_ADM1031 is not set=0A# CONFIG_SENSORS=
_ADM9240 is not set=0A# CONFIG_SENSORS_ADT7410 is not set=0A# CONFIG_SENSOR=
S_ADT7411 is not set=0A# CONFIG_SENSORS_ADT7462 is not set=0A# CONFIG_SENSO=
RS_ADT7470 is not set=0A# CONFIG_SENSORS_ADT7475 is not set=0A# CONFIG_SENS=
ORS_ASC7621 is not set=0A# CONFIG_SENSORS_K8TEMP is not set=0A# CONFIG_SENS=
ORS_K10TEMP is not set=0A# CONFIG_SENSORS_FAM15H_POWER is not set=0A# CONFI=
G_SENSORS_APPLESMC is not set=0A# CONFIG_SENSORS_ASB100 is not set=0A# CONF=
IG_SENSORS_ATXP1 is not set=0A# CONFIG_SENSORS_DS620 is not set=0A# CONFIG_=
SENSORS_DS1621 is not set=0ACONFIG_SENSORS_DELL_SMM=3Dm=0A# CONFIG_SENSORS_=
I5K_AMB is not set=0A# CONFIG_SENSORS_F71805F is not set=0A# CONFIG_SENSORS=
_F71882FG is not set=0A# CONFIG_SENSORS_F75375S is not set=0A# CONFIG_SENSO=
RS_FSCHMD is not set=0A# CONFIG_SENSORS_GL518SM is not set=0A# CONFIG_SENSO=
RS_GL520SM is not set=0A# CONFIG_SENSORS_G760A is not set=0A# CONFIG_SENSOR=
S_G762 is not set=0A# CONFIG_SENSORS_HIH6130 is not set=0A# CONFIG_SENSORS_=
IBMAEM is not set=0A# CONFIG_SENSORS_IBMPEX is not set=0A# CONFIG_SENSORS_I=
5500 is not set=0A# CONFIG_SENSORS_CORETEMP is not set=0A# CONFIG_SENSORS_I=
T87 is not set=0A# CONFIG_SENSORS_JC42 is not set=0A# CONFIG_SENSORS_POWR12=
20 is not set=0A# CONFIG_SENSORS_LINEAGE is not set=0A# CONFIG_SENSORS_LTC2=
945 is not set=0A# CONFIG_SENSORS_LTC4151 is not set=0A# CONFIG_SENSORS_LTC=
4215 is not set=0A# CONFIG_SENSORS_LTC4222 is not set=0A# CONFIG_SENSORS_LT=
C4245 is not set=0A# CONFIG_SENSORS_LTC4260 is not set=0A# CONFIG_SENSORS_L=
TC4261 is not set=0A# CONFIG_SENSORS_MAX16065 is not set=0A# CONFIG_SENSORS=
_MAX1619 is not set=0A# CONFIG_SENSORS_MAX1668 is not set=0A# CONFIG_SENSOR=
S_MAX197 is not set=0A# CONFIG_SENSORS_MAX6639 is not set=0A# CONFIG_SENSOR=
S_MAX6642 is not set=0A# CONFIG_SENSORS_MAX6650 is not set=0A# CONFIG_SENSO=
RS_MAX6697 is not set=0A# CONFIG_SENSORS_MAX31790 is not set=0A# CONFIG_SEN=
SORS_HTU21 is not set=0A# CONFIG_SENSORS_MCP3021 is not set=0A# CONFIG_SENS=
ORS_LM63 is not set=0A# CONFIG_SENSORS_LM73 is not set=0A# CONFIG_SENSORS_L=
M75 is not set=0A# CONFIG_SENSORS_LM77 is not set=0A# CONFIG_SENSORS_LM78 i=
s not set=0A# CONFIG_SENSORS_LM80 is not set=0A# CONFIG_SENSORS_LM83 is not=
 set=0A# CONFIG_SENSORS_LM85 is not set=0A# CONFIG_SENSORS_LM87 is not set=
=0A# CONFIG_SENSORS_LM90 is not set=0A# CONFIG_SENSORS_LM92 is not set=0A# =
CONFIG_SENSORS_LM93 is not set=0A# CONFIG_SENSORS_LM95234 is not set=0A# CO=
NFIG_SENSORS_LM95241 is not set=0A# CONFIG_SENSORS_LM95245 is not set=0A# C=
ONFIG_SENSORS_PC87360 is not set=0A# CONFIG_SENSORS_PC87427 is not set=0A# =
CONFIG_SENSORS_NTC_THERMISTOR is not set=0A# CONFIG_SENSORS_NCT6683 is not =
set=0A# CONFIG_SENSORS_NCT6775 is not set=0A# CONFIG_SENSORS_NCT7802 is not=
 set=0A# CONFIG_SENSORS_NCT7904 is not set=0A# CONFIG_SENSORS_PCF8591 is no=
t set=0A# CONFIG_PMBUS is not set=0A# CONFIG_SENSORS_SHT21 is not set=0A# C=
ONFIG_SENSORS_SHTC1 is not set=0A# CONFIG_SENSORS_SIS5595 is not set=0A# CO=
NFIG_SENSORS_DME1737 is not set=0A# CONFIG_SENSORS_EMC1403 is not set=0A# C=
ONFIG_SENSORS_EMC2103 is not set=0A# CONFIG_SENSORS_EMC6W201 is not set=0A#=
 CONFIG_SENSORS_SMSC47M1 is not set=0A# CONFIG_SENSORS_SMSC47M192 is not se=
t=0A# CONFIG_SENSORS_SMSC47B397 is not set=0A# CONFIG_SENSORS_SCH56XX_COMMO=
N is not set=0A# CONFIG_SENSORS_SMM665 is not set=0A# CONFIG_SENSORS_ADC128=
D818 is not set=0A# CONFIG_SENSORS_ADS1015 is not set=0A# CONFIG_SENSORS_AD=
S7828 is not set=0A# CONFIG_SENSORS_AMC6821 is not set=0A# CONFIG_SENSORS_I=
NA209 is not set=0A# CONFIG_SENSORS_INA2XX is not set=0A# CONFIG_SENSORS_TC=
74 is not set=0A# CONFIG_SENSORS_THMC50 is not set=0A# CONFIG_SENSORS_TMP10=
2 is not set=0A# CONFIG_SENSORS_TMP103 is not set=0A# CONFIG_SENSORS_TMP401=
 is not set=0A# CONFIG_SENSORS_TMP421 is not set=0A# CONFIG_SENSORS_VIA_CPU=
TEMP is not set=0A# CONFIG_SENSORS_VIA686A is not set=0A# CONFIG_SENSORS_VT=
1211 is not set=0A# CONFIG_SENSORS_VT8231 is not set=0A# CONFIG_SENSORS_W83=
781D is not set=0A# CONFIG_SENSORS_W83791D is not set=0A# CONFIG_SENSORS_W8=
3792D is not set=0A# CONFIG_SENSORS_W83793 is not set=0A# CONFIG_SENSORS_W8=
3795 is not set=0A# CONFIG_SENSORS_W83L785TS is not set=0A# CONFIG_SENSORS_=
W83L786NG is not set=0A# CONFIG_SENSORS_W83627HF is not set=0A# CONFIG_SENS=
ORS_W83627EHF is not set=0A=0A#=0A# ACPI drivers=0A#=0A# CONFIG_SENSORS_ACP=
I_POWER is not set=0A# CONFIG_SENSORS_ATK0110 is not set=0ACONFIG_THERMAL=
=3Dy=0ACONFIG_THERMAL_HWMON=3Dy=0ACONFIG_THERMAL_WRITABLE_TRIPS=3Dy=0ACONFI=
G_THERMAL_DEFAULT_GOV_STEP_WISE=3Dy=0A# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHA=
RE is not set=0A# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set=0A# CONF=
IG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set=0ACONFIG_THERMAL_GOV_FAIR=
_SHARE=3Dy=0ACONFIG_THERMAL_GOV_STEP_WISE=3Dy=0ACONFIG_THERMAL_GOV_BANG_BAN=
G=3Dy=0ACONFIG_THERMAL_GOV_USER_SPACE=3Dy=0A# CONFIG_THERMAL_GOV_POWER_ALLO=
CATOR is not set=0A# CONFIG_THERMAL_EMULATION is not set=0A# CONFIG_INTEL_P=
OWERCLAMP is not set=0ACONFIG_INTEL_SOC_DTS_IOSF_CORE=3Dm=0ACONFIG_INTEL_SO=
C_DTS_THERMAL=3Dm=0ACONFIG_INT340X_THERMAL=3Dm=0ACONFIG_ACPI_THERMAL_REL=3D=
m=0A# CONFIG_INTEL_PCH_THERMAL is not set=0A# CONFIG_WATCHDOG is not set=0A=
CONFIG_SSB_POSSIBLE=3Dy=0A=0A#=0A# Sonics Silicon Backplane=0A#=0ACONFIG_SS=
B=3Dm=0ACONFIG_SSB_SPROM=3Dy=0ACONFIG_SSB_PCIHOST_POSSIBLE=3Dy=0ACONFIG_SSB=
_PCIHOST=3Dy=0A# CONFIG_SSB_B43_PCI_BRIDGE is not set=0ACONFIG_SSB_PCMCIAHO=
ST_POSSIBLE=3Dy=0ACONFIG_SSB_PCMCIAHOST=3Dy=0A# CONFIG_SSB_HOST_SOC is not =
set=0A# CONFIG_SSB_DEBUG is not set=0ACONFIG_SSB_DRIVER_PCICORE_POSSIBLE=3D=
y=0ACONFIG_SSB_DRIVER_PCICORE=3Dy=0ACONFIG_BCMA_POSSIBLE=3Dy=0A=0A#=0A# Bro=
adcom specific AMBA=0A#=0ACONFIG_BCMA=3Dm=0ACONFIG_BCMA_HOST_PCI_POSSIBLE=
=3Dy=0ACONFIG_BCMA_HOST_PCI=3Dy=0A# CONFIG_BCMA_HOST_SOC is not set=0ACONFI=
G_BCMA_DRIVER_PCI=3Dy=0ACONFIG_BCMA_DRIVER_GMAC_CMN=3Dy=0A# CONFIG_BCMA_DEB=
UG is not set=0A=0A#=0A# Multifunction device drivers=0A#=0ACONFIG_MFD_CORE=
=3Dm=0A# CONFIG_MFD_AS3711 is not set=0A# CONFIG_PMIC_ADP5520 is not set=0A=
# CONFIG_MFD_BCM590XX is not set=0A# CONFIG_MFD_AXP20X is not set=0A# CONFI=
G_MFD_CROS_EC is not set=0A# CONFIG_PMIC_DA903X is not set=0A# CONFIG_MFD_D=
A9052_I2C is not set=0A# CONFIG_MFD_DA9055 is not set=0A# CONFIG_MFD_DA9062=
 is not set=0A# CONFIG_MFD_DA9063 is not set=0A# CONFIG_MFD_DA9150 is not s=
et=0A# CONFIG_MFD_MC13XXX_I2C is not set=0A# CONFIG_HTC_PASIC3 is not set=
=0A# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set=0ACONFIG_LPC_ICH=3Dm=0ACONF=
IG_LPC_SCH=3Dm=0A# CONFIG_MFD_INTEL_LPSS_ACPI is not set=0A# CONFIG_MFD_INT=
EL_LPSS_PCI is not set=0A# CONFIG_MFD_JANZ_CMODIO is not set=0A# CONFIG_MFD=
_KEMPLD is not set=0A# CONFIG_MFD_88PM800 is not set=0A# CONFIG_MFD_88PM805=
 is not set=0A# CONFIG_MFD_88PM860X is not set=0A# CONFIG_MFD_MAX14577 is n=
ot set=0A# CONFIG_MFD_MAX77693 is not set=0A# CONFIG_MFD_MAX77843 is not se=
t=0A# CONFIG_MFD_MAX8907 is not set=0A# CONFIG_MFD_MAX8925 is not set=0A# C=
ONFIG_MFD_MAX8997 is not set=0A# CONFIG_MFD_MAX8998 is not set=0A# CONFIG_M=
FD_MT6397 is not set=0A# CONFIG_MFD_MENF21BMC is not set=0A# CONFIG_MFD_RET=
U is not set=0A# CONFIG_MFD_PCF50633 is not set=0A# CONFIG_MFD_RDC321X is n=
ot set=0ACONFIG_MFD_RTSX_PCI=3Dm=0A# CONFIG_MFD_RT5033 is not set=0A# CONFI=
G_MFD_RC5T583 is not set=0A# CONFIG_MFD_RN5T618 is not set=0A# CONFIG_MFD_S=
EC_CORE is not set=0A# CONFIG_MFD_SI476X_CORE is not set=0ACONFIG_MFD_SM501=
=3Dm=0A# CONFIG_MFD_SKY81452 is not set=0A# CONFIG_MFD_SMSC is not set=0A# =
CONFIG_ABX500_CORE is not set=0A# CONFIG_MFD_SYSCON is not set=0A# CONFIG_M=
FD_TI_AM335X_TSCADC is not set=0A# CONFIG_MFD_LP3943 is not set=0A# CONFIG_=
MFD_LP8788 is not set=0A# CONFIG_MFD_PALMAS is not set=0A# CONFIG_TPS6105X =
is not set=0A# CONFIG_TPS6507X is not set=0A# CONFIG_MFD_TPS65090 is not se=
t=0A# CONFIG_MFD_TPS65217 is not set=0A# CONFIG_MFD_TPS65218 is not set=0A#=
 CONFIG_MFD_TPS6586X is not set=0A# CONFIG_MFD_TPS80031 is not set=0A# CONF=
IG_TWL4030_CORE is not set=0A# CONFIG_TWL6040_CORE is not set=0ACONFIG_MFD_=
WL1273_CORE=3Dm=0A# CONFIG_MFD_LM3533 is not set=0A# CONFIG_MFD_TMIO is not=
 set=0ACONFIG_MFD_VX855=3Dm=0A# CONFIG_MFD_ARIZONA_I2C is not set=0A# CONFI=
G_MFD_WM8400 is not set=0A# CONFIG_MFD_WM831X_I2C is not set=0A# CONFIG_MFD=
_WM8350_I2C is not set=0A# CONFIG_MFD_WM8994 is not set=0A# CONFIG_REGULATO=
R is not set=0A# CONFIG_MEDIA_SUPPORT is not set=0A=0A#=0A# Graphics suppor=
t=0A#=0A# CONFIG_AGP is not set=0ACONFIG_INTEL_GTT=3Dm=0ACONFIG_VGA_ARB=3Dy=
=0ACONFIG_VGA_ARB_MAX_GPUS=3D16=0ACONFIG_VGA_SWITCHEROO=3Dy=0ACONFIG_DRM=3D=
m=0ACONFIG_DRM_MIPI_DSI=3Dy=0ACONFIG_DRM_KMS_HELPER=3Dm=0ACONFIG_DRM_KMS_FB=
_HELPER=3Dy=0ACONFIG_DRM_FBDEV_EMULATION=3Dy=0ACONFIG_DRM_LOAD_EDID_FIRMWAR=
E=3Dy=0ACONFIG_DRM_TTM=3Dm=0A=0A#=0A# I2C encoder or helper chips=0A#=0A# C=
ONFIG_DRM_I2C_ADV7511 is not set=0ACONFIG_DRM_I2C_CH7006=3Dm=0ACONFIG_DRM_I=
2C_SIL164=3Dm=0ACONFIG_DRM_I2C_NXP_TDA998X=3Dm=0A# CONFIG_DRM_TDFX is not s=
et=0A# CONFIG_DRM_R128 is not set=0ACONFIG_DRM_RADEON=3Dm=0A# CONFIG_DRM_RA=
DEON_USERPTR is not set=0A# CONFIG_DRM_RADEON_UMS is not set=0A# CONFIG_DRM=
_AMDGPU is not set=0ACONFIG_DRM_NOUVEAU=3Dm=0ACONFIG_NOUVEAU_DEBUG=3D5=0ACO=
NFIG_NOUVEAU_DEBUG_DEFAULT=3D3=0ACONFIG_DRM_NOUVEAU_BACKLIGHT=3Dy=0ACONFIG_=
DRM_I915=3Dm=0A# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set=0A# CONF=
IG_DRM_MGA is not set=0ACONFIG_DRM_VIA=3Dm=0A# CONFIG_DRM_SAVAGE is not set=
=0A# CONFIG_DRM_VGEM is not set=0ACONFIG_DRM_VMWGFX=3Dm=0ACONFIG_DRM_VMWGFX=
_FBCON=3Dy=0ACONFIG_DRM_GMA500=3Dm=0A# CONFIG_DRM_GMA600 is not set=0ACONFI=
G_DRM_GMA3600=3Dy=0ACONFIG_DRM_AST=3Dm=0ACONFIG_DRM_MGAG200=3Dm=0ACONFIG_DR=
M_CIRRUS_QEMU=3Dm=0ACONFIG_DRM_QXL=3Dm=0ACONFIG_DRM_BOCHS=3Dm=0A# CONFIG_DR=
M_VIRTIO_GPU is not set=0ACONFIG_DRM_PANEL=3Dy=0A=0A#=0A# Display Panels=0A=
#=0ACONFIG_DRM_BRIDGE=3Dy=0A=0A#=0A# Display Interface Bridges=0A#=0A# CONF=
IG_HSA_AMD is not set=0A=0A#=0A# Frame buffer Devices=0A#=0ACONFIG_FB=3Dy=
=0A# CONFIG_FIRMWARE_EDID is not set=0ACONFIG_FB_CMDLINE=3Dy=0A# CONFIG_FB_=
DDC is not set=0ACONFIG_FB_BOOT_VESA_SUPPORT=3Dy=0ACONFIG_FB_CFB_FILLRECT=
=3Dy=0ACONFIG_FB_CFB_COPYAREA=3Dy=0ACONFIG_FB_CFB_IMAGEBLIT=3Dy=0A# CONFIG_=
FB_CFB_REV_PIXELS_IN_BYTE is not set=0ACONFIG_FB_SYS_FILLRECT=3Dy=0ACONFIG_=
FB_SYS_COPYAREA=3Dy=0ACONFIG_FB_SYS_IMAGEBLIT=3Dy=0A# CONFIG_FB_FOREIGN_END=
IAN is not set=0ACONFIG_FB_SYS_FOPS=3Dy=0ACONFIG_FB_DEFERRED_IO=3Dy=0A# CON=
FIG_FB_SVGALIB is not set=0A# CONFIG_FB_MACMODES is not set=0ACONFIG_FB_BAC=
KLIGHT=3Dy=0A# CONFIG_FB_MODE_HELPERS is not set=0ACONFIG_FB_TILEBLITTING=
=3Dy=0A=0A#=0A# Frame buffer hardware drivers=0A#=0A# CONFIG_FB_CIRRUS is n=
ot set=0A# CONFIG_FB_PM2 is not set=0A# CONFIG_FB_CYBER2000 is not set=0A# =
CONFIG_FB_ARC is not set=0A# CONFIG_FB_ASILIANT is not set=0A# CONFIG_FB_IM=
STT is not set=0ACONFIG_FB_VGA16=3Dm=0A# CONFIG_FB_UVESA is not set=0ACONFI=
G_FB_VESA=3Dy=0ACONFIG_FB_EFI=3Dy=0A# CONFIG_FB_N411 is not set=0A# CONFIG_=
FB_HGA is not set=0A# CONFIG_FB_OPENCORES is not set=0A# CONFIG_FB_S1D13XXX=
 is not set=0A# CONFIG_FB_NVIDIA is not set=0A# CONFIG_FB_RIVA is not set=
=0A# CONFIG_FB_I740 is not set=0A# CONFIG_FB_LE80578 is not set=0A# CONFIG_=
FB_MATROX is not set=0A# CONFIG_FB_RADEON is not set=0A# CONFIG_FB_ATY128 i=
s not set=0A# CONFIG_FB_ATY is not set=0A# CONFIG_FB_S3 is not set=0A# CONF=
IG_FB_SAVAGE is not set=0A# CONFIG_FB_SIS is not set=0A# CONFIG_FB_NEOMAGIC=
 is not set=0A# CONFIG_FB_KYRO is not set=0A# CONFIG_FB_3DFX is not set=0A#=
 CONFIG_FB_VOODOO1 is not set=0A# CONFIG_FB_VT8623 is not set=0A# CONFIG_FB=
_TRIDENT is not set=0A# CONFIG_FB_ARK is not set=0A# CONFIG_FB_PM3 is not s=
et=0A# CONFIG_FB_CARMINE is not set=0A# CONFIG_FB_SM501 is not set=0A# CONF=
IG_FB_IBM_GXT4500 is not set=0ACONFIG_FB_VIRTUAL=3Dm=0ACONFIG_XEN_FBDEV_FRO=
NTEND=3Dy=0A# CONFIG_FB_METRONOME is not set=0A# CONFIG_FB_MB862XX is not s=
et=0A# CONFIG_FB_BROADSHEET is not set=0A# CONFIG_FB_AUO_K190X is not set=
=0ACONFIG_FB_HYPERV=3Dm=0A# CONFIG_FB_SIMPLE is not set=0A# CONFIG_FB_SM712=
 is not set=0ACONFIG_BACKLIGHT_LCD_SUPPORT=3Dy=0ACONFIG_LCD_CLASS_DEVICE=3D=
m=0ACONFIG_LCD_PLATFORM=3Dm=0ACONFIG_BACKLIGHT_CLASS_DEVICE=3Dy=0A# CONFIG_=
BACKLIGHT_GENERIC is not set=0ACONFIG_BACKLIGHT_APPLE=3Dm=0A# CONFIG_BACKLI=
GHT_PM8941_WLED is not set=0A# CONFIG_BACKLIGHT_SAHARA is not set=0A# CONFI=
G_BACKLIGHT_ADP8860 is not set=0A# CONFIG_BACKLIGHT_ADP8870 is not set=0A# =
CONFIG_BACKLIGHT_LM3639 is not set=0A# CONFIG_BACKLIGHT_LV5207LP is not set=
=0A# CONFIG_BACKLIGHT_BD6107 is not set=0ACONFIG_VGASTATE=3Dm=0ACONFIG_HDMI=
=3Dy=0A=0A#=0A# Console display driver support=0A#=0ACONFIG_VGA_CONSOLE=3Dy=
=0ACONFIG_VGACON_SOFT_SCROLLBACK=3Dy=0ACONFIG_VGACON_SOFT_SCROLLBACK_SIZE=
=3D64=0ACONFIG_DUMMY_CONSOLE=3Dy=0ACONFIG_DUMMY_CONSOLE_COLUMNS=3D80=0ACONF=
IG_DUMMY_CONSOLE_ROWS=3D25=0ACONFIG_FRAMEBUFFER_CONSOLE=3Dy=0ACONFIG_FRAMEB=
UFFER_CONSOLE_DETECT_PRIMARY=3Dy=0ACONFIG_FRAMEBUFFER_CONSOLE_ROTATION=3Dy=
=0ACONFIG_LOGO=3Dy=0A# CONFIG_LOGO_LINUX_MONO is not set=0A# CONFIG_LOGO_LI=
NUX_VGA16 is not set=0ACONFIG_LOGO_LINUX_CLUT224=3Dy=0A# CONFIG_SOUND is no=
t set=0A=0A#=0A# HID support=0A#=0ACONFIG_HID=3Dy=0ACONFIG_HID_BATTERY_STRE=
NGTH=3Dy=0ACONFIG_HIDRAW=3Dy=0ACONFIG_UHID=3Dm=0ACONFIG_HID_GENERIC=3Dy=0A=
=0A#=0A# Special HID drivers=0A#=0A# CONFIG_HID_A4TECH is not set=0A# CONFI=
G_HID_ACRUX is not set=0A# CONFIG_HID_APPLE is not set=0A# CONFIG_HID_AUREA=
L is not set=0A# CONFIG_HID_BELKIN is not set=0A# CONFIG_HID_CHERRY is not =
set=0A# CONFIG_HID_CHICONY is not set=0A# CONFIG_HID_CYPRESS is not set=0A#=
 CONFIG_HID_DRAGONRISE is not set=0A# CONFIG_HID_EMS_FF is not set=0A# CONF=
IG_HID_ELECOM is not set=0A# CONFIG_HID_EZKEY is not set=0A# CONFIG_HID_GEM=
BIRD is not set=0A# CONFIG_HID_GFRM is not set=0A# CONFIG_HID_KEYTOUCH is n=
ot set=0A# CONFIG_HID_KYE is not set=0A# CONFIG_HID_WALTOP is not set=0A# C=
ONFIG_HID_GYRATION is not set=0A# CONFIG_HID_ICADE is not set=0A# CONFIG_HI=
D_TWINHAN is not set=0A# CONFIG_HID_KENSINGTON is not set=0A# CONFIG_HID_LC=
POWER is not set=0A# CONFIG_HID_LENOVO is not set=0A# CONFIG_HID_LOGITECH i=
s not set=0A# CONFIG_HID_MAGICMOUSE is not set=0A# CONFIG_HID_MICROSOFT is =
not set=0A# CONFIG_HID_MONTEREY is not set=0A# CONFIG_HID_MULTITOUCH is not=
 set=0A# CONFIG_HID_ORTEK is not set=0A# CONFIG_HID_PANTHERLORD is not set=
=0A# CONFIG_HID_PETALYNX is not set=0A# CONFIG_HID_PICOLCD is not set=0A# C=
ONFIG_HID_PLANTRONICS is not set=0A# CONFIG_HID_PRIMAX is not set=0A# CONFI=
G_HID_SAITEK is not set=0A# CONFIG_HID_SAMSUNG is not set=0A# CONFIG_HID_SP=
EEDLINK is not set=0A# CONFIG_HID_STEELSERIES is not set=0A# CONFIG_HID_SUN=
PLUS is not set=0A# CONFIG_HID_RMI is not set=0A# CONFIG_HID_GREENASIA is n=
ot set=0A# CONFIG_HID_HYPERV_MOUSE is not set=0A# CONFIG_HID_SMARTJOYPLUS i=
s not set=0A# CONFIG_HID_TIVO is not set=0A# CONFIG_HID_TOPSEED is not set=
=0A# CONFIG_HID_THINGM is not set=0A# CONFIG_HID_THRUSTMASTER is not set=0A=
# CONFIG_HID_WACOM is not set=0A# CONFIG_HID_WIIMOTE is not set=0A# CONFIG_=
HID_XINMO is not set=0A# CONFIG_HID_ZEROPLUS is not set=0A# CONFIG_HID_ZYDA=
CRON is not set=0A# CONFIG_HID_SENSOR_HUB is not set=0A=0A#=0A# I2C HID sup=
port=0A#=0ACONFIG_I2C_HID=3Dm=0ACONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy=0A# CONFI=
G_USB_SUPPORT is not set=0A# CONFIG_UWB is not set=0A# CONFIG_MMC is not se=
t=0A# CONFIG_MEMSTICK is not set=0ACONFIG_NEW_LEDS=3Dy=0ACONFIG_LEDS_CLASS=
=3Dy=0A# CONFIG_LEDS_CLASS_FLASH is not set=0A=0A#=0A# LED drivers=0A#=0A# =
CONFIG_LEDS_LM3530 is not set=0A# CONFIG_LEDS_LM3642 is not set=0A# CONFIG_=
LEDS_PCA9532 is not set=0A# CONFIG_LEDS_LP3944 is not set=0A# CONFIG_LEDS_L=
P5521 is not set=0A# CONFIG_LEDS_LP5523 is not set=0A# CONFIG_LEDS_LP5562 i=
s not set=0A# CONFIG_LEDS_LP8501 is not set=0A# CONFIG_LEDS_LP8860 is not s=
et=0A# CONFIG_LEDS_CLEVO_MAIL is not set=0A# CONFIG_LEDS_PCA955X is not set=
=0A# CONFIG_LEDS_PCA963X is not set=0A# CONFIG_LEDS_BD2802 is not set=0A# C=
ONFIG_LEDS_INTEL_SS4200 is not set=0A# CONFIG_LEDS_DELL_NETBOOKS is not set=
=0A# CONFIG_LEDS_TCA6507 is not set=0A# CONFIG_LEDS_TLC591XX is not set=0A#=
 CONFIG_LEDS_LM355x is not set=0A=0A#=0A# LED driver for blink(1) USB RGB L=
ED is under Special HID drivers (HID_THINGM)=0A#=0A# CONFIG_LEDS_BLINKM is =
not set=0A=0A#=0A# LED Triggers=0A#=0ACONFIG_LEDS_TRIGGERS=3Dy=0A# CONFIG_L=
EDS_TRIGGER_TIMER is not set=0A# CONFIG_LEDS_TRIGGER_ONESHOT is not set=0A#=
 CONFIG_LEDS_TRIGGER_HEARTBEAT is not set=0A# CONFIG_LEDS_TRIGGER_BACKLIGHT=
 is not set=0A# CONFIG_LEDS_TRIGGER_CPU is not set=0A# CONFIG_LEDS_TRIGGER_=
DEFAULT_ON is not set=0A=0A#=0A# iptables trigger is under Netfilter config=
 (LED target)=0A#=0A# CONFIG_LEDS_TRIGGER_TRANSIENT is not set=0A# CONFIG_L=
EDS_TRIGGER_CAMERA is not set=0A# CONFIG_ACCESSIBILITY is not set=0A# CONFI=
G_INFINIBAND is not set=0ACONFIG_EDAC_ATOMIC_SCRUB=3Dy=0ACONFIG_EDAC_SUPPOR=
T=3Dy=0A# CONFIG_EDAC is not set=0ACONFIG_RTC_LIB=3Dy=0ACONFIG_RTC_CLASS=3D=
y=0ACONFIG_RTC_HCTOSYS=3Dy=0ACONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"=0A# CONFIG_=
RTC_SYSTOHC is not set=0A# CONFIG_RTC_DEBUG is not set=0A=0A#=0A# RTC inter=
faces=0A#=0ACONFIG_RTC_INTF_SYSFS=3Dy=0ACONFIG_RTC_INTF_PROC=3Dy=0ACONFIG_R=
TC_INTF_DEV=3Dy=0A# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set=0A# CONFIG_RTC_=
DRV_TEST is not set=0A=0A#=0A# I2C RTC drivers=0A#=0A# CONFIG_RTC_DRV_ABB5Z=
ES3 is not set=0A# CONFIG_RTC_DRV_ABX80X is not set=0ACONFIG_RTC_DRV_DS1307=
=3Dm=0ACONFIG_RTC_DRV_DS1374=3Dm=0A# CONFIG_RTC_DRV_DS1374_WDT is not set=
=0ACONFIG_RTC_DRV_DS1672=3Dm=0ACONFIG_RTC_DRV_DS3232=3Dm=0ACONFIG_RTC_DRV_M=
AX6900=3Dm=0ACONFIG_RTC_DRV_RS5C372=3Dm=0ACONFIG_RTC_DRV_ISL1208=3Dm=0ACONF=
IG_RTC_DRV_ISL12022=3Dm=0A# CONFIG_RTC_DRV_ISL12057 is not set=0ACONFIG_RTC=
_DRV_X1205=3Dm=0ACONFIG_RTC_DRV_PCF2127=3Dm=0ACONFIG_RTC_DRV_PCF8523=3Dm=0A=
CONFIG_RTC_DRV_PCF8563=3Dm=0ACONFIG_RTC_DRV_PCF85063=3Dm=0ACONFIG_RTC_DRV_P=
CF8583=3Dm=0ACONFIG_RTC_DRV_M41T80=3Dm=0ACONFIG_RTC_DRV_M41T80_WDT=3Dy=0ACO=
NFIG_RTC_DRV_BQ32K=3Dm=0A# CONFIG_RTC_DRV_S35390A is not set=0ACONFIG_RTC_D=
RV_FM3130=3Dm=0ACONFIG_RTC_DRV_RX8581=3Dm=0ACONFIG_RTC_DRV_RX8025=3Dm=0ACON=
FIG_RTC_DRV_EM3027=3Dm=0ACONFIG_RTC_DRV_RV3029C2=3Dm=0A# CONFIG_RTC_DRV_RV8=
803 is not set=0A=0A#=0A# SPI RTC drivers=0A#=0A=0A#=0A# Platform RTC drive=
rs=0A#=0ACONFIG_RTC_DRV_CMOS=3Dy=0ACONFIG_RTC_DRV_DS1286=3Dm=0ACONFIG_RTC_D=
RV_DS1511=3Dm=0ACONFIG_RTC_DRV_DS1553=3Dm=0A# CONFIG_RTC_DRV_DS1685_FAMILY =
is not set=0ACONFIG_RTC_DRV_DS1742=3Dm=0ACONFIG_RTC_DRV_DS2404=3Dm=0ACONFIG=
_RTC_DRV_STK17TA8=3Dm=0A# CONFIG_RTC_DRV_M48T86 is not set=0ACONFIG_RTC_DRV=
_M48T35=3Dm=0ACONFIG_RTC_DRV_M48T59=3Dm=0ACONFIG_RTC_DRV_MSM6242=3Dm=0ACONF=
IG_RTC_DRV_BQ4802=3Dm=0ACONFIG_RTC_DRV_RP5C01=3Dm=0ACONFIG_RTC_DRV_V3020=3D=
m=0A=0A#=0A# on-CPU RTC drivers=0A#=0A=0A#=0A# HID Sensor RTC drivers=0A#=
=0ACONFIG_DMADEVICES=3Dy=0A# CONFIG_DMADEVICES_DEBUG is not set=0A=0A#=0A# =
DMA Devices=0A#=0ACONFIG_DMA_ENGINE=3Dy=0ACONFIG_DMA_VIRTUAL_CHANNELS=3Dy=
=0ACONFIG_DMA_ACPI=3Dy=0ACONFIG_INTEL_IDMA64=3Dy=0ACONFIG_INTEL_IOATDMA=3Dm=
=0ACONFIG_INTEL_MIC_X100_DMA=3Dm=0ACONFIG_DW_DMAC_CORE=3Dm=0ACONFIG_DW_DMAC=
=3Dm=0ACONFIG_DW_DMAC_PCI=3Dm=0A=0A#=0A# DMA Clients=0A#=0ACONFIG_ASYNC_TX_=
DMA=3Dy=0A# CONFIG_DMATEST is not set=0ACONFIG_DMA_ENGINE_RAID=3Dy=0ACONFIG=
_DCA=3Dm=0ACONFIG_AUXDISPLAY=3Dy=0ACONFIG_UIO=3Dm=0ACONFIG_UIO_CIF=3Dm=0A# =
CONFIG_UIO_PDRV_GENIRQ is not set=0A# CONFIG_UIO_DMEM_GENIRQ is not set=0AC=
ONFIG_UIO_AEC=3Dm=0ACONFIG_UIO_SERCOS3=3Dm=0ACONFIG_UIO_PCI_GENERIC=3Dm=0A#=
 CONFIG_UIO_NETX is not set=0A# CONFIG_UIO_PRUSS is not set=0A# CONFIG_UIO_=
MF624 is not set=0ACONFIG_VFIO_IOMMU_TYPE1=3Dm=0ACONFIG_VFIO_VIRQFD=3Dm=0AC=
ONFIG_VFIO=3Dm=0ACONFIG_VFIO_PCI=3Dm=0ACONFIG_VFIO_PCI_VGA=3Dy=0ACONFIG_VFI=
O_PCI_MMAP=3Dy=0ACONFIG_VFIO_PCI_INTX=3Dy=0ACONFIG_IRQ_BYPASS_MANAGER=3Dm=
=0A# CONFIG_VIRT_DRIVERS is not set=0ACONFIG_VIRTIO=3Dm=0A=0A#=0A# Virtio d=
rivers=0A#=0ACONFIG_VIRTIO_PCI=3Dm=0ACONFIG_VIRTIO_PCI_LEGACY=3Dy=0ACONFIG_=
VIRTIO_BALLOON=3Dm=0A# CONFIG_VIRTIO_INPUT is not set=0ACONFIG_VIRTIO_MMIO=
=3Dm=0A# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set=0A=0A#=0A# Microsoft=
 Hyper-V guest support=0A#=0ACONFIG_HYPERV=3Dm=0ACONFIG_HYPERV_UTILS=3Dm=0A=
CONFIG_HYPERV_BALLOON=3Dm=0A=0A#=0A# Xen driver support=0A#=0ACONFIG_XEN_BA=
LLOON=3Dy=0ACONFIG_XEN_SELFBALLOONING=3Dy=0ACONFIG_XEN_BALLOON_MEMORY_HOTPL=
UG=3Dy=0ACONFIG_XEN_BALLOON_MEMORY_HOTPLUG_LIMIT=3D512=0ACONFIG_XEN_SCRUB_P=
AGES=3Dy=0ACONFIG_XEN_DEV_EVTCHN=3Dy=0ACONFIG_XEN_BACKEND=3Dy=0ACONFIG_XENF=
S=3Dy=0ACONFIG_XEN_COMPAT_XENFS=3Dy=0ACONFIG_XEN_SYS_HYPERVISOR=3Dy=0ACONFI=
G_XEN_XENBUS_FRONTEND=3Dy=0ACONFIG_XEN_GNTDEV=3Dy=0ACONFIG_XEN_GRANT_DEV_AL=
LOC=3Dy=0ACONFIG_SWIOTLB_XEN=3Dy=0ACONFIG_XEN_TMEM=3Dm=0A# CONFIG_XEN_PCIDE=
V_BACKEND is not set=0A# CONFIG_XEN_SCSI_BACKEND is not set=0ACONFIG_XEN_PR=
IVCMD=3Dy=0A# CONFIG_XEN_ACPI_PROCESSOR is not set=0ACONFIG_XEN_HAVE_PVMMU=
=3Dy=0ACONFIG_XEN_EFI=3Dy=0ACONFIG_XEN_AUTO_XLATE=3Dy=0ACONFIG_XEN_ACPI=3Dy=
=0ACONFIG_XEN_SYMS=3Dy=0ACONFIG_XEN_HAVE_VPMU=3Dy=0A# CONFIG_STAGING is not=
 set=0ACONFIG_X86_PLATFORM_DEVICES=3Dy=0ACONFIG_ACER_WMI=3Dm=0ACONFIG_ACERH=
DF=3Dm=0ACONFIG_ALIENWARE_WMI=3Dm=0ACONFIG_ASUS_LAPTOP=3Dm=0ACONFIG_DELL_LA=
PTOP=3Dm=0ACONFIG_DELL_WMI=3Dm=0ACONFIG_DELL_WMI_AIO=3Dm=0ACONFIG_DELL_SMO8=
800=3Dm=0ACONFIG_FUJITSU_LAPTOP=3Dm=0A# CONFIG_FUJITSU_LAPTOP_DEBUG is not =
set=0ACONFIG_FUJITSU_TABLET=3Dm=0ACONFIG_HP_ACCEL=3Dm=0ACONFIG_HP_WIRELESS=
=3Dm=0ACONFIG_HP_WMI=3Dm=0ACONFIG_PANASONIC_LAPTOP=3Dm=0ACONFIG_THINKPAD_AC=
PI=3Dm=0A# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set=0A# CONFIG_THINK=
PAD_ACPI_DEBUG is not set=0A# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set=
=0ACONFIG_THINKPAD_ACPI_VIDEO=3Dy=0ACONFIG_THINKPAD_ACPI_HOTKEY_POLL=3Dy=0A=
CONFIG_SENSORS_HDAPS=3Dm=0A# CONFIG_INTEL_MENLOW is not set=0ACONFIG_EEEPC_=
LAPTOP=3Dm=0ACONFIG_ASUS_WMI=3Dm=0ACONFIG_ASUS_NB_WMI=3Dm=0ACONFIG_EEEPC_WM=
I=3Dm=0ACONFIG_ACPI_WMI=3Dm=0ACONFIG_MSI_WMI=3Dm=0ACONFIG_TOPSTAR_LAPTOP=3D=
m=0ACONFIG_ACPI_TOSHIBA=3Dm=0ACONFIG_TOSHIBA_BT_RFKILL=3Dm=0ACONFIG_TOSHIBA=
_HAPS=3Dm=0A# CONFIG_TOSHIBA_WMI is not set=0ACONFIG_ACPI_CMPC=3Dm=0ACONFIG=
_INTEL_IPS=3Dm=0A# CONFIG_IBM_RTL is not set=0ACONFIG_SAMSUNG_LAPTOP=3Dm=0A=
CONFIG_MXM_WMI=3Dm=0ACONFIG_SAMSUNG_Q10=3Dm=0ACONFIG_APPLE_GMUX=3Dm=0ACONFI=
G_INTEL_RST=3Dm=0ACONFIG_INTEL_SMARTCONNECT=3Dy=0ACONFIG_PVPANIC=3Dm=0A# CO=
NFIG_INTEL_PMC_IPC is not set=0A# CONFIG_SURFACE_PRO3_BUTTON is not set=0A#=
 CONFIG_CHROME_PLATFORMS is not set=0ACONFIG_CLKDEV_LOOKUP=3Dy=0ACONFIG_HAV=
E_CLK_PREPARE=3Dy=0ACONFIG_COMMON_CLK=3Dy=0A=0A#=0A# Common Clock Framework=
=0A#=0A# CONFIG_COMMON_CLK_SI5351 is not set=0A# CONFIG_COMMON_CLK_PXA is n=
ot set=0A# CONFIG_COMMON_CLK_CDCE706 is not set=0A=0A#=0A# Hardware Spinloc=
k drivers=0A#=0A=0A#=0A# Clock Source drivers=0A#=0ACONFIG_CLKEVT_I8253=3Dy=
=0ACONFIG_I8253_LOCK=3Dy=0ACONFIG_CLKBLD_I8253=3Dy=0A# CONFIG_ATMEL_PIT is =
not set=0A# CONFIG_SH_TIMER_CMT is not set=0A# CONFIG_SH_TIMER_MTU2 is not =
set=0A# CONFIG_SH_TIMER_TMU is not set=0A# CONFIG_EM_TIMER_STI is not set=
=0A# CONFIG_MAILBOX is not set=0ACONFIG_IOMMU_API=3Dy=0ACONFIG_IOMMU_SUPPOR=
T=3Dy=0A=0A#=0A# Generic IOMMU Pagetable Support=0A#=0ACONFIG_IOMMU_IOVA=3D=
y=0ACONFIG_AMD_IOMMU=3Dy=0ACONFIG_AMD_IOMMU_STATS=3Dy=0ACONFIG_AMD_IOMMU_V2=
=3Dm=0ACONFIG_DMAR_TABLE=3Dy=0ACONFIG_INTEL_IOMMU=3Dy=0A# CONFIG_INTEL_IOMM=
U_SVM is not set=0A# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set=0ACONFIG_INTE=
L_IOMMU_FLOPPY_WA=3Dy=0ACONFIG_IRQ_REMAP=3Dy=0A=0A#=0A# Remoteproc drivers=
=0A#=0A# CONFIG_STE_MODEM_RPROC is not set=0A=0A#=0A# Rpmsg drivers=0A#=0A=
=0A#=0A# SOC (System On Chip) specific Drivers=0A#=0A# CONFIG_SUNXI_SRAM is=
 not set=0A# CONFIG_SOC_TI is not set=0ACONFIG_PM_DEVFREQ=3Dy=0A=0A#=0A# DE=
VFREQ Governors=0A#=0ACONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=3Dm=0A# CONFIG_DEV=
FREQ_GOV_PERFORMANCE is not set=0A# CONFIG_DEVFREQ_GOV_POWERSAVE is not set=
=0A# CONFIG_DEVFREQ_GOV_USERSPACE is not set=0A=0A#=0A# DEVFREQ Drivers=0A#=
=0A# CONFIG_PM_DEVFREQ_EVENT is not set=0A# CONFIG_EXTCON is not set=0A# CO=
NFIG_MEMORY is not set=0A# CONFIG_IIO is not set=0ACONFIG_NTB=3Dm=0A# CONFI=
G_NTB_INTEL is not set=0A# CONFIG_NTB_PINGPONG is not set=0A# CONFIG_NTB_TO=
OL is not set=0A# CONFIG_NTB_TRANSPORT is not set=0A# CONFIG_VME_BUS is not=
 set=0A# CONFIG_PWM is not set=0A# CONFIG_IPACK_BUS is not set=0ACONFIG_RES=
ET_CONTROLLER=3Dy=0A# CONFIG_FMC is not set=0A=0A#=0A# PHY Subsystem=0A#=0A=
CONFIG_GENERIC_PHY=3Dy=0A# CONFIG_PHY_PXA_28NM_HSIC is not set=0A# CONFIG_P=
HY_PXA_28NM_USB2 is not set=0A# CONFIG_BCM_KONA_USB2_PHY is not set=0ACONFI=
G_POWERCAP=3Dy=0ACONFIG_INTEL_RAPL=3Dm=0A# CONFIG_MCB is not set=0A=0A#=0A#=
 Performance monitor support=0A#=0ACONFIG_RAS=3Dy=0A# CONFIG_THUNDERBOLT is=
 not set=0A=0A#=0A# Android=0A#=0A# CONFIG_ANDROID is not set=0A# CONFIG_LI=
BNVDIMM is not set=0A# CONFIG_NVMEM is not set=0A# CONFIG_STM is not set=0A=
# CONFIG_STM_DUMMY is not set=0A# CONFIG_STM_SOURCE_CONSOLE is not set=0A# =
CONFIG_INTEL_TH is not set=0A=0A#=0A# FPGA Configuration Support=0A#=0A# CO=
NFIG_FPGA is not set=0A=0A#=0A# Firmware Drivers=0A#=0ACONFIG_EDD=3Dm=0A# C=
ONFIG_EDD_OFF is not set=0ACONFIG_FIRMWARE_MEMMAP=3Dy=0A# CONFIG_DELL_RBU i=
s not set=0ACONFIG_DCDBAS=3Dm=0ACONFIG_DMIID=3Dy=0ACONFIG_DMI_SYSFS=3Dy=0AC=
ONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=3Dy=0ACONFIG_ISCSI_IBFT_FIND=3Dy=0A=
# CONFIG_GOOGLE_FIRMWARE is not set=0A=0A#=0A# EFI (Extensible Firmware Int=
erface) Support=0A#=0ACONFIG_EFI_VARS=3Dy=0ACONFIG_EFI_ESRT=3Dy=0ACONFIG_EF=
I_VARS_PSTORE=3Dy=0ACONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=3Dy=0ACONFIG_EFI=
_RUNTIME_MAP=3Dy=0A# CONFIG_EFI_FAKE_MEMMAP is not set=0ACONFIG_EFI_RUNTIME=
_WRAPPERS=3Dy=0ACONFIG_UEFI_CPER=3Dy=0A=0A#=0A# File systems=0A#=0ACONFIG_D=
CACHE_WORD_ACCESS=3Dy=0A# CONFIG_EXT2_FS is not set=0A# CONFIG_EXT3_FS is n=
ot set=0ACONFIG_EXT4_FS=3Dy=0ACONFIG_EXT4_USE_FOR_EXT2=3Dy=0ACONFIG_EXT4_FS=
_POSIX_ACL=3Dy=0ACONFIG_EXT4_FS_SECURITY=3Dy=0A# CONFIG_EXT4_ENCRYPTION is =
not set=0A# CONFIG_EXT4_DEBUG is not set=0ACONFIG_JBD2=3Dy=0A# CONFIG_JBD2_=
DEBUG is not set=0ACONFIG_FS_MBCACHE=3Dy=0A# CONFIG_REISERFS_FS is not set=
=0A# CONFIG_JFS_FS is not set=0A# CONFIG_XFS_FS is not set=0A# CONFIG_GFS2_=
FS is not set=0A# CONFIG_OCFS2_FS is not set=0A# CONFIG_BTRFS_FS is not set=
=0A# CONFIG_NILFS2_FS is not set=0A# CONFIG_F2FS_FS is not set=0A# CONFIG_F=
S_DAX is not set=0ACONFIG_FS_POSIX_ACL=3Dy=0ACONFIG_EXPORTFS=3Dy=0ACONFIG_F=
ILE_LOCKING=3Dy=0ACONFIG_FSNOTIFY=3Dy=0ACONFIG_DNOTIFY=3Dy=0ACONFIG_INOTIFY=
_USER=3Dy=0ACONFIG_FANOTIFY=3Dy=0ACONFIG_FANOTIFY_ACCESS_PERMISSIONS=3Dy=0A=
CONFIG_QUOTA=3Dy=0ACONFIG_QUOTA_NETLINK_INTERFACE=3Dy=0A# CONFIG_PRINT_QUOT=
A_WARNING is not set=0A# CONFIG_QUOTA_DEBUG is not set=0ACONFIG_QUOTA_TREE=
=3Dy=0A# CONFIG_QFMT_V1 is not set=0ACONFIG_QFMT_V2=3Dy=0ACONFIG_QUOTACTL=
=3Dy=0ACONFIG_QUOTACTL_COMPAT=3Dy=0ACONFIG_AUTOFS4_FS=3Dy=0ACONFIG_FUSE_FS=
=3Dm=0ACONFIG_CUSE=3Dm=0ACONFIG_OVERLAY_FS=3Dm=0A=0A#=0A# Caches=0A#=0ACONF=
IG_FSCACHE=3Dm=0ACONFIG_FSCACHE_STATS=3Dy=0A# CONFIG_FSCACHE_HISTOGRAM is n=
ot set=0A# CONFIG_FSCACHE_DEBUG is not set=0ACONFIG_FSCACHE_OBJECT_LIST=3Dy=
=0ACONFIG_CACHEFILES=3Dm=0A# CONFIG_CACHEFILES_DEBUG is not set=0A# CONFIG_=
CACHEFILES_HISTOGRAM is not set=0A=0A#=0A# CD-ROM/DVD Filesystems=0A#=0ACON=
FIG_ISO9660_FS=3Dm=0ACONFIG_JOLIET=3Dy=0ACONFIG_ZISOFS=3Dy=0ACONFIG_UDF_FS=
=3Dm=0ACONFIG_UDF_NLS=3Dy=0A=0A#=0A# DOS/FAT/NT Filesystems=0A#=0A# CONFIG_=
MSDOS_FS is not set=0A# CONFIG_VFAT_FS is not set=0A# CONFIG_NTFS_FS is not=
 set=0A=0A#=0A# Pseudo filesystems=0A#=0ACONFIG_PROC_FS=3Dy=0ACONFIG_PROC_K=
CORE=3Dy=0ACONFIG_PROC_VMCORE=3Dy=0ACONFIG_PROC_SYSCTL=3Dy=0ACONFIG_PROC_PA=
GE_MONITOR=3Dy=0A# CONFIG_PROC_CHILDREN is not set=0ACONFIG_KERNFS=3Dy=0ACO=
NFIG_SYSFS=3Dy=0ACONFIG_TMPFS=3Dy=0ACONFIG_TMPFS_POSIX_ACL=3Dy=0ACONFIG_TMP=
FS_XATTR=3Dy=0ACONFIG_HUGETLBFS=3Dy=0ACONFIG_HUGETLB_PAGE=3Dy=0ACONFIG_CONF=
IGFS_FS=3Dy=0ACONFIG_EFIVAR_FS=3Dy=0ACONFIG_MISC_FILESYSTEMS=3Dy=0A# CONFIG=
_ADFS_FS is not set=0A# CONFIG_AFFS_FS is not set=0A# CONFIG_ECRYPT_FS is n=
ot set=0A# CONFIG_HFS_FS is not set=0A# CONFIG_HFSPLUS_FS is not set=0A# CO=
NFIG_BEFS_FS is not set=0A# CONFIG_BFS_FS is not set=0A# CONFIG_EFS_FS is n=
ot set=0A# CONFIG_LOGFS is not set=0A# CONFIG_CRAMFS is not set=0A# CONFIG_=
SQUASHFS is not set=0A# CONFIG_VXFS_FS is not set=0A# CONFIG_MINIX_FS is no=
t set=0A# CONFIG_OMFS_FS is not set=0A# CONFIG_HPFS_FS is not set=0A# CONFI=
G_QNX4FS_FS is not set=0A# CONFIG_QNX6FS_FS is not set=0A# CONFIG_ROMFS_FS =
is not set=0ACONFIG_PSTORE=3Dy=0A# CONFIG_PSTORE_CONSOLE is not set=0A# CON=
FIG_PSTORE_PMSG is not set=0A# CONFIG_PSTORE_FTRACE is not set=0ACONFIG_PST=
ORE_RAM=3Dm=0A# CONFIG_SYSV_FS is not set=0A# CONFIG_UFS_FS is not set=0A# =
CONFIG_EXOFS_FS is not set=0ACONFIG_NETWORK_FILESYSTEMS=3Dy=0A# CONFIG_NFS_=
FS is not set=0A# CONFIG_NFSD is not set=0A# CONFIG_CEPH_FS is not set=0A# =
CONFIG_CIFS is not set=0A# CONFIG_NCP_FS is not set=0A# CONFIG_CODA_FS is n=
ot set=0A# CONFIG_AFS_FS is not set=0ACONFIG_NLS=3Dy=0ACONFIG_NLS_DEFAULT=
=3D"utf8"=0A# CONFIG_NLS_CODEPAGE_437 is not set=0A# CONFIG_NLS_CODEPAGE_73=
7 is not set=0A# CONFIG_NLS_CODEPAGE_775 is not set=0A# CONFIG_NLS_CODEPAGE=
_850 is not set=0A# CONFIG_NLS_CODEPAGE_852 is not set=0A# CONFIG_NLS_CODEP=
AGE_855 is not set=0A# CONFIG_NLS_CODEPAGE_857 is not set=0A# CONFIG_NLS_CO=
DEPAGE_860 is not set=0A# CONFIG_NLS_CODEPAGE_861 is not set=0A# CONFIG_NLS=
_CODEPAGE_862 is not set=0A# CONFIG_NLS_CODEPAGE_863 is not set=0A# CONFIG_=
NLS_CODEPAGE_864 is not set=0A# CONFIG_NLS_CODEPAGE_865 is not set=0A# CONF=
IG_NLS_CODEPAGE_866 is not set=0A# CONFIG_NLS_CODEPAGE_869 is not set=0A# C=
ONFIG_NLS_CODEPAGE_936 is not set=0A# CONFIG_NLS_CODEPAGE_950 is not set=0A=
# CONFIG_NLS_CODEPAGE_932 is not set=0A# CONFIG_NLS_CODEPAGE_949 is not set=
=0A# CONFIG_NLS_CODEPAGE_874 is not set=0ACONFIG_NLS_ISO8859_8=3Dm=0A# CONF=
IG_NLS_CODEPAGE_1250 is not set=0A# CONFIG_NLS_CODEPAGE_1251 is not set=0AC=
ONFIG_NLS_ASCII=3Dy=0ACONFIG_NLS_ISO8859_1=3Dy=0ACONFIG_NLS_ISO8859_2=3Dy=
=0A# CONFIG_NLS_ISO8859_3 is not set=0A# CONFIG_NLS_ISO8859_4 is not set=0A=
# CONFIG_NLS_ISO8859_5 is not set=0A# CONFIG_NLS_ISO8859_6 is not set=0A# C=
ONFIG_NLS_ISO8859_7 is not set=0A# CONFIG_NLS_ISO8859_9 is not set=0A# CONF=
IG_NLS_ISO8859_13 is not set=0A# CONFIG_NLS_ISO8859_14 is not set=0A# CONFI=
G_NLS_ISO8859_15 is not set=0A# CONFIG_NLS_KOI8_R is not set=0A# CONFIG_NLS=
_KOI8_U is not set=0A# CONFIG_NLS_MAC_ROMAN is not set=0A# CONFIG_NLS_MAC_C=
ELTIC is not set=0A# CONFIG_NLS_MAC_CENTEURO is not set=0A# CONFIG_NLS_MAC_=
CROATIAN is not set=0A# CONFIG_NLS_MAC_CYRILLIC is not set=0A# CONFIG_NLS_M=
AC_GAELIC is not set=0A# CONFIG_NLS_MAC_GREEK is not set=0A# CONFIG_NLS_MAC=
_ICELAND is not set=0A# CONFIG_NLS_MAC_INUIT is not set=0A# CONFIG_NLS_MAC_=
ROMANIAN is not set=0A# CONFIG_NLS_MAC_TURKISH is not set=0ACONFIG_NLS_UTF8=
=3Dm=0A# CONFIG_DLM is not set=0A=0A#=0A# Kernel hacking=0A#=0ACONFIG_TRACE=
_IRQFLAGS_SUPPORT=3Dy=0A=0A#=0A# printk and dmesg options=0A#=0ACONFIG_PRIN=
TK_TIME=3Dy=0ACONFIG_MESSAGE_LOGLEVEL_DEFAULT=3D4=0ACONFIG_BOOT_PRINTK_DELA=
Y=3Dy=0ACONFIG_DYNAMIC_DEBUG=3Dy=0A=0A#=0A# Compile-time checks and compile=
r options=0A#=0ACONFIG_DEBUG_INFO=3Dy=0A# CONFIG_DEBUG_INFO_REDUCED is not =
set=0A# CONFIG_DEBUG_INFO_SPLIT is not set=0ACONFIG_DEBUG_INFO_DWARF4=3Dy=
=0ACONFIG_GDB_SCRIPTS=3Dy=0A# CONFIG_ENABLE_WARN_DEPRECATED is not set=0ACO=
NFIG_ENABLE_MUST_CHECK=3Dy=0ACONFIG_FRAME_WARN=3D2048=0ACONFIG_STRIP_ASM_SY=
MS=3Dy=0A# CONFIG_READABLE_ASM is not set=0ACONFIG_UNUSED_SYMBOLS=3Dy=0A# C=
ONFIG_PAGE_OWNER is not set=0ACONFIG_DEBUG_FS=3Dy=0ACONFIG_HEADERS_CHECK=3D=
y=0A# CONFIG_DEBUG_SECTION_MISMATCH is not set=0ACONFIG_SECTION_MISMATCH_WA=
RN_ONLY=3Dy=0ACONFIG_ARCH_WANT_FRAME_POINTERS=3Dy=0ACONFIG_FRAME_POINTER=3D=
y=0A# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set=0ACONFIG_MAGIC_SYSRQ=3Dy=
=0ACONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=3D0x0=0ACONFIG_DEBUG_KERNEL=3Dy=0A=0A#=
=0A# Memory Debugging=0A#=0A# CONFIG_PAGE_EXTENSION is not set=0A# CONFIG_D=
EBUG_PAGEALLOC is not set=0A# CONFIG_DEBUG_OBJECTS is not set=0A# CONFIG_SL=
UB_DEBUG_ON is not set=0A# CONFIG_SLUB_STATS is not set=0ACONFIG_HAVE_DEBUG=
_KMEMLEAK=3Dy=0A# CONFIG_DEBUG_KMEMLEAK is not set=0A# CONFIG_DEBUG_STACK_U=
SAGE is not set=0ACONFIG_DEBUG_VM=3Dy=0A# CONFIG_DEBUG_VM_VMACACHE is not s=
et=0A# CONFIG_DEBUG_VM_RB is not set=0A# CONFIG_DEBUG_VIRTUAL is not set=0A=
CONFIG_DEBUG_MEMORY_INIT=3Dy=0A# CONFIG_DEBUG_PER_CPU_MAPS is not set=0ACON=
FIG_HAVE_DEBUG_STACKOVERFLOW=3Dy=0ACONFIG_DEBUG_STACKOVERFLOW=3Dy=0ACONFIG_=
HAVE_ARCH_KMEMCHECK=3Dy=0ACONFIG_HAVE_ARCH_KASAN=3Dy=0A# CONFIG_KASAN is no=
t set=0ACONFIG_DEBUG_SHIRQ=3Dy=0A=0A#=0A# Debug Lockups and Hangs=0A#=0ACON=
FIG_LOCKUP_DETECTOR=3Dy=0ACONFIG_HARDLOCKUP_DETECTOR=3Dy=0A# CONFIG_BOOTPAR=
AM_HARDLOCKUP_PANIC is not set=0ACONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=3D=
0=0A# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set=0ACONFIG_BOOTPARAM_SOFTL=
OCKUP_PANIC_VALUE=3D0=0A# CONFIG_DETECT_HUNG_TASK is not set=0A# CONFIG_PAN=
IC_ON_OOPS is not set=0ACONFIG_PANIC_ON_OOPS_VALUE=3D0=0ACONFIG_PANIC_TIMEO=
UT=3D0=0ACONFIG_SCHED_DEBUG=3Dy=0ACONFIG_SCHED_INFO=3Dy=0A# CONFIG_SCHEDSTA=
TS is not set=0A# CONFIG_SCHED_STACK_END_CHECK is not set=0A# CONFIG_DEBUG_=
TIMEKEEPING is not set=0ACONFIG_TIMER_STATS=3Dy=0A=0A#=0A# Lock Debugging (=
spinlocks, mutexes, etc...)=0A#=0A# CONFIG_DEBUG_RT_MUTEXES is not set=0A# =
CONFIG_DEBUG_SPINLOCK is not set=0A# CONFIG_DEBUG_MUTEXES is not set=0A# CO=
NFIG_DEBUG_WW_MUTEX_SLOWPATH is not set=0A# CONFIG_DEBUG_LOCK_ALLOC is not =
set=0A# CONFIG_PROVE_LOCKING is not set=0A# CONFIG_LOCK_STAT is not set=0A#=
 CONFIG_DEBUG_ATOMIC_SLEEP is not set=0A# CONFIG_DEBUG_LOCKING_API_SELFTEST=
S is not set=0A# CONFIG_LOCK_TORTURE_TEST is not set=0ACONFIG_STACKTRACE=3D=
y=0A# CONFIG_DEBUG_KOBJECT is not set=0ACONFIG_DEBUG_BUGVERBOSE=3Dy=0ACONFI=
G_DEBUG_LIST=3Dy=0A# CONFIG_DEBUG_PI_LIST is not set=0A# CONFIG_DEBUG_SG is=
 not set=0A# CONFIG_DEBUG_NOTIFIERS is not set=0A# CONFIG_DEBUG_CREDENTIALS=
 is not set=0A=0A#=0A# RCU Debugging=0A#=0A# CONFIG_PROVE_RCU is not set=0A=
CONFIG_SPARSE_RCU_POINTER=3Dy=0ACONFIG_TORTURE_TEST=3Dm=0ACONFIG_RCU_TORTUR=
E_TEST=3Dm=0A# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set=0A# CONFIG_R=
CU_TORTURE_TEST_SLOW_INIT is not set=0A# CONFIG_RCU_TORTURE_TEST_SLOW_CLEAN=
UP is not set=0ACONFIG_RCU_CPU_STALL_TIMEOUT=3D60=0A# CONFIG_RCU_TRACE is n=
ot set=0A# CONFIG_RCU_EQS_DEBUG is not set=0A# CONFIG_DEBUG_BLOCK_EXT_DEVT =
is not set=0A# CONFIG_NOTIFIER_ERROR_INJECTION is not set=0A# CONFIG_FAULT_=
INJECTION is not set=0A# CONFIG_LATENCYTOP is not set=0ACONFIG_ARCH_HAS_DEB=
UG_STRICT_USER_COPY_CHECKS=3Dy=0A# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is =
not set=0ACONFIG_USER_STACKTRACE_SUPPORT=3Dy=0ACONFIG_NOP_TRACER=3Dy=0ACONF=
IG_HAVE_FUNCTION_TRACER=3Dy=0ACONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy=0ACONFI=
G_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy=0ACONFIG_HAVE_DYNAMIC_FTRACE=3Dy=0ACONFIG=
_HAVE_DYNAMIC_FTRACE_WITH_REGS=3Dy=0ACONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy=
=0ACONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy=0ACONFIG_HAVE_FENTRY=3Dy=0ACONFIG_HA=
VE_C_RECORDMCOUNT=3Dy=0ACONFIG_TRACER_MAX_TRACE=3Dy=0ACONFIG_TRACE_CLOCK=3D=
y=0ACONFIG_RING_BUFFER=3Dy=0ACONFIG_EVENT_TRACING=3Dy=0ACONFIG_CONTEXT_SWIT=
CH_TRACER=3Dy=0ACONFIG_RING_BUFFER_ALLOW_SWAP=3Dy=0ACONFIG_TRACING=3Dy=0ACO=
NFIG_GENERIC_TRACER=3Dy=0ACONFIG_TRACING_SUPPORT=3Dy=0ACONFIG_FTRACE=3Dy=0A=
CONFIG_FUNCTION_TRACER=3Dy=0ACONFIG_FUNCTION_GRAPH_TRACER=3Dy=0A# CONFIG_IR=
QSOFF_TRACER is not set=0ACONFIG_SCHED_TRACER=3Dy=0ACONFIG_FTRACE_SYSCALLS=
=3Dy=0ACONFIG_TRACER_SNAPSHOT=3Dy=0A# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP i=
s not set=0ACONFIG_BRANCH_PROFILE_NONE=3Dy=0A# CONFIG_PROFILE_ANNOTATED_BRA=
NCHES is not set=0A# CONFIG_PROFILE_ALL_BRANCHES is not set=0ACONFIG_STACK_=
TRACER=3Dy=0ACONFIG_BLK_DEV_IO_TRACE=3Dy=0ACONFIG_KPROBE_EVENT=3Dy=0ACONFIG=
_UPROBE_EVENT=3Dy=0ACONFIG_PROBE_EVENTS=3Dy=0ACONFIG_DYNAMIC_FTRACE=3Dy=0AC=
ONFIG_DYNAMIC_FTRACE_WITH_REGS=3Dy=0ACONFIG_FUNCTION_PROFILER=3Dy=0ACONFIG_=
FTRACE_MCOUNT_RECORD=3Dy=0A# CONFIG_FTRACE_STARTUP_TEST is not set=0A# CONF=
IG_MMIOTRACE is not set=0A# CONFIG_TRACEPOINT_BENCHMARK is not set=0ACONFIG=
_RING_BUFFER_BENCHMARK=3Dm=0A# CONFIG_RING_BUFFER_STARTUP_TEST is not set=
=0A# CONFIG_TRACE_ENUM_MAP_FILE is not set=0A=0A#=0A# Runtime Testing=0A#=
=0A# CONFIG_LKDTM is not set=0A# CONFIG_TEST_LIST_SORT is not set=0A# CONFI=
G_KPROBES_SANITY_TEST is not set=0A# CONFIG_BACKTRACE_SELF_TEST is not set=
=0A# CONFIG_RBTREE_TEST is not set=0A# CONFIG_INTERVAL_TREE_TEST is not set=
=0A# CONFIG_PERCPU_TEST is not set=0ACONFIG_ATOMIC64_SELFTEST=3Dy=0ACONFIG_=
ASYNC_RAID6_TEST=3Dm=0A# CONFIG_TEST_HEXDUMP is not set=0A# CONFIG_TEST_STR=
ING_HELPERS is not set=0ACONFIG_TEST_KSTRTOX=3Dy=0A# CONFIG_TEST_PRINTF is =
not set=0A# CONFIG_TEST_RHASHTABLE is not set=0ACONFIG_PROVIDE_OHCI1394_DMA=
_INIT=3Dy=0ACONFIG_BUILD_DOCSRC=3Dy=0A# CONFIG_DMA_API_DEBUG is not set=0A#=
 CONFIG_TEST_LKM is not set=0A# CONFIG_TEST_USER_COPY is not set=0A# CONFIG=
_TEST_BPF is not set=0A# CONFIG_TEST_FIRMWARE is not set=0A# CONFIG_TEST_UD=
ELAY is not set=0A# CONFIG_MEMTEST is not set=0A# CONFIG_TEST_STATIC_KEYS i=
s not set=0A# CONFIG_SAMPLES is not set=0ACONFIG_HAVE_ARCH_KGDB=3Dy=0ACONFI=
G_KGDB=3Dy=0ACONFIG_KGDB_SERIAL_CONSOLE=3Dy=0ACONFIG_KGDB_TESTS=3Dy=0A# CON=
FIG_KGDB_TESTS_ON_BOOT is not set=0ACONFIG_KGDB_LOW_LEVEL_TRAP=3Dy=0ACONFIG=
_KGDB_KDB=3Dy=0ACONFIG_KDB_DEFAULT_ENABLE=3D0x1=0ACONFIG_KDB_KEYBOARD=3Dy=
=0ACONFIG_KDB_CONTINUE_CATASTROPHIC=3D0=0ACONFIG_STRICT_DEVMEM=3Dy=0A# CONF=
IG_X86_VERBOSE_BOOTUP is not set=0ACONFIG_EARLY_PRINTK=3Dy=0ACONFIG_EARLY_P=
RINTK_DBGP=3Dy=0ACONFIG_EARLY_PRINTK_EFI=3Dy=0A# CONFIG_X86_PTDUMP_CORE is =
not set=0A# CONFIG_X86_PTDUMP is not set=0A# CONFIG_EFI_PGT_DUMP is not set=
=0ACONFIG_DEBUG_RODATA=3Dy=0ACONFIG_DEBUG_RODATA_TEST=3Dy=0A# CONFIG_DEBUG_=
WX is not set=0ACONFIG_DEBUG_SET_MODULE_RONX=3Dy=0ACONFIG_DEBUG_NX_TEST=3Dm=
=0ACONFIG_DOUBLEFAULT=3Dy=0A# CONFIG_DEBUG_TLBFLUSH is not set=0A# CONFIG_I=
OMMU_STRESS is not set=0ACONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy=0ACONFIG_X86_DEC=
ODER_SELFTEST=3Dy=0ACONFIG_IO_DELAY_TYPE_0X80=3D0=0ACONFIG_IO_DELAY_TYPE_0X=
ED=3D1=0ACONFIG_IO_DELAY_TYPE_UDELAY=3D2=0ACONFIG_IO_DELAY_TYPE_NONE=3D3=0A=
CONFIG_IO_DELAY_0X80=3Dy=0A# CONFIG_IO_DELAY_0XED is not set=0A# CONFIG_IO_=
DELAY_UDELAY is not set=0A# CONFIG_IO_DELAY_NONE is not set=0ACONFIG_DEFAUL=
T_IO_DELAY_TYPE=3D0=0ACONFIG_DEBUG_BOOT_PARAMS=3Dy=0A# CONFIG_CPA_DEBUG is =
not set=0ACONFIG_OPTIMIZE_INLINING=3Dy=0A# CONFIG_DEBUG_ENTRY is not set=0A=
# CONFIG_DEBUG_NMI_SELFTEST is not set=0A# CONFIG_X86_DEBUG_STATIC_CPU_HAS =
is not set=0ACONFIG_X86_DEBUG_FPU=3Dy=0A# CONFIG_PUNIT_ATOM_DEBUG is not se=
t=0A=0A#=0A# Security options=0A#=0ACONFIG_KEYS=3Dy=0ACONFIG_PERSISTENT_KEY=
RINGS=3Dy=0ACONFIG_BIG_KEYS=3Dy=0ACONFIG_TRUSTED_KEYS=3Dm=0ACONFIG_ENCRYPTE=
D_KEYS=3Dm=0A# CONFIG_SECURITY_DMESG_RESTRICT is not set=0ACONFIG_SECURITY=
=3Dy=0ACONFIG_SECURITYFS=3Dy=0ACONFIG_SECURITY_NETWORK=3Dy=0ACONFIG_SECURIT=
Y_NETWORK_XFRM=3Dy=0A# CONFIG_SECURITY_PATH is not set=0ACONFIG_INTEL_TXT=
=3Dy=0A# CONFIG_SECURITY_SELINUX is not set=0A# CONFIG_SECURITY_SMACK is no=
t set=0A# CONFIG_SECURITY_TOMOYO is not set=0A# CONFIG_SECURITY_APPARMOR is=
 not set=0A# CONFIG_SECURITY_YAMA is not set=0A# CONFIG_INTEGRITY is not se=
t=0ACONFIG_DEFAULT_SECURITY_DAC=3Dy=0ACONFIG_DEFAULT_SECURITY=3D""=0ACONFIG=
_XOR_BLOCKS=3Dm=0ACONFIG_ASYNC_CORE=3Dm=0ACONFIG_ASYNC_MEMCPY=3Dm=0ACONFIG_=
ASYNC_XOR=3Dm=0ACONFIG_ASYNC_PQ=3Dm=0ACONFIG_ASYNC_RAID6_RECOV=3Dm=0ACONFIG=
_CRYPTO=3Dy=0A=0A#=0A# Crypto core or helper=0A#=0ACONFIG_CRYPTO_ALGAPI=3Dy=
=0ACONFIG_CRYPTO_ALGAPI2=3Dy=0ACONFIG_CRYPTO_AEAD=3Dy=0ACONFIG_CRYPTO_AEAD2=
=3Dy=0ACONFIG_CRYPTO_BLKCIPHER=3Dy=0ACONFIG_CRYPTO_BLKCIPHER2=3Dy=0ACONFIG_=
CRYPTO_HASH=3Dy=0ACONFIG_CRYPTO_HASH2=3Dy=0ACONFIG_CRYPTO_RNG=3Dy=0ACONFIG_=
CRYPTO_RNG2=3Dy=0ACONFIG_CRYPTO_RNG_DEFAULT=3Dy=0ACONFIG_CRYPTO_PCOMP2=3Dy=
=0ACONFIG_CRYPTO_AKCIPHER2=3Dy=0A# CONFIG_CRYPTO_RSA is not set=0ACONFIG_CR=
YPTO_MANAGER=3Dy=0ACONFIG_CRYPTO_MANAGER2=3Dy=0A# CONFIG_CRYPTO_USER is not=
 set=0A# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set=0ACONFIG_CRYPTO_GF1=
28MUL=3Dy=0ACONFIG_CRYPTO_NULL=3Dy=0ACONFIG_CRYPTO_NULL2=3Dy=0A# CONFIG_CRY=
PTO_PCRYPT is not set=0ACONFIG_CRYPTO_WORKQUEUE=3Dy=0A# CONFIG_CRYPTO_CRYPT=
D is not set=0A# CONFIG_CRYPTO_MCRYPTD is not set=0ACONFIG_CRYPTO_AUTHENC=
=3Dm=0A# CONFIG_CRYPTO_TEST is not set=0A=0A#=0A# Authenticated Encryption =
with Associated Data=0A#=0ACONFIG_CRYPTO_CCM=3Dm=0ACONFIG_CRYPTO_GCM=3Dm=0A=
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set=0ACONFIG_CRYPTO_SEQIV=3Dy=0ACON=
FIG_CRYPTO_ECHAINIV=3Dm=0A=0A#=0A# Block modes=0A#=0ACONFIG_CRYPTO_CBC=3Dy=
=0ACONFIG_CRYPTO_CTR=3Dy=0A# CONFIG_CRYPTO_CTS is not set=0A# CONFIG_CRYPTO=
_ECB is not set=0ACONFIG_CRYPTO_LRW=3Dy=0A# CONFIG_CRYPTO_PCBC is not set=
=0ACONFIG_CRYPTO_XTS=3Dy=0A# CONFIG_CRYPTO_KEYWRAP is not set=0A=0A#=0A# Ha=
sh modes=0A#=0A# CONFIG_CRYPTO_CMAC is not set=0ACONFIG_CRYPTO_HMAC=3Dy=0A#=
 CONFIG_CRYPTO_XCBC is not set=0A# CONFIG_CRYPTO_VMAC is not set=0A=0A#=0A#=
 Digest=0A#=0ACONFIG_CRYPTO_CRC32C=3Dy=0ACONFIG_CRYPTO_CRC32C_INTEL=3Dm=0A#=
 CONFIG_CRYPTO_CRC32 is not set=0A# CONFIG_CRYPTO_CRC32_PCLMUL is not set=
=0ACONFIG_CRYPTO_CRCT10DIF=3Dy=0A# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not se=
t=0ACONFIG_CRYPTO_GHASH=3Dm=0A# CONFIG_CRYPTO_POLY1305 is not set=0A# CONFI=
G_CRYPTO_POLY1305_X86_64 is not set=0A# CONFIG_CRYPTO_MD4 is not set=0ACONF=
IG_CRYPTO_MD5=3Dy=0A# CONFIG_CRYPTO_MICHAEL_MIC is not set=0A# CONFIG_CRYPT=
O_RMD128 is not set=0A# CONFIG_CRYPTO_RMD160 is not set=0A# CONFIG_CRYPTO_R=
MD256 is not set=0A# CONFIG_CRYPTO_RMD320 is not set=0ACONFIG_CRYPTO_SHA1=
=3Dy=0A# CONFIG_CRYPTO_SHA1_SSSE3 is not set=0A# CONFIG_CRYPTO_SHA256_SSSE3=
 is not set=0A# CONFIG_CRYPTO_SHA512_SSSE3 is not set=0A# CONFIG_CRYPTO_SHA=
1_MB is not set=0ACONFIG_CRYPTO_SHA256=3Dy=0A# CONFIG_CRYPTO_SHA512 is not =
set=0A# CONFIG_CRYPTO_TGR192 is not set=0A# CONFIG_CRYPTO_WP512 is not set=
=0A# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set=0A=0A#=0A# Ciphers=0A#=
=0ACONFIG_CRYPTO_AES=3Dy=0A# CONFIG_CRYPTO_AES_X86_64 is not set=0A# CONFIG=
_CRYPTO_AES_NI_INTEL is not set=0A# CONFIG_CRYPTO_ANUBIS is not set=0ACONFI=
G_CRYPTO_ARC4=3Dm=0A# CONFIG_CRYPTO_BLOWFISH is not set=0A# CONFIG_CRYPTO_B=
LOWFISH_X86_64 is not set=0A# CONFIG_CRYPTO_CAMELLIA is not set=0A# CONFIG_=
CRYPTO_CAMELLIA_X86_64 is not set=0A# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_=
64 is not set=0A# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set=0A# C=
ONFIG_CRYPTO_CAST5 is not set=0A# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set=
=0A# CONFIG_CRYPTO_CAST6 is not set=0A# CONFIG_CRYPTO_CAST6_AVX_X86_64 is n=
ot set=0ACONFIG_CRYPTO_DES=3Dm=0A# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set=
=0A# CONFIG_CRYPTO_FCRYPT is not set=0A# CONFIG_CRYPTO_KHAZAD is not set=0A=
# CONFIG_CRYPTO_SALSA20 is not set=0A# CONFIG_CRYPTO_SALSA20_X86_64 is not =
set=0A# CONFIG_CRYPTO_CHACHA20 is not set=0A# CONFIG_CRYPTO_CHACHA20_X86_64=
 is not set=0A# CONFIG_CRYPTO_SEED is not set=0A# CONFIG_CRYPTO_SERPENT is =
not set=0A# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set=0A# CONFIG_CRYPTO_=
SERPENT_AVX_X86_64 is not set=0A# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not =
set=0A# CONFIG_CRYPTO_TEA is not set=0A# CONFIG_CRYPTO_TWOFISH is not set=
=0A# CONFIG_CRYPTO_TWOFISH_X86_64 is not set=0A# CONFIG_CRYPTO_TWOFISH_X86_=
64_3WAY is not set=0A# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set=0A=0A#=
=0A# Compression=0A#=0ACONFIG_CRYPTO_DEFLATE=3Dm=0A# CONFIG_CRYPTO_ZLIB is =
not set=0ACONFIG_CRYPTO_LZO=3Dy=0A# CONFIG_CRYPTO_842 is not set=0A# CONFIG=
_CRYPTO_LZ4 is not set=0A# CONFIG_CRYPTO_LZ4HC is not set=0A=0A#=0A# Random=
 Number Generation=0A#=0A# CONFIG_CRYPTO_ANSI_CPRNG is not set=0ACONFIG_CRY=
PTO_DRBG_MENU=3Dy=0ACONFIG_CRYPTO_DRBG_HMAC=3Dy=0A# CONFIG_CRYPTO_DRBG_HASH=
 is not set=0A# CONFIG_CRYPTO_DRBG_CTR is not set=0ACONFIG_CRYPTO_DRBG=3Dy=
=0ACONFIG_CRYPTO_JITTERENTROPY=3Dy=0A# CONFIG_CRYPTO_USER_API_HASH is not s=
et=0A# CONFIG_CRYPTO_USER_API_SKCIPHER is not set=0A# CONFIG_CRYPTO_USER_AP=
I_RNG is not set=0A# CONFIG_CRYPTO_USER_API_AEAD is not set=0A# CONFIG_CRYP=
TO_HW is not set=0A# CONFIG_ASYMMETRIC_KEY_TYPE is not set=0A=0A#=0A# Certi=
ficates for signature checking=0A#=0A# CONFIG_SYSTEM_TRUSTED_KEYRING is not=
 set=0ACONFIG_HAVE_KVM=3Dy=0ACONFIG_HAVE_KVM_IRQCHIP=3Dy=0ACONFIG_HAVE_KVM_=
IRQFD=3Dy=0ACONFIG_HAVE_KVM_IRQ_ROUTING=3Dy=0ACONFIG_HAVE_KVM_EVENTFD=3Dy=
=0ACONFIG_KVM_APIC_ARCHITECTURE=3Dy=0ACONFIG_KVM_MMIO=3Dy=0ACONFIG_KVM_ASYN=
C_PF=3Dy=0ACONFIG_HAVE_KVM_MSI=3Dy=0ACONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=3D=
y=0ACONFIG_KVM_VFIO=3Dy=0ACONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=3Dy=0ACO=
NFIG_KVM_COMPAT=3Dy=0ACONFIG_HAVE_KVM_IRQ_BYPASS=3Dy=0ACONFIG_VIRTUALIZATIO=
N=3Dy=0ACONFIG_KVM=3Dm=0ACONFIG_KVM_INTEL=3Dm=0ACONFIG_KVM_AMD=3Dm=0ACONFIG=
_KVM_MMU_AUDIT=3Dy=0ACONFIG_KVM_DEVICE_ASSIGNMENT=3Dy=0ACONFIG_BINARY_PRINT=
F=3Dy=0A=0A#=0A# Library routines=0A#=0ACONFIG_RAID6_PQ=3Dm=0ACONFIG_BITREV=
ERSE=3Dy=0A# CONFIG_HAVE_ARCH_BITREVERSE is not set=0ACONFIG_RATIONAL=3Dy=
=0ACONFIG_GENERIC_STRNCPY_FROM_USER=3Dy=0ACONFIG_GENERIC_STRNLEN_USER=3Dy=
=0ACONFIG_GENERIC_NET_UTILS=3Dy=0ACONFIG_GENERIC_FIND_FIRST_BIT=3Dy=0ACONFI=
G_GENERIC_PCI_IOMAP=3Dy=0ACONFIG_GENERIC_IOMAP=3Dy=0ACONFIG_GENERIC_IO=3Dy=
=0ACONFIG_ARCH_USE_CMPXCHG_LOCKREF=3Dy=0ACONFIG_ARCH_HAS_FAST_MULTIPLIER=3D=
y=0ACONFIG_CRC_CCITT=3Dm=0ACONFIG_CRC16=3Dy=0ACONFIG_CRC_T10DIF=3Dy=0ACONFI=
G_CRC_ITU_T=3Dm=0ACONFIG_CRC32=3Dy=0A# CONFIG_CRC32_SELFTEST is not set=0AC=
ONFIG_CRC32_SLICEBY8=3Dy=0A# CONFIG_CRC32_SLICEBY4 is not set=0A# CONFIG_CR=
C32_SARWATE is not set=0A# CONFIG_CRC32_BIT is not set=0A# CONFIG_CRC7 is n=
ot set=0ACONFIG_LIBCRC32C=3Dm=0ACONFIG_CRC8=3Dm=0A# CONFIG_AUDIT_ARCH_COMPA=
T_GENERIC is not set=0A# CONFIG_RANDOM32_SELFTEST is not set=0ACONFIG_ZLIB_=
INFLATE=3Dy=0ACONFIG_ZLIB_DEFLATE=3Dy=0ACONFIG_LZO_COMPRESS=3Dy=0ACONFIG_LZ=
O_DECOMPRESS=3Dy=0ACONFIG_LZ4_DECOMPRESS=3Dy=0ACONFIG_XZ_DEC=3Dy=0ACONFIG_X=
Z_DEC_X86=3Dy=0ACONFIG_XZ_DEC_POWERPC=3Dy=0ACONFIG_XZ_DEC_IA64=3Dy=0ACONFIG=
_XZ_DEC_ARM=3Dy=0ACONFIG_XZ_DEC_ARMTHUMB=3Dy=0ACONFIG_XZ_DEC_SPARC=3Dy=0ACO=
NFIG_XZ_DEC_BCJ=3Dy=0A# CONFIG_XZ_DEC_TEST is not set=0ACONFIG_DECOMPRESS_G=
ZIP=3Dy=0ACONFIG_DECOMPRESS_BZIP2=3Dy=0ACONFIG_DECOMPRESS_LZMA=3Dy=0ACONFIG=
_DECOMPRESS_XZ=3Dy=0ACONFIG_DECOMPRESS_LZO=3Dy=0ACONFIG_DECOMPRESS_LZ4=3Dy=
=0ACONFIG_GENERIC_ALLOCATOR=3Dy=0ACONFIG_REED_SOLOMON=3Dm=0ACONFIG_REED_SOL=
OMON_ENC8=3Dy=0ACONFIG_REED_SOLOMON_DEC8=3Dy=0ACONFIG_TEXTSEARCH=3Dy=0ACONF=
IG_TEXTSEARCH_KMP=3Dm=0ACONFIG_TEXTSEARCH_BM=3Dm=0ACONFIG_TEXTSEARCH_FSM=3D=
m=0ACONFIG_INTERVAL_TREE=3Dy=0ACONFIG_ASSOCIATIVE_ARRAY=3Dy=0ACONFIG_HAS_IO=
MEM=3Dy=0ACONFIG_HAS_IOPORT_MAP=3Dy=0ACONFIG_HAS_DMA=3Dy=0ACONFIG_CHECK_SIG=
NATURE=3Dy=0ACONFIG_CPU_RMAP=3Dy=0ACONFIG_DQL=3Dy=0ACONFIG_NLATTR=3Dy=0ACON=
FIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=3Dy=0ACONFIG_CORDIC=3Dm=0A# CONFIG_DD=
R is not set=0ACONFIG_UCS2_STRING=3Dy=0ACONFIG_FONT_SUPPORT=3Dy=0A# CONFIG_=
FONTS is not set=0ACONFIG_FONT_8x8=3Dy=0ACONFIG_FONT_8x16=3Dy=0A# CONFIG_SG=
_SPLIT is not set=0ACONFIG_ARCH_HAS_SG_CHAIN=3Dy=0ACONFIG_ARCH_HAS_PMEM_API=
=3Dy=0ACONFIG_ARCH_HAS_MMIO_FLUSH=3Dy=0A
--FCF9ydJxlAJsfRTu
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="xen-netfront-detach-crash.patch"
Content-Transfer-Encoding: quoted-printable

When it get to free_page(queue->grant_tx_page[i]), the use counter on this =
page
is already 0, which cause a crash. Not sure if this is the proper fix
(according to git log this may introduce some memory leak), but at least it
prevent the crash.

Details in this thread:
http://xen.markmail.org/thread/pw5edbtqienjx4q5

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..a5efbb0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1065,9 +1069,10 @@ static void xennet_release_tx_bufs(struct netfront_q=
ueue *queue)
=20
 		skb =3D queue->tx_skbs[i].skb;
 		get_page(queue->grant_tx_page[i]);
-		gnttab_end_foreign_access(queue->grant_tx_ref[i],
-					  GNTMAP_readonly,
-					  (unsigned long)page_address(queue->grant_tx_page[i]));
+		gnttab_end_foreign_access_ref(
+				queue->grant_tx_ref[i], GNTMAP_readonly);
+		gnttab_release_grant_reference(
+				&queue->gref_tx_head, queue->grant_tx_ref[i]);
 		queue->grant_tx_page[i] =3D NULL;
 		queue->grant_tx_ref[i] =3D GRANT_INVALID_REF;
 		add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i);

--FCF9ydJxlAJsfRTu--

--RD6GsZsdEJvsf78O
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWooG/AAoJENuP0xzK19csVGAH/jxgkKcWbH57xltQZQ2Jr8iw
k92BTkM7SkkOF1/zE9Oufp7CeMvcNElhKmcd1SlMvnLcVgowW+jogPwa/XZ1Ud9s
RtXIwlWOSxa/kKcBBQ7KJAJCnqgrJa/9V1nwXGduyhcAMQRMczwXU+mMtcuvfivx
pJAE0IkfD0RUCxLgCb8i63q7t03Arz9hCLxlisERaodYFZlGQ+nJgmNwBx9IyA8z
yAkJtcYiUwID11JQzpIJ67LkM+n3lC2Q8kIh2Tmp4vyC/S5oiOBu80C9rCXChjOy
KrxDVwM7KqnBEGffj0ZdnJVcKH8DWer12xJpgNgVgSa9g3xsMBx7PBceL3m3NHc=
=yVMs
-----END PGP SIGNATURE-----

--RD6GsZsdEJvsf78O--
