From: Mike Galbraith <bitbucket@online.de>
Subject: Re: OOPS in nf_ct_unlink_expect_report using Polycom RealPresence
 Mobile
Date: Fri, 31 Jan 2014 14:17:03 +0100
Message-ID: <1391174223.6395.3.camel@marge.simpson.net>
References: <20140131120527.Horde.-3YzQu5S8WWBx7vuVVNdBA2@aws-it.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: astx <astx@aws-it.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140131120527.Horde.-3YzQu5S8WWBx7vuVVNdBA2@aws-it.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(CC netdev)

On Fri, 2014-01-31 at 12:05 +0100, astx wrote: 
> Using Polycom video conferencing software my homebrew linux NAT router  
> crashes with attached kernel oops message.
> This error can be reproduced also using kernel 3.2.54. Kernel 2.6.35  
> seems to be stable.
> 
> Disabling nf_nat_h323 and nf_conntrack_h323 avoids crash - but video  
> conferencing software is no more usable.
> 
> 
> ===================================================================================
>   BUG: unable to handle kernel paging request at 00100104
> IP: [<f8214f07>] nf_ct_unlink_expect_report+0x57/0xf0 [nf_conntrack]
> *pdpt = 00000000359aa001 *pde = 0000000000000000
> Oops: 0002 [#1] SMP
> Modules linked in: nf_conntrack_netlink nfnetlink xt_mac xt_TCPMSS  
> ipt_MASQUERADE
>   xt_pkttype xt_multiport xt_REDIRECT xt_nat iptable_mangle xt_LOG  
> xt_limit af_packet
>   act_mirred cls_u32 sch_ingress sch_hfsc ifb xt_tcpudp ip6t_REJECT ipt_REJECT
>   ip6table_raw iptable_raw xt_CT iptable_filter nf_nat_pptp nf_nat_proto_gre
>   nf_conntrack_proto_udplite nf_conntrack_proto_dccp ip6table_mangle  
> iptable_nat
>   nf_nat_ipv4 nf_nat_sip nf_nat_irc nf_nat_snmp_basic nf_conntrack_snmp
>   nf_conntrack_broadcast nf_nat_h323 nf_nat_tftp nf_nat_ftp nf_nat  
> nf_conntrack_h323
>   nf_conntrack_tftp nf_conntrack_proto_sctp nf_conntrack_sip nf_conntrack_irc
>   nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_ftp nf_conntrack_ipv4
>   nf_defrag_ipv4 ip_tables xt_conntrack nf_conntrack ip6table_filter ip6_tables
>   x_tables padlock_sha padlock_aes e_powersaver freq_table mperf via_cputemp
>   hwmon_vid serio_raw pcspkr i2c_viapro ehci_pci fan thermal processor 8139too
>   sg thermal_sys button shpchp 8139cp pci_hotplug mii via_agp ext4 crc16 jbd2
>   pata_via sata_via libata sd_mod scsi_mod ohci_hcd uhci_hcd ehci_hcd
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.28-9500-smp_m #1
> Hardware name:    /CN700-8237, BIOS 6.00 PG 08/30/2007
> task: c07ce180 ti: f6408000 task.ti: c07c2000
> EIP: 0060:[<f8214f07>] EFLAGS: 00210206 CPU: 0
> EIP is at nf_ct_unlink_expect_report+0x57/0xf0 [nf_conntrack]
> EAX: 00100100 EBX: eb636bc0 ECX: 00000000 EDX: eb461540
> ESI: c0804e00 EDI: eb461544 EBP: f6409f08 ESP: f6409eec
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> CR0: 8005003b CR2: 00100104 CR3: 359d4000 CR4: 000006b0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Stack:
>   00000000 00200286 f6409f08 c0244bd8 eb636bc0 00100100 00000000 f6409f18
>   f8215687 f598ede8 c0804e00 f6409f28 f8211c99 f598ede8 f598ee50 f6409f5c
>   f8212e5e 00000003 00000000 00000000 00000004 eb461514 f598ede8 00000000
> Call Trace:
>   [<c0244bd8>] ? del_timer+0x48/0x70
>   [<f8215687>] nf_ct_remove_expectations+0x47/0x60 [nf_conntrack]
>   [<f8211c99>] nf_ct_delete_from_lists+0x59/0x90 [nf_conntrack]
>   [<f8212e5e>] death_by_timeout+0x14e/0x1c0 [nf_conntrack]
>   [<f8212d10>] ? nf_conntrack_set_hashsize+0x190/0x190 [nf_conntrack]
>   [<c024442d>] call_timer_fn+0x1d/0x80
>   [<c024461e>] run_timer_softirq+0x18e/0x1a0
>   [<f8212d10>] ? nf_conntrack_set_hashsize+0x190/0x190 [nf_conntrack]
>   [<c023e6f3>] __do_softirq+0xa3/0x170
>   [<c023e650>] ? __local_bh_enable+0x70/0x70
>   <IRQ>
>   [<c023e587>] ? irq_exit+0x67/0xa0
>   [<c0202af6>] ? do_IRQ+0x46/0xb0
>   [<c027ad05>] ? clockevents_notify+0x35/0x110
>   [<c066ac6c>] ? common_interrupt+0x2c/0x40
>   [<c056e3c1>] ? cpuidle_enter_state+0x41/0xf0
>   [<c056e6fb>] ? cpuidle_idle_call+0x8b/0x100
>   [<c02085f8>] ? arch_cpu_idle+0x8/0x30
>   [<c027314b>] ? cpu_idle_loop+0x4b/0x140
>   [<c0273258>] ? cpu_startup_entry+0x18/0x20
>   [<c066056d>] ? rest_init+0x5d/0x70
>   [<c0813ac8>] ? start_kernel+0x2ec/0x2f2
>   [<c081364f>] ? repair_env_string+0x5b/0x5b
>   [<c0813269>] ? i386_start_kernel+0x33/0x35
> Code: 8b 7b 0c 8b b6 98 00 00 00 85 c0 89 07 74 03 89 78 04 c7 43 0c 00
>   02 20 00 83 ae ec 05 00 00 01 8b 03 8b 7b 04 85 c0 89 07 74 03 <89> 78
>   04 8b 43 7c c7 03 00 01 10 00 c7 43 04 00 02 20 00 80 6c
> EIP: [<f8214f07>] nf_ct_unlink_expect_report+0x57/0xf0 [nf_conntrack]  
> SS:ESP 0068:f6409eec
> CR2: 0000000000100104
> ---[ end trace 79fe2e6b81f54dee ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Rebooting in 300 seconds..
> ===================================================================================
> 
> 
> Polycom Version: 3.1-44477
> running on device: Apple iPad Mini
> using operating system: iOS Version: 7.0.4
> 
> 
> Attached also my kernel config. Hopefully someone could help...
> 
> BR, Toni
