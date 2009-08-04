From: Rene Mayrhofer <rene@mayrhofer.eu.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 05 Aug 2009 00:59:43 +0200
Message-ID: <4A78BD5F.2030901@mayrhofer.eu.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:41647 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933363AbZHDXAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 19:00:14 -0400
In-Reply-To: <4A78BC48.4060200@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Rene Mayrhofer wrote:
> Nonetheless, the current unmodified version from netdev git solves the
> oops in sky2. 
Actually, it doesn't. I managed to run networking restart twice without
an oops (with the netdev git version of sky2.c), but after generating
some minor traffic and trying to restart again, I still get this oops:

[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  844.000236] sky2 0000:01:00.0:
error interrupt status=0xffffffff

[  844.007309] sky2 0000:01:00.0: PCI hardware error (0xffff)

[  844.013657] sky2 0000:01:00.0: PCI Express error (0xffffffff)

[  844.020290] sky2 wan: ram data read parity error

[  844.025697] sky2 wan: ram data write parity error

[  844.031148] sky2 wan: MAC parity error

[  844.035522] sky2 wan: RX parity error

[  844.039812] sky2 wan: TCP segmentation error

[  844.044966] BUG: unable to handle kernel NULL pointer dereference at
0000038d
[  844.048782] IP: [<f8050d2d>] sky2_mac_intr+0x30/0xc1 [sky2]

[  844.048782] *pde = 00000000

[  844.048782] Oops: 0000 [#1] PREEMPT SMP

[  844.048782] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

[  844.048782] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ipv6 evdev parport_pc parport serio_raw i2c_i801 i2c_core
iTCO_wdt rng_core pcspkr intel_agp loop aufs exportfs nls_utf8 nls_cp437
ide_generic sd_mod ide_gd_mod ata_generic pata_acpi ata_piix skge piix
ide_pci_generic ide_core sky2 thermal_sys

[  844.048782]

[  844.048782] Pid: 13285, comm: postfix Not tainted (2.6.30.4 #2)

[  844.048782] EIP: 0060:[<f8050d2d>] EFLAGS: 00010286 CPU: 0

[  844.048782] EIP is at sky2_mac_intr+0x30/0xc1 [sky2]

[  844.048782] EAX: f8068f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff

[  844.048782] ESI: 00000000 EDI: f6901b80 EBP: e1c83e9c ESP: e1c83e84

[  844.048782]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068

[  844.048782] Process postfix (pid: 13285, ti=e1c82000 task=e1d105b0
task.ti=e1c82000)

[  844.048782] Stack:

[  844.048782]  00000080 ff901b80 eda21a93 f71ed840 ffffffff ffffffff
e1c83f28 f8054181

[  844.048782]  c022594e 00000000 00000040 f6901b88 00000003 eda21a93
f6901b80 ffffffff

[  844.048782]  c181d7a4 f71ef000 c0243594 00000000 c181d7a0 f702e130
eda21a93 e1c83eec

[  844.048782] Call Trace:

[  844.048782]  [<f8054181>] ? sky2_poll+0x1d2/0xb65 [sky2]

[  844.048782]  [<c022594e>] ? __wake_up+0x41/0x5c

[  844.048782]  [<c0243594>] ? insert_work+0xa5/0xbf

[  844.048782]  [<c04ee2a5>] ? _spin_unlock_irqrestore+0x31/0x44

[  844.048782]  [<c0243e4b>] ? __queue_work+0x36/0x4d

[  844.048782]  [<c047731c>] ? __qdisc_run+0x73/0x1ca

[  844.048782]  [<c0463ce6>] ? net_rx_action+0x9e/0x1a2

[  844.048782]  [<c0237b6e>] ? __do_softirq+0xb2/0x188

[  844.048782]  [<c0237c83>] ? do_softirq+0x3f/0x5c

[  844.048782]  [<c0237e0d>] ? irq_exit+0x37/0x80

[  844.048782]  [<c0213cfd>] ? smp_apic_timer_interrupt+0x7c/0x9b

[  844.048782]  [<c02037dd>] ? apic_timer_interrupt+0x31/0x38

[  844.048782] Code: c7 56 53 89 d3 83 ec 0c 65 a1 14 00 00 00 89 45 f0
31 c0 8b 74 97 3c c1 e2 07 89 d0 05 08 0f 00 00 89 55 e8 03 07 8a 10 88
55 ef <f6> 86 8d 03 00 00 02 74 12 0f b6 c2 50 56 68 d0 64 05 f8 e8 df

[  844.048782] EIP: [<f8050d2d>] sky2_mac_intr+0x30/0xc1 [sky2] SS:ESP
0068:e1c83e84

[  844.048782] CR2: 000000000000038d

[  844.345647] ---[ end trace d7398807329498ac ]---

[  844.351055] Kernel panic - not syncing: Fatal exception in interrupt

[  844.358606] Pid: 13285, comm: postfix Tainted: G      D    2.6.30.4
#2
[  844.366298] Call Trace:

[  844.369278]  [<c04eb041>] ? printk+0x1d/0x30

[  844.374388]  [<c04eaf7f>] panic+0x53/0xf8

[  844.379197]  [<c0206368>] oops_end+0x9f/0xbf

[  844.384303]  [<c021ceb4>] no_context+0x11a/0x135

[  844.389791]  [<c021d005>] __bad_area_nosemaphore+0x136/0x14f

[  844.396489]  [<c0374f60>] ? vsnprintf+0x91/0x332

[  844.401994]  [<c04ee2a5>] ? _spin_unlock_irqrestore+0x31/0x44

[  844.408787]  [<c04ee2a5>] ? _spin_unlock_irqrestore+0x31/0x44

[  844.415546]  [<c0232f4f>] ? release_console_sem+0x18b/0x1c9

[  844.422152]  [<c021d03b>] bad_area_nosemaphore+0x1d/0x34

[  844.428464]  [<c021d30b>] do_page_fault+0x110/0x21b

[  844.434271]  [<c021d1fb>] ? do_page_fault+0x0/0x21b

[  844.440026]  [<c04ee71a>] error_code+0x7a/0x80

[  844.445442]  [<c037007b>] ? add_uevent_var+0x17/0xb9

[  844.451413]  [<f8050d2d>] ? sky2_mac_intr+0x30/0xc1 [sky2]

[  844.457981]  [<f8054181>] sky2_poll+0x1d2/0xb65 [sky2]

[  844.464050]  [<c022594e>] ? __wake_up+0x41/0x5c

[  844.469437]  [<c0243594>] ? insert_work+0xa5/0xbf

[  844.475055]  [<c04ee2a5>] ? _spin_unlock_irqrestore+0x31/0x44

[  844.481817]  [<c0243e4b>] ? __queue_work+0x36/0x4d

[  844.487516]  [<c047731c>] ? __qdisc_run+0x73/0x1ca

[  844.493201]  [<c0463ce6>] net_rx_action+0x9e/0x1a2

[  844.498883]  [<c0237b6e>] __do_softirq+0xb2/0x188

[  844.504446]  [<c0237c83>] do_softirq+0x3f/0x5c

[  844.509720]  [<c0237e0d>] irq_exit+0x37/0x80

[  844.514791]  [<c0213cfd>] smp_apic_timer_interrupt+0x7c/0x9b

[  844.521488]  [<c02037dd>] apic_timer_interrupt+0x31/0x38

[  844.527811] Rebooting in 30 seconds..

This is with the newest version of sky2 as of today. Is this any
indication that traffic is needed to reproduce it? E.g. that a certain
number of interrupts must have already been handled to trigger the bug?

Again, any hints would be greatly appreciated (and sorry for being
persistent about this annoying little bug...).

best regards,
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp4vV8ACgkQq7SPDcPCS95UvgCfTNzwXKGxXi1SUfrMyLglF5Hf
mCkAnRZqfuA5KYkKCz53leWgxHBOLWMo
=Shq7
-----END PGP SIGNATURE-----
