From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Thu, 3 Mar 2016 14:24:54 -0800
Message-ID: <CALx6S36-LNu_uqPP3is1U7gO48qtbkTADgxpm_ecuHN+UuxrgQ@mail.gmail.com>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
	<CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <kernel-team@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35028 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758546AbcCCWYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:24:55 -0500
Received: by mail-ig0-f194.google.com with SMTP id ww10so643565igb.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 14:24:54 -0800 (PST)
In-Reply-To: <CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This a kernel based on 3.10. We believe the lockups coincide with
removing/readding qdiscs.

Thanks,
Tom

Mar  3 14:19:24  kernel: [2611792.157733] BUG: soft lockup - CPU#5
stuck for 22s! [swapper/5:0]
Mar  3 14:19:24  kernel: [2611792.158925] Modules linked in:
netconsole mpt2sas raid_class k10temp ip_set cls_u32 sch_fq_codel
cls_fw sch_htb tcp_diag inet_diag xt_NFLOG nfnetlink_log nfnetlink
xt_statistic xt_mark hwmon_vid w83795 i2c_piix4 rpcsec_gss_krb5
auth_rpcgss oid_registry sunrpc iptable_raw iptable_filter
iptable_mangle ip_tables ip6table_raw ip6table_filter xt_DSCP
xt_comment xt_tcpudp ip6table_mangle ip6_tables x_tables ipv6 vfat fat
xfs exportfs libcrc32c loop sg ses enclosure serio_raw iTCO_wdt
iTCO_vendor_support e1000e ipmi_devintf coretemp hwmon kvm
crc32c_intel aesni_intel ablk_helper cryptd lrw gf128mul glue_helper
aes_x86_64 microcode mlx4_en ptp pps_core mlx4_core rtc_cmos pcspkr
i2c_i801 i2c_core lpc_ich mfd_core ehci_pci ehci_hcd ipmi_si
ipmi_msghandler shpchp megaraid_sas button dm_mirror dm_region_hash
dm_log dm_mod [last unloaded: netconsole]
Mar  3 14:19:24  kernel: [2611792.170916] CPU: 5 PID: 0 Comm:
swapper/5 Not tainted 3.10.75-81_fbk20_04878_ga42f32d #1
Mar  3 14:19:24  kernel: [2611792.172181] Hardware name: Quanta
Freedom 1F03R000044/Winterfell IPV6, BIOS F03_3B10 09/02/2014
Mar  3 14:19:24  kernel: [2611792.173554] task: ffff8817fab7a100 ti:
ffff8817fab84000 task.ti: ffff8817fab84000
Mar  3 14:19:24  kernel: [2611792.174729] RIP:
0010:[<ffffffff8160ac52>]  [<ffffffff8160ac52>]
_raw_spin_lock+0x22/0x30
Mar  3 14:19:24  kernel: [2611792.176275] RSP: 0018:ffff88181f143db0
EFLAGS: 00000206
Mar  3 14:19:24  kernel: [2611792.177181] RAX: 0000000000000034 RBX:
ffff88181f143d38 RCX: ffff8817d4223038
Mar  3 14:19:24  kernel: [2611792.179487] RDX: 0000000000000031 RSI:
00000000001edc3a RDI: ffff8817fa7f409c
Mar  3 14:19:24  kernel: [2611792.182370] RBP: ffff88181f143db0 R08:
000000000155157d R09: ffff8817fa468000
Mar  3 14:19:24  kernel: [2611792.183486] R10: 0000000000000005 R11:
0000000000000004 R12: ffff88181f143d28
Mar  3 14:19:24  kernel: [2611792.184610] R13: ffffffff81613cca R14:
ffff88181f143db0 R15: 0000000000000008
Mar  3 14:19:24  kernel: [2611792.185817] FS:  0000000000000000(0000)
GS:ffff88181f140000(0000) knlGS:0000000000000000
Mar  3 14:19:24  kernel: [2611792.187077] CS:  0010 DS: 0000 ES: 0000
CR0: 0000000080050033
Mar  3 14:19:24  kernel: [2611792.187983] CR2: 00007fe30b431ec0 CR3:
0000000001c0c000 CR4: 00000000001407e0
Mar  3 14:19:24  kernel: [2611792.189113] DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Mar  3 14:19:24  kernel: [2611792.190235] DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Mar  3 14:19:24  kernel: [2611792.191496] Stack:
Mar  3 14:19:24  kernel: [2611792.191825]  ffff88181f143e10
ffffffff8153b269 ffffffff810879b1 0000000400000005
Mar  3 14:19:24  kernel: [2611792.192985]  ffff88181f151ac0
ffff8817d41e7600 ffff88181f143de0 ffff8817fa468000
Mar  3 14:19:24  kernel: [2611792.194134]  ffffffff81ec27c0
0000000000000100 ffffffff8153b200 0000000000000004
Mar  3 14:19:24  kernel: [2611792.195290] Call Trace:
Mar  3 14:19:24  kernel: [2611792.195717]  <IRQ>
Mar  3 14:19:24  kernel: [2611792.196040]  [<ffffffff8153b269>]
est_timer+0x69/0x160
Mar  3 14:19:24  kernel: [2611792.197279]  [<ffffffff810879b1>] ?
trigger_load_balance+0x61/0x210
Mar  3 14:19:24  kernel: [2611792.198269]  [<ffffffff8153b200>] ?
gnet_stats_copy_app+0xd0/0xd0
Mar  3 14:19:24  kernel: [2611792.199235]  [<ffffffff81056f2a>]
call_timer_fn+0x3a/0x110
Mar  3 14:19:24  kernel: [2611792.202186]  [<ffffffff8153b200>] ?
gnet_stats_copy_app+0xd0/0xd0
Mar  3 14:19:24  kernel: [2611792.203141]  [<ffffffff810588a0>]
run_timer_softirq+0x1f0/0x2a0
Mar  3 14:19:24  kernel: [2611792.204073]  [<ffffffff81092b92>] ?
ktime_get+0x52/0xe0
Mar  3 14:19:24  kernel: [2611792.205044]  [<ffffffff81050c00>]
__do_softirq+0xe0/0x220
Mar  3 14:19:24  kernel: [2611792.206004]  [<ffffffff810711e0>] ?
hrtimer_interrupt+0x140/0x240
Mar  3 14:19:24  kernel: [2611792.206974]  [<ffffffff8161433c>]
call_softirq+0x1c/0x30
Mar  3 14:19:24  kernel: [2611792.207819]  [<ffffffff81004325>]
do_softirq+0x55/0x90
Mar  3 14:19:24  kernel: [2611792.208639]  [<ffffffff81050e95>]
irq_exit+0x95/0xa0
Mar  3 14:19:24  kernel: [2611792.209418]  [<ffffffff81614abe>]
smp_apic_timer_interrupt+0x6e/0x99
Mar  3 14:19:24  kernel: [2611792.210424]  [<ffffffff81613cca>]
apic_timer_interrupt+0x6a/0x70
Mar  3 14:19:24  kernel: [2611792.211485]  <EOI>
Mar  3 14:19:24  kernel: [2611792.211810]  [<ffffffff815000cb>] ?
cpuidle_enter_state+0x5b/0xe0
Mar  3 14:19:24  kernel: [2611792.212801]  [<ffffffff815000c7>] ?
cpuidle_enter_state+0x57/0xe0
Mar  3 14:19:24  kernel: [2611792.213768]  [<ffffffff8150020b>]
cpuidle_idle_call+0xbb/0x200
Mar  3 14:19:24  kernel: [2611792.214696]  [<ffffffff8100ae4e>]
arch_cpu_idle+0xe/0x30
Mar  3 14:19:24  kernel: [2611792.216857]  [<ffffffff81090fca>]
cpu_startup_entry+0x9a/0x220
Mar  3 14:19:24  kernel: [2611792.218315]  [<ffffffff8102e349>]
start_secondary+0x189/0x1e0
Mar  3 14:19:24  kernel: [2611792.219233] Code: 75 f7 48 83 c4 08 5b
5d c3 0f 1f 44 00 00 55 48 89 e5 b8 00 01 00 00 f0 66 0f c1 07 0f b6
d4 38 c2 74 0f 66 0f 1f 44 00 00 f3 90 <0f> b6 07 38 d0 75 f7 5d c3 90
90 90 90 90 0f 1f 44 00 00 55 48

On Tue, Mar 1, 2016 at 10:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Mar 1, 2016 at 3:16 PM, Tom Herbert <tom@herbertland.com> wrote:
>> We are seeing a number of softlockups occurring with HTB upon removing
>> the qdisc. We are still attempting to repro the exact circumstances,
>> however looking at the code I'm very suspicious of this block in
>> net_tx_action and its interaction with dev_deactivate (called through
>> tc_modify_qdisc):
>
>
> Do you mind to share the stack trace of these soft lockups with us?
>
> Thanks.
