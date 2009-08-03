From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Mon, 03 Aug 2009 13:55:34 +0200
Message-ID: <4A76D036.6090705@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at>	<20090723102848.00a56ad1@nehalam>	<4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	mikem@ring3k.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:45702 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbZHCLzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:55:46 -0400
In-Reply-To: <20090727153548.7c0d9f85@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I have now tried again with the newest stable kernel (2.6.30.4), without
PaX and squashfs-lzma support. Still the same problem:

[~]# uname -a
Linux gibraltar3-esys-master 2.6.30.4 #9 SMP PREEMPT Fri Jul 31 15:32:55
UTC 2009 i686 GNU/Linux
[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  277.816049] sky2 0000:01:00.0:
error interrupt status=0xffffffff
[  277.822124] sky2 0000:01:00.0: PCI hardware error (0xffff)
[  277.827656] sky2 0000:01:00.0: PCI Express error (0xffffffff)
[  277.833449] sky2 wan: ram data read parity error
[  277.838107] sky2 wan: ram data write parity error
[  277.842852] sky2 wan: MAC parity error
[  277.846643] sky2 wan: RX parity error
[  277.850345] sky2 wan: TCP segmentation error
[  277.854688] BUG: unable to handle kernel NULL pointer dereference at
0000038d
[  277.858653] IP: [<f8050ca5>] sky2_mac_intr+0x30/0xc1 [sky2]
[  277.858653] *pde = 00000000
[  277.858653] Oops: 0000 [#1] PREEMPT SMP
[  277.858653] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
[  277.858653] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ipv6 evdev parport_pc parport serio_raw i2c_i801 pcspkr
i2c_core iTCO_wdt rng_core intel_agp loop aufs exportfs nls_utf8
nls_cp437 ide_generic sd_mod ide_gd_mod ata_generic pata_acpi skge
ata_piix piix ide_pci_generic ide_core sky2 thermal_sys
[  277.858653]
[  277.858653] Pid: 9423, comm: tlsmgr Not tainted (2.6.30.4 #9)
[  277.858653] EIP: 0060:[<f8050ca5>] EFLAGS: 00010286 CPU: 0
[  277.858653] EIP is at sky2_mac_intr+0x30/0xc1 [sky2]
[  277.858653] EAX: f8068f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff
[  277.858653] ESI: 00000000 EDI: f6901b80 EBP: f6acfce4 ESP: f6acfccc
[  277.858653]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  277.858653] Process tlsmgr (pid: 9423, ti=f6ace000 task=f7176e70
task.ti=f6ace000)
[  277.858653] Stack:
[  277.858653]  00000080 ff901b80 968c5f08 f71ed840 ffffffff ffffffff
f6acfd6c f80542d8
[  277.858653]  00000000 c181d260 00000040 f6901b88 f6acfd08 c04ee2b5
f6901b80 ffffffff
[  277.858653]  c022ded2 f71ef000 00000000 00000000 0000000f c181d260
00000000 00000246
[  277.858653] Call Trace:
[  277.858653]  [<f80542d8>] ? sky2_poll+0x1d2/0xb1e [sky2]
[  277.858653]  [<c04ee2b5>] ? _spin_unlock_irqrestore+0x31/0x44
[  277.858653]  [<c022ded2>] ? try_to_wake_up+0x291/0x2ac
[  277.858653]  [<c022df62>] ? wake_up_process+0x1b/0x2e
[  277.858653]  [<c04772f4>] ? __qdisc_run+0x73/0x1ca
[  277.858653]  [<c0463cc2>] ? net_rx_action+0x9e/0x1a2
[  277.858653]  [<c0237b5e>] ? __do_softirq+0xb2/0x188
[  277.858653]  [<c0237c73>] ? do_softirq+0x3f/0x5c
[  277.858653]  [<c0237dfd>] ? irq_exit+0x37/0x80
[  277.858653]  [<c0213cfd>] ? smp_apic_timer_interrupt+0x7c/0x9b
[  277.858653]  [<c02037dd>] ? apic_timer_interrupt+0x31/0x38
[  277.858653]  [<c0371524>] ? radix_tree_lookup_slot+0x34/0x79
[  277.858653]  [<c0284852>] ? find_get_page+0x34/0xc6
[  277.858653]  [<c0284c9e>] ? find_lock_page+0x21/0x67
[  277.858653]  [<c0285214>] ? filemap_fault+0x97/0x366
[  277.858653]  [<c0297054>] ? __do_fault+0x56/0x3b0
[  277.858653]  [<c02503a2>] ? getnstimeofday+0x5f/0xf3
[  277.858653]  [<c0252d85>] ? clockevents_program_event+0xe8/0x108
[  277.858653]  [<c0298f33>] ? handle_mm_fault+0x2b9/0x668
[  277.858653]  [<c024b121>] ? hrtimer_interrupt+0x13e/0x15f
[  277.858653]  [<c021d3f6>] ? do_page_fault+0x1fb/0x21b
[  277.858653]  [<c021d1fb>] ? do_page_fault+0x0/0x21b
[  277.858653]  [<c04ee72a>] ? error_code+0x7a/0x80
[  277.858653] Code: c7 56 53 89 d3 83 ec 0c 65 a1 14 00 00 00 89 45 f0
31 c0 8b 74 97 3c c1 e2 07 89 d0 05 08 0f 00 00 89 55 e8 03 07 8a 10 88
55 ef <f6> 86 8d 03 00 00 02 74 12 0f b6 c2 50 56 68 30 64 05 f8 e8 74
[  277.858653] EIP: [<f8050ca5>] sky2_mac_intr+0x30/0xc1 [sky2] SS:ESP
0068:f6acfccc
[  277.858653] CR2: 000000000000038d
[  278.173200] ---[ end trace bec12ce036036cbf ]---
[  278.177861] Kernel panic - not syncing: Fatal exception in interrupt
[  278.184259] Pid: 9423, comm: tlsmgr Tainted: G      D    2.6.30.4 #9
[  278.190654] Call Trace:
[  278.193140]  [<c04eb04e>] ? printk+0x1d/0x30
[  278.197452]  [<c04eaf8c>] panic+0x53/0xf8
[  278.201506]  [<c0206368>] oops_end+0x9f/0xbf
[  278.205817]  [<c021ceb4>] no_context+0x11a/0x135
[  278.210480]  [<c021d005>] __bad_area_nosemaphore+0x136/0x14f
[  278.216177]  [<c0374e68>] ? vsnprintf+0x91/0x332
[  278.220840]  [<c04ee2b5>] ? _spin_unlock_irqrestore+0x31/0x44
[  278.226622]  [<c04ee2b5>] ? _spin_unlock_irqrestore+0x31/0x44
[  278.232404]  [<c0232f3f>] ? release_console_sem+0x18b/0x1c9
[  278.238015]  [<c021d03b>] bad_area_nosemaphore+0x1d/0x34
[  278.243370]  [<c021d30b>] do_page_fault+0x110/0x21b
[  278.248287]  [<c021d1fb>] ? do_page_fault+0x0/0x21b
[  278.253209]  [<c04ee72a>] error_code+0x7a/0x80
[  278.257693]  [<c037007b>] ? kobject_uevent_env+0x42/0x387
[  278.263141]  [<f8050ca5>] ? sky2_mac_intr+0x30/0xc1 [sky2]
[  278.268673]  [<f80542d8>] sky2_poll+0x1d2/0xb1e [sky2]
[  278.273850]  [<c04ee2b5>] ? _spin_unlock_irqrestore+0x31/0x44
[  278.279632]  [<c022ded2>] ? try_to_wake_up+0x291/0x2ac
[  278.284818]  [<c022df62>] ? wake_up_process+0x1b/0x2e
[  278.289914]  [<c04772f4>] ? __qdisc_run+0x73/0x1ca
[  278.294750]  [<c0463cc2>] net_rx_action+0x9e/0x1a2
[  278.299578]  [<c0237b5e>] __do_softirq+0xb2/0x188
[  278.304321]  [<c0237c73>] do_softirq+0x3f/0x5c
[  278.308801]  [<c0237dfd>] irq_exit+0x37/0x80
[  278.313111]  [<c0213cfd>] smp_apic_timer_interrupt+0x7c/0x9b
[  278.318807]  [<c02037dd>] apic_timer_interrupt+0x31/0x38
[  278.324165]  [<c0371524>] ? radix_tree_lookup_slot+0x34/0x79
[  278.329869]  [<c0284852>] find_get_page+0x34/0xc6
[  278.334619]  [<c0284c9e>] find_lock_page+0x21/0x67
[  278.339447]  [<c0285214>] filemap_fault+0x97/0x366
[  278.344276]  [<c0297054>] __do_fault+0x56/0x3b0
[  278.348842]  [<c02503a2>] ? getnstimeofday+0x5f/0xf3
[  278.353847]  [<c0252d85>] ? clockevents_program_event+0xe8/0x108
[  278.359899]  [<c0298f33>] handle_mm_fault+0x2b9/0x668
[  278.364997]  [<c024b121>] ? hrtimer_interrupt+0x13e/0x15f
[  278.370445]  [<c021d3f6>] do_page_fault+0x1fb/0x21b
[  278.375364]  [<c021d1fb>] ? do_page_fault+0x0/0x21b
[  278.380287]  [<c04ee72a>] error_code+0x7a/0x80
[  278.384779] Rebooting in 30 seconds..

To allow easier debugging, I have now put our whole kernel tree up in a
public (read-only) git repository at
https://www.gibraltar.at/git/linux-2.6-gibraltar.git. The branch for
this kernel is origin/gibraltar-3.0, although the above dump was
produced by a version slightly "older" then HEAD, which did not yet have
the latest PaX patch applied (no PaX and no lzma-squashfs in this kernel).

Any hints/pointers/patches/etc. would be highly appreciated.

best regards,
Rene

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp20DYACgkQq7SPDcPCS96R3QCdGTJsPiJGLfiWUZk67f6wms9Y
rVgAoPMO2hnT3jwRtY0Qz40NRp0DpKxT
=8NsP
-----END PGP SIGNATURE-----
