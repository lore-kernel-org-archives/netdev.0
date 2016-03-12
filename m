From: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Subject: SYN flooding on port 80 + DMAR:[DMA Write] faults
Date: Sun, 13 Mar 2016 00:15:22 +0100
Message-ID: <56E4A30A.2060800@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today my server (64 bit hardened Gentoo kernel) was faced a SYN-flood attack.
I do wonder if the DMAR events points to an issue in the kernel ?


Mar 12 21:56:51 ms-magpie kernel: [99582.831584] TCP: request_sock_TCP: Possible SYN flooding on port 80. Sending cookies.  Check SNMP counters.
Mar 12 21:57:17 ms-magpie kernel: [99609.502567] ------------[ cut here ]------------
Mar 12 21:57:17 ms-magpie kernel: [99609.502575] WARNING: CPU: 2 PID: 18218 at net/sched/sch_generic.c:303 dev_watchdog+0x235/0x240()
Mar 12 21:57:17 ms-magpie kernel: [99609.502577] NETDEV WATCHDOG: enp3s0 (r8169): transmit queue 0 timed out
Mar 12 21:57:17 ms-magpie kernel: [99609.502578] Modules linked in: af_packet nf_log_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_log_ipv4 nf_log_common xt_LOG xt_multiport nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter ip_tables hmac drbg tpm_tis tpm thermal processor atkbd i2c_i801 i2c_core button x86_pkg_temp_thermal
Mar 12 21:57:17 ms-magpie kernel: [99609.502601] CPU: 2 PID: 18218 Comm: cc1plus Not tainted 4.4.5-hardened #1
Mar 12 21:57:17 ms-magpie kernel: [99609.502603] Hardware name: System manufacturer System Product Name/P8H77-M PRO, BIOS 0922 09/10/2012
Mar 12 21:57:17 ms-magpie kernel: [99609.502605]  ffffffff8b20482b 0000000000000286 0000000000000000 ffff88041fa83d98
Mar 12 21:57:17 ms-magpie kernel: [99609.502608]  ffffffff8aad5247 0000000000000007 ffff88041fa83de0 ffffffff8afb6257
Mar 12 21:57:17 ms-magpie kernel: [99609.502611]  ffff88041fa83dd0 ffffffff8a879e8c ffffffff8afb6257 000000000000012f
Mar 12 21:57:17 ms-magpie kernel: [99609.502614] Call Trace:
Mar 12 21:57:17 ms-magpie kernel: [99609.502616]  <IRQ>  [<ffffffff8aad5247>] dump_stack+0x4e/0x77
Mar 12 21:57:17 ms-magpie kernel: [99609.502625]  [<ffffffff8a879e8c>] warn_slowpath_common+0x7c/0xc0
Mar 12 21:57:17 ms-magpie kernel: [99609.502627]  [<ffffffff8a879f2b>] warn_slowpath_fmt+0x5b/0x70
Mar 12 21:57:17 ms-magpie kernel: [99609.502631]  [<ffffffff8a8a9293>] ? __update_cpu_load+0xe3/0x140
Mar 12 21:57:17 ms-magpie kernel: [99609.502634]  [<ffffffff8ac85cf5>] dev_watchdog+0x235/0x240
Mar 12 21:57:17 ms-magpie kernel: [99609.502637]  [<ffffffff8ac85ac0>] ? dev_deactivate_queue+0x70/0x70
Mar 12 21:57:17 ms-magpie kernel: [99609.502640]  [<ffffffff8a8cfdee>] call_timer_fn.isra.24+0x2e/0x90
Mar 12 21:57:17 ms-magpie kernel: [99609.502643]  [<ffffffff8ac85ac0>] ? dev_deactivate_queue+0x70/0x70
Mar 12 21:57:17 ms-magpie kernel: [99609.502645]  [<ffffffff8a8d0074>] run_timer_softirq+0x224/0x3b0
Mar 12 21:57:17 ms-magpie kernel: [99609.502649]  [<ffffffff8a8de20f>] ? clockevents_program_event+0x7f/0x120
Mar 12 21:57:17 ms-magpie kernel: [99609.502652]  [<ffffffff8a87db3f>] __do_softirq+0xef/0x1e0
Mar 12 21:57:17 ms-magpie kernel: [99609.502654]  [<ffffffff8a87dd60>] irq_exit+0x80/0x90
Mar 12 21:57:17 ms-magpie kernel: [99609.502657]  [<ffffffff8a839f2f>] smp_apic_timer_interrupt+0x4f/0x70
Mar 12 21:57:17 ms-magpie kernel: [99609.502662]  [<ffffffff8ad5732b>] apic_timer_interrupt+0x8b/0x90
Mar 12 21:57:17 ms-magpie kernel: [99609.502663]  <EOI>
Mar 12 21:57:17 ms-magpie kernel: [99609.502665] ---[ end trace 10603242d3d9404d ]---
Mar 12 21:57:17 ms-magpie kernel: [99609.519275] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:57:29 ms-magpie kernel: [99621.522005] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:57:41 ms-magpie kernel: [99633.518745] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:57:53 ms-magpie kernel: [99645.514461] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:58:05 ms-magpie kernel: [99657.525221] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:58:17 ms-magpie kernel: [99669.519938] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:58:35 ms-magpie kernel: [99687.513517] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:58:47 ms-magpie kernel: [99699.518283] r8169 0000:03:00.0 enp3s0: link up
Mar 12 21:58:59 ms-magpie kernel: [99711.512010] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:00:41 ms-magpie kernel: [99813.511713] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:00:53 ms-magpie kernel: [99825.510459] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:01:05 ms-magpie kernel: [99837.508171] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:01:05 ms-magpie kernel: [99837.518271] DMAR: DRHD: handling fault status reg 3
Mar 12 22:01:05 ms-magpie kernel: [99837.518277] DMAR: DMAR:[DMA Write] Request device [03:00.0] fault addr ffbfb000
Mar 12 22:01:05 ms-magpie kernel: [99837.518277] DMAR:[fault reason 05] PTE Write access is not set
Mar 12 22:01:05 ms-magpie kernel: [99837.523139] DMAR: DRHD: handling fault status reg 3
Mar 12 22:01:05 ms-magpie kernel: [99837.523144] DMAR: DMAR:[DMA Write] Request device [03:00.0] fault addr ffbf8000
Mar 12 22:01:05 ms-magpie kernel: [99837.523144] DMAR:[fault reason 05] PTE Write access is not set
Mar 12 22:01:05 ms-magpie kernel: [99837.523213] DMAR: DRHD: handling fault status reg 3
Mar 12 22:01:05 ms-magpie kernel: [99837.523217] DMAR: DMAR:[DMA Write] Request device [03:00.0] fault addr ffbf5000
Mar 12 22:01:05 ms-magpie kernel: [99837.523217] DMAR:[fault reason 05] PTE Write access is not set
Mar 12 22:01:05 ms-magpie kernel: [99837.523221] DMAR: DRHD: handling fault status reg 3
Mar 12 22:01:05 ms-magpie kernel: [99837.523227] DMAR: DMAR:[DMA Write] Request device [03:00.0] fault addr ffbf3000
Mar 12 22:01:05 ms-magpie kernel: [99837.523227] DMAR:[fault reason 05] PTE Write access is not set
Mar 12 22:01:05 ms-magpie kernel: [99837.523241] DMAR: DRHD: handling fault status reg 3
...
Mar 12 22:01:05 ms-magpie kernel: [99837.523507] DMAR: DMAR:[DMA Write] Request device [03:00.0] fault addr ffbcf000
Mar 12 22:01:05 ms-magpie kernel: [99837.523507] DMAR:[fault reason 05] PTE Write access is not set
Mar 12 22:01:17 ms-magpie kernel: [99849.505904] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:01:29 ms-magpie kernel: [99861.507679] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:01:41 ms-magpie kernel: [99873.509113] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:01:53 ms-magpie kernel: [99885.507166] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:02:05 ms-magpie kernel: [99897.509888] r8169 0000:03:00.0 enp3s0: link up
Mar 12 22:02:17 ms-magpie kernel: [99909.508613] r8169 0000:03:00.0 enp3s0: link up
...
Mar 13 00:00:35 ms-magpie kernel: [107007.349774] r8169 0000:03:00.0 enp3s0: link up
Mar 13 00:01:23 ms-magpie kernel: [107055.350767] r8169 0000:03:00.0 enp3s0: link up
<rebooted>

-- 
Toralf
PGP: C4EACDDE 0076E94E, OTR: 420E74C8 30246EE7
