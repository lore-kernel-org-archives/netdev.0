From: Frans van Berckel <fberckel@xs4all.nl>
Subject: netdev watchdog enp1s0 (tg3): transmit queue 0 timed out
Date: Fri, 01 Sep 2017 08:10:08 +0200
Message-ID: <1504246208.2050.15.camel@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud7.xs4all.net ([194.109.24.28]:58315 "EHLO
        lb2-smtp-cloud7.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751014AbdIAGRP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 02:17:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear NetDev Team,

I am new to this machine. On a marketplace website I
bought a Dell PowerEdge sc1435. Booting a today's Fedora (or even a
Debian) amd64 Live CD from usb, and goes all fine.  

[    0.000000] Linux version 4.11.8-300.fc26.x86_64 (mockbuild@bkernel0
2.phx2.fedoraproject.org) (gcc version 7.1.1 20170622 (Red Hat 7.1.1-
3) (GCC) ) #1 SMP Thu Jun 29 20:09:48 UTC 2017

Until .. I plunged in the ethernet cable for the first time. I have got
console output, what frightens me a bit. It's about the driver for
bcm95721. This kernel does a DMA Status error. And next it's calling a
watchdog for enp1s0 (tg3): transmit queue 0 timed out.

[  237.169194] tg3 0000:01:00.0 enp1s0: Link is up at 1000 Mbps, full
du
plex
[  237.169335] tg3 0000:01:00.0 enp1s0: Flow control is on for TX
and
on for RX
[  237.169375] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link
becomes
ready
[  243.683910] tg3 0000:01:00.0 enp1s0: DMA Status
error.  Resetting
chip.
[  243.759610] hrtimer: interrupt took 9464192 ns
[  245.317566] tg3 0000:01:00.0 enp1s0: 0x00000000: 0x165914e4,
0x00100406, 0x02000021, 0x00000010

<snap> a long list of likely the same type of error codes.

[  245.760055] tg3 0000:01:00.0 enp1s0: 0x00007810: 0x00000000,
0x00000060, 0x0000000d, 0x00000000
[  245.762065] tg3 0000:01:00.0 enp1s0: 0: Host status block
[00000005:00000016:(0000:0007:0000):(0007:000c)]
[  245.764128] tg3 0000:01:00.0 enp1s0: 0: NAPI info
[00000015:00000015:(000f:000c:01ff):0006:(00ce:0000:0000:0000)]
[  245.867391] tg3 0000:01:00.0: tg3_stop_block timed out, ofs=2c00
enable_bit=2
[  245.971098] tg3 0000:01:00.0: tg3_stop_block timed out, ofs=4800
enable_bit=2
[  245.993343] tg3 0000:01:00.0 enp1s0: Link is down
[  249.731158] tg3 0000:01:00.0 enp1s0: Link is up at 1000 Mbps, full
duplex
[  249.731336] tg3 0000:01:00.0 enp1s0: Flow control is on for TX and
on for RX
[  254.944022] ------------[ cut here ]------------
[  254.945010] WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:316
dev_watchdog+0x221/0x230
[  254.945010] NETDEV WATCHDOG: enp1s0 (tg3): transmit queue 0 timed
out
[  254.945010] Modules linked in: xt_CHECKSUM ipt_MASQUERADE
nf_nat_masquerade_ipv4 tun fuse nf_conntrack_netbios_ns
nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6
xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_raw ip6table_security iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter
ebtables ip6table_filter ip6_tables powernow_k8 amd64_edac_mod
edac_mce_amd edac_core kvm_amd kvm irqbypass amdkfd amd_iommu_v2 dcdbas
radeon k8temp ipmi_ssif i2c_algo_bit ttm drm_kms_helper drm ipmi_si
ipmi_devintf tpm_tis ipmi_msghandler tpm_tis_core tpm i2c_piix4 shpchp
nls_utf8 isofs squashfs ata_generic
[  254.945010]  pata_acpi uas usb_storage 8021q garp stp llc mrp
serio_raw tg3 sata_sil24 ptp pps_core pata_serverworks sunrpc
scsi_transport_iscsi loop
[  254.945010] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.11.8-
300.fc26.x86_64 #1
[  254.945010] Hardware name: Dell Inc. PowerEdge SC1435/0YR707, BIOS
2.2.5 03/21/2008
[  254.945010] Call Trace:
[  254.945010]  <IRQ>
[  254.945010]  dump_stack+0x63/0x84
[  254.945010]  __warn+0xcb/0xf0
[  254.945010]  warn_slowpath_fmt+0x5a/0x80
[  254.945010]  dev_watchdog+0x221/0x230
[  254.945010]  ? qdisc_rcu_free+0x50/0x50
[  254.945010]  call_timer_fn+0x33/0x130
[  254.945010]  run_timer_softirq+0x3ee/0x440
[  254.945010]  ? ktime_get+0x40/0xb0
[  254.945010]  ? lapic_next_event+0x1d/0x30
[  254.945010]  __do_softirq+0xea/0x2e3
[  254.945010]  irq_exit+0xfb/0x100
[  254.945010]  smp_apic_timer_interrupt+0x3d/0x50
[  254.945010]  apic_timer_interrupt+0x93/0xa0
[  254.945010] RIP: 0010:native_safe_halt+0x6/0x10
[  254.945010] RSP: 0018:ffffbabf4038be60 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff10
[  254.945010] RAX: 6874754100002d40 RBX: ffff926d39d04880 RCX:
0000000000000000
[  254.945010] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
0000000000000000
[  254.945010] RBP: ffffbabf4038be60 R08: ffff926d3d052ae0 R09:
0000000000000000
[  254.945010] R10: 0000000000000000 R11: 0000000000000000 R12:
0000000000000001
[  254.945010] R13: ffff926d39d04880 R14: 0000000000000000 R15:
0000000000000000
[  254.945010]  </IRQ>
[  254.945010]  default_idle+0x20/0xe0
[  254.945010]  amd_e400_idle+0x3f/0x50
[  254.945010]  arch_cpu_idle+0xf/0x20
[  254.945010]  default_idle_call+0x23/0x30
[  254.945010]  do_idle+0x170/0x200
[  254.945010]  cpu_startup_entry+0x71/0x80
[  254.945010]  start_secondary+0x154/0x190
[  254.945010]  start_cpu+0x14/0x14
[  255.080137] ---[ end trace 25a535e6d8610c90 ]---
[  255.080137] tg3 0000:01:00.0 enp1s0: transmit timed out, resetting

And resetting is what 'he' does again and again. Until you take out the
UTP cable. This counts for the second ethernet port as well. Is there
something with the machine bios or a setting that i can switch? Or did
i find a driver bug? And do i need to find out what's wrong.

Thanks,

Frans van Berckel
