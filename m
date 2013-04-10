From: CAI Qian <caiqian@redhat.com>
Subject: [BUG] Fatal exception in interrupt - nf_nat_cleanup_conntrack
 during IPv6 tests
Date: Tue, 9 Apr 2013 23:17:58 -0400 (EDT)
Message-ID: <1089062823.1991307.1365563878922.JavaMail.root@redhat.com>
References: <605030311.1990960.1365563720663.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <605030311.1990960.1365563720663.JavaMail.root@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just hit this very often during IPv6 tests in both the latest stable
and mainline kernel.

[ 3597.179161] general protection fault: 0000 [#1] SMP  
[ 3597.206166] Modules linked in: btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_files(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F) arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_koi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) nf_nat_ipv4(F-) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) coretemp(F) ixgbe(F) kvm_intel(F) kvm(F) ptp(F) iTCO_wdt(F) iTCO_vend
 or_support(F) crc32c_intel(F) pps_core(F) mdio(F) ghash_clmulni_intel(F) e1000e(F) lpc_ich(F) dca(F) hpilo(F) hpwdt(F) mfd_core(F) pcspkr(F) serio_raw(F) microcode(F) xfs(F) libcrc32c(F) ata_generic(F) mgag200(F) i2c_algo_bit(F) pata_acpi(F) drm_kms_helper(F) sd_mod(F) crc_t10dif(F) ttm(F) ata_piix(F) drm(F) hpsa(F) libata(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: iptable_nat] 
[ 3597.750154] CPU 3  
[ 3597.759743] Pid: 0, comm: swapper/3 Tainted: GF            3.8.5+ #1 HP ProLiant DL120 G7 
[ 3597.804861] RIP: 0010:[<ffffffffa03227f2>]  [<ffffffffa03227f2>] nf_nat_cleanup_conntrack+0x42/0x70 [nf_nat] 
[ 3597.855207] RSP: 0018:ffff880202c63d40  EFLAGS: 00010246 
[ 3597.881350] RAX: 0000000000000000 RBX: ffff8801ac7bec28 RCX: ffff8801d0eedbe0 
[ 3597.917226] RDX: dead000000200200 RSI: 0000000000000011 RDI: ffffffffa03265b8 
[ 3597.952432] RBP: ffff880202c63d50 R08: 000003451753e1c0 R09: dead000000200200 
[ 3597.989578] R10: 0000000000000000 R11: 0000000000000004 R12: ffff8801ac7beba8 
[ 3598.026430] R13: ffff8801d0eedb58 R14: ffffffffa02fe6a0 R15: ffff8801d0eedb58 
[ 3598.061575] FS:  0000000000000000(0000) GS:ffff880202c60000(0000) knlGS:0000000000000000 
[ 3598.102232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[ 3598.131044] CR2: 000000000280e508 CR3: 00000000018f2000 CR4: 00000000000407e0 
[ 3598.166274] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3598.202110] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3598.238221] Process swapper/3 (pid: 0, threadinfo ffff8801ffaee000, task ffff8801ffaf5010) 
[ 3598.282292] Stack: 
[ 3598.292908]  0000000000000000 0000000000000001 ffff880202c63d80 ffffffffa0305bb4 
[ 3598.332820]  ffffffff8161646d ffff8801d0eedb58 ffffffff819a5d40 0000000000000100 
[ 3598.371541]  ffff880202c63da0 ffffffffa02fd3fe ffff8801d0eedb58 ffffffff819a5d40 
[ 3598.409036] Call Trace: 
[ 3598.421036]  <IRQ>  
[ 3598.430467]  [<ffffffffa0305bb4>] __nf_ct_ext_destroy+0x44/0x60 [nf_conntrack] 
[ 3598.467970]  [<ffffffff8161646d>] ? notifier_call_chain+0x4d/0x70 
[ 3598.499191]  [<ffffffffa02fd3fe>] nf_conntrack_free+0x2e/0x70 [nf_conntrack] 
[ 3598.534121]  [<ffffffffa02febed>] destroy_conntrack+0xbd/0x110 [nf_conntrack] 
[ 3598.569981]  [<ffffffff81532187>] nf_conntrack_destroy+0x17/0x20 
[ 3598.599579]  [<ffffffffa02fe77c>] death_by_timeout+0xdc/0x1b0 [nf_conntrack] 
[ 3598.634842]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3598.669352]  [<ffffffff81070c9a>] call_timer_fn+0x3a/0x120 
[ 3598.696383]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3598.730896]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3598.762416]  [<ffffffff81072a2e>] run_timer_softirq+0x1fe/0x2b0 
[ 3598.793980]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3598.826872]  [<ffffffff8106a8f0>] __do_softirq+0xd0/0x210 
[ 3598.855564]  [<ffffffff8101b883>] ? native_sched_clock+0x13/0x80 
[ 3598.887548]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3598.920717]  [<ffffffff8161bddc>] call_softirq+0x1c/0x30 
[ 3598.947948]  [<ffffffff810162a5>] do_softirq+0x75/0xb0 
[ 3598.973283]  [<ffffffff8106abc5>] irq_exit+0xb5/0xc0 
[ 3598.998710]  [<ffffffff8161c75e>] smp_apic_timer_interrupt+0x6e/0x99 
[ 3599.030033]  [<ffffffff8161b69d>] apic_timer_interrupt+0x6d/0x80 
[ 3599.060308]  <EOI>  
[ 3599.069737]  [<ffffffff814bc830>] ? cpuidle_wrap_enter+0x50/0xa0 
[ 3599.100918]  [<ffffffff814bc829>] ? cpuidle_wrap_enter+0x49/0xa0 
[ 3599.130548]  [<ffffffff814bc890>] cpuidle_enter_tk+0x10/0x20 
[ 3599.158994]  [<ffffffff814bc4c9>] cpuidle_idle_call+0xa9/0x260 
[ 3599.187843]  [<ffffffff8101d3cf>] cpu_idle+0xaf/0x120 
[ 3599.213581]  [<ffffffff815fc461>] start_secondary+0x255/0x257 
[ 3599.241868] Code: 83 ec 08 0f b6 58 11 84 db 74 43 48 01 c3 48 83 7b 20 00 74 39 48 c7 c7 b8 65 32 a0 e8 98 fc 2e e1 48 8b 03 48 8b 53 08 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 ba 00 02 20 00 00 00 ad de 48 c7  
[ 3599.337037] RIP  [<ffffffffa03227f2>] nf_nat_cleanup_conntrack+0x42/0x70 [nf_nat] 
[ 3599.378020]  RSP <ffff880202c63d40> 
[ 3599.402446] bad: scheduling from the idle thread! 
[ 3599.428245] Pid: 0, comm: swapper/3 Tainted: GF            3.8.5+ #1 
[ 3599.463162] Call Trace: 
[ 3599.476367]  <IRQ>  [<ffffffff8109b47f>] dequeue_task_idle+0x2f/0x40 
[ 3599.508112]  [<ffffffff810947de>] dequeue_task+0x8e/0xa0 
[ 3599.535485]  [<ffffffff81095223>] deactivate_task+0x23/0x30 
[ 3599.563276]  [<ffffffff81610d49>] __schedule+0x599/0x7b0 
[ 3599.590450]  [<ffffffff8101b8f9>] ? sched_clock+0x9/0x10 
[ 3599.616588]  [<ffffffff81611289>] schedule+0x29/0x70 
[ 3599.641650]  [<ffffffff8160f7a3>] schedule_timeout+0x163/0x2b0 
[ 3599.670525]  [<ffffffff8106ab91>] ? irq_exit+0x81/0xc0 
[ 3599.696649]  [<ffffffff81071710>] ? __internal_add_timer+0x130/0x130 
[ 3599.728262]  [<ffffffff8160f90e>] schedule_timeout_uninterruptible+0x1e/0x20 
[ 3599.763734]  [<ffffffff81073160>] msleep+0x20/0x30 
[ 3599.787466]  [<ffffffffa009beff>] mga_crtc_dpms+0x10f/0x1b0 [mgag200] 
[ 3599.820051]  [<ffffffffa009bdf0>] ? mga_encoder_destroy+0x30/0x30 [mgag200] 
[ 3599.854791]  [<ffffffffa00c39e2>] drm_helper_connector_dpms+0x72/0x130 [drm_kms_helper] 
[ 3599.897275]  [<ffffffffa00c2090>] drm_fb_helper_dpms.isra.14+0xa0/0xf0 [drm_kms_helper] 
[ 3599.941004]  [<ffffffffa00c2126>] drm_fb_helper_blank+0x46/0x80 [drm_kms_helper] 
[ 3599.980813]  [<ffffffff81342656>] fb_blank+0x56/0xc0 
[ 3600.008422]  [<ffffffff8134f70b>] fbcon_blank+0x22b/0x2e0 
[ 3600.037769]  [<ffffffff81063849>] ? console_unlock+0x1e9/0x3f0 
[ 3600.069907]  [<ffffffff810716f3>] ? __internal_add_timer+0x113/0x130 
[ 3600.101532]  [<ffffffff81071d00>] ? internal_add_timer+0x20/0x50 
[ 3600.131757]  [<ffffffff81073041>] ? mod_timer+0x131/0x210 
[ 3600.158302]  [<ffffffff813c3474>] do_unblank_screen+0xb4/0x1e0 
[ 3600.187752]  [<ffffffff813c35b0>] unblank_screen+0x10/0x20 
[ 3600.214798]  [<ffffffff813066c9>] bust_spinlocks+0x19/0x40 
[ 3600.242523]  [<ffffffff816135cf>] oops_end+0x3f/0xe0 
[ 3600.266990]  [<ffffffff81017848>] die+0x58/0x90 
[ 3600.290099]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3600.324031]  [<ffffffff8161309a>] do_general_protection+0xda/0x160 
[ 3600.355466]  [<ffffffff81612a28>] general_protection+0x28/0x30 
[ 3600.385088]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3600.419965]  [<ffffffffa03227f2>] ? nf_nat_cleanup_conntrack+0x42/0x70 [nf_nat] 
[ 3600.457872]  [<ffffffffa0305bb4>] __nf_ct_ext_destroy+0x44/0x60 [nf_conntrack] 
[ 3600.496919]  [<ffffffff8161646d>] ? notifier_call_chain+0x4d/0x70 
[ 3600.531231]  [<ffffffffa02fd3fe>] nf_conntrack_free+0x2e/0x70 [nf_conntrack] 
[ 3600.569264]  [<ffffffffa02febed>] destroy_conntrack+0xbd/0x110 [nf_conntrack] 
[ 3600.608912]  [<ffffffff81532187>] nf_conntrack_destroy+0x17/0x20 
[ 3600.638505]  [<ffffffffa02fe77c>] death_by_timeout+0xdc/0x1b0 [nf_conntrack] 
[ 3600.673851]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3600.708435]  [<ffffffff81070c9a>] call_timer_fn+0x3a/0x120 
[ 3600.735880]  [<ffffffffa02fe6a0>] ? kill_report+0x180/0x180 [nf_conntrack] 
[ 3600.770429]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3600.800481]  [<ffffffff81072a2e>] run_timer_softirq+0x1fe/0x2b0 
[ 3600.830378]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3600.860402]  [<ffffffff8106a8f0>] __do_softirq+0xd0/0x210 
[ 3600.887542]  [<ffffffff8101b883>] ? native_sched_clock+0x13/0x80 
[ 3600.917405]  [<ffffffff814bbe40>] ? cpufreq_p4_target+0x130/0x130 
[ 3600.948576]  [<ffffffff8161bddc>] call_softirq+0x1c/0x30 
[ 3600.975042]  [<ffffffff810162a5>] do_softirq+0x75/0xb0 
[ 3601.001068]  [<ffffffff8106abc5>] irq_exit+0xb5/0xc0 
[ 3601.026576]  [<ffffffff8161c75e>] smp_apic_timer_interrupt+0x6e/0x99 
[ 3601.061371]  [<ffffffff8161b69d>] apic_timer_interrupt+0x6d/0x80 
[ 3601.093649]  <EOI>  [<ffffffff814bc830>] ? cpuidle_wrap_enter+0x50/0xa0 
[ 3601.129895]  [<ffffffff814bc829>] ? cpuidle_wrap_enter+0x49/0xa0 
[ 3601.161286]  [<ffffffff814bc890>] cpuidle_enter_tk+0x10/0x20 
[ 3601.189765]  [<ffffffff814bc4c9>] cpuidle_idle_call+0xa9/0x260 
[ 3601.218496]  [<ffffffff8101d3cf>] cpu_idle+0xaf/0x120 
[ 3601.243956]  [<ffffffff815fc461>] start_secondary+0x255/0x257 
[ 3601.273220] BUG: unable to handle kernel NULL pointer dereference at           (null) 
[ 3601.312563] IP: [<          (null)>]           (null) 
[ 3601.337599] PGD 1b9d80067 PUD 1e62d2067 PMD 0  
[ 3601.360361] Oops: 0010 [#2] SMP  
[ 3601.376324] Modules linked in: btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_files(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F) arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_koi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) nf_nat_ipv4(F-) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) coretemp(F) ixgbe(F) kvm_intel(F) kvm(F) ptp(F) iTCO_wdt(F) iTCO_vend
 or_support(F) crc32c_intel(F) pps_core(F) mdio(F) ghash_clmulni_intel(F) e1000e(F) lpc_ich(F) dca(F) hpilo(F) hpwdt(F) mfd_core(F) pcspkr(F) serio_raw(F) microcode(F) xfs(F) libcrc32c(F) ata_generic(F) mgag200(F) i2c_algo_bit(F) pata_acpi(F) drm_kms_helper(F) sd_mod(F) crc_t10dif(F) ttm(F) ata_piix(F) drm(F) hpsa(F) libata(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: iptable_nat] 
[ 3601.922124] CPU 3  
[ 3601.931628] Pid: 63862, comm: grep Tainted: GF            3.8.5+ #1 HP ProLiant DL120 G7 
[ 3601.973462] RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null) 
[ 3602.010902] RSP: 0000:ffff8801b04efcf0  EFLAGS: 00010046 
[ 3602.037249] RAX: ffffffff81631ac0 RBX: ffff8801ffaf5010 RCX: 000000001048f4fc 
[ 3602.073506] RDX: 0000000000000005 RSI: ffff8801ffaf5010 RDI: ffff880202c74180 
[ 3602.112346] RBP: ffff8801b04efd18 R08: 0000000000000000 R09: 0000000000000000 
[ 3602.150489] R10: 0000000000000000 R11: 000000000000bbe2 R12: ffff880202c74180 
[ 3602.189458] R13: 0000000000000005 R14: 0000000000000246 R15: ffff880202c74180 
[ 3602.227532] FS:  00007fe849139740(0000) GS:ffff880202c60000(0000) knlGS:0000000000000000 
[ 3602.270418] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[ 3602.298692] CR2: 0000000000000000 CR3: 00000001ea35d000 CR4: 00000000000407e0 
[ 3602.334682] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3602.370618] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3602.407160] Process grep (pid: 63862, threadinfo ffff8801b04ee000, task ffff8801ff9fb560) 
[ 3602.448654] Stack: 
[ 3602.458587]  ffffffff81094856 ffff8801fb5406c0 ffff8801ffaf5010 ffff880202c74180 
[ 3602.496119]  0000000000000000 ffff8801b04efd28 ffffffff810951f3 ffff8801b04efd48 
[ 3602.533501]  ffffffff8109564c ffff8801ffaf5010 ffff8801ffaf57f4 ffff8801b04efda8 
[ 3602.569906] Call Trace: 
[ 3602.582433]  [<ffffffff81094856>] ? enqueue_task+0x66/0x80 
[ 3602.609676]  [<ffffffff810951f3>] activate_task+0x23/0x30 
[ 3602.636830]  [<ffffffff8109564c>] ttwu_do_activate.constprop.78+0x3c/0x70 
[ 3602.672787]  [<ffffffff81097cbc>] try_to_wake_up+0x1dc/0x2d0 
[ 3602.703479]  [<ffffffff81071710>] ? __internal_add_timer+0x130/0x130 
[ 3602.737967]  [<ffffffff81097e17>] wake_up_process+0x27/0x50 
[ 3602.767596]  [<ffffffff8107171e>] process_timeout+0xe/0x10 
[ 3602.796510]  [<ffffffff81070c9a>] call_timer_fn+0x3a/0x120 
[ 3602.823533]  [<ffffffff81071710>] ? __internal_add_timer+0x130/0x130 
[ 3602.855717]  [<ffffffff81072a2e>] run_timer_softirq+0x1fe/0x2b0 
[ 3602.885014]  [<ffffffff8106a8f0>] __do_softirq+0xd0/0x210 
[ 3602.912611]  [<ffffffff8101b883>] ? native_sched_clock+0x13/0x80 
[ 3602.942503]  [<ffffffff8161bddc>] call_softirq+0x1c/0x30 
[ 3602.969510]  [<ffffffff810162a5>] do_softirq+0x75/0xb0 
[ 3602.994957]  [<ffffffff8106abc5>] irq_exit+0xb5/0xc0 
[ 3603.020036]  [<ffffffff8161c75e>] smp_apic_timer_interrupt+0x6e/0x99 
[ 3603.051018]  [<ffffffff8161b69d>] apic_timer_interrupt+0x6d/0x80 
[ 3603.081602] Code:  Bad RIP value. 
[ 3603.097893] RIP  [<          (null)>]           (null) 
[ 3603.123740]  RSP <ffff8801b04efcf0> 
[ 3603.140928] CR2: 0000000000000000 
[ 3603.157190] ---[ end trace 62e555f1b47d35f6 ]--- 
[ 3603.181234] Kernel panic - not syncing: Fatal exception in interrupt 

CAI Qian
