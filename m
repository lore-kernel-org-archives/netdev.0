From: Vlado Drzik <vlado@ttx.sk>
Subject: Oops in cleanup_once - 2.6.37
Date: Tue, 22 Feb 2011 19:09:49 +0100
Message-ID: <4D63FBED.1000707@ttx.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ttx02.ttx-net.sk ([193.110.187.3]:53247 "EHLO ttx02.ttx-net.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab1BVSfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 13:35:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello,

We are recently facing crashes with 2.6.36.1 and also 2.6.37 on our
routers/firewalls (on weekly basis).
Kernels are x86_64. We use igb and e1000e network cards and crashes are
not happening during the peek load (peak is 200kpps).

I have several crashdumps available if that could help someone.
It looks like iptables  might be somehow involved... (I always see
reject in there)

I've seen similar thing reported on kernel mailing list but no sadly
resolution. Could someone take a quick look?

Here is one of Oops messages (all look very similiar):
 
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff812e714a>] cleanup_once+0x4a/0x1f0
PGD 0
Oops: 0002 [#1] SMP
last sysfs file: /sys/kernel/kexec_crash_loaded
CPU 4
Modules linked in: act_mirred sch_ingress cls_u32 sch_htb ifb
nf_conntrack_netlink nfnetlink i2c_dev i2c_core bonding 8021q ipt_LOG
xt_comment ipt_REJECT xt_state ipt_REDIRECT x
t_tcpudp xt_CLASSIFY xt_mark iptable_raw ip_set_macipmap dm_mirror
dm_region_hash dm_log dm_mod video output hed battery ac ipt_set ip_set
xt_ACCOUNT compat_xtables nf_nat_ftp n
f_conntrack_ftp iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4
nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables sg sr_mod
cdrom e1000e bnx2 i5000_edac edac_cor
e igb psmouse serio_raw ata_piix libata shpchp pcspkr dcdbas usb_storage
megaraid_sas sd_mod scsi_mod ehci_hcd ohci_hcd uhci_hcd [last unloaded:
microcode]

Pid: 0, comm: kworker/0:1 Not tainted 2.6.37 #1 0UR033/PowerEdge 1950
RIP: 0010:[<ffffffff812e714a>]  [<ffffffff812e714a>] cleanup_once+0x4a/0x1f0
RSP: 0018:ffff8800cfd03710  EFLAGS: 00010206
RAX: ffff88012d49fcc0 RBX: ffff88012ccd6f58 RCX: 0000000000000013
RDX: 0000000000000000 RSI: 0000000000000013 RDI: ffffffff814c5810
RBP: 0000000000000000 R08: ffff88011d796000 R09: ffff88011c37b9c0
R10: 0000000000000014 R11: ffff88011d5bf340 R12: ffff88012ccd6f40
R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000040
FS:  0000000000000000(0000) GS:ffff8800cfd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 00000000b6550000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff88012fd72000, task
ffff88012fd616c0)
Stack:
 ffff88012b5ac580 ffff88011330d402 ffffc900119111d0 ffffffffa01d677a
 ffff88011c12fe00 ffff88012c7ebb00 ffff88012fed4090 ffffffff8105b3ce
 ffff88012b5ac000 00008800cfd0dd08 ffff88012b5ac580 ffff88012c7ebb00
Call Trace:
 <IRQ>
 [<ffffffffa01d677a>] ? e1000_xmit_frame+0x98a/0xc90 [e1000e]
 [<ffffffff8105b3ce>] ? hrtimer_interrupt+0xfe/0x1f0
 [<ffffffff812b17e0>] ? skb_checksum+0x50/0x2d0
 [<ffffffff812bc6b8>] ? dev_hard_start_xmit+0x528/0x750
 [<ffffffff810de8c8>] ? __slab_alloc+0x1d8/0x2e0
 [<ffffffff812ae092>] ? sock_alloc_send_pskb+0x1a2/0x2f0
 [<ffffffff812375b5>] ? secure_ip_id+0x45/0x50
 [<ffffffff812e7502>] ? inet_getpeer+0xf2/0x1f0
 [<ffffffff813106f2>] ? icmp_glue_bits+0x82/0xa0
 [<ffffffff812eae36>] ? ip_append_data+0x896/0xb70
 [<ffffffff81310670>] ? icmp_glue_bits+0x0/0xa0
 [<ffffffff812e585f>] ? rt_bind_peer+0xf/0x40
 [<ffffffff812e597f>] ? __ip_select_ident+0xef/0x130
 [<ffffffff812ebebf>] ? ip_push_pending_frames+0x2ff/0x3c0
 [<ffffffff8131109e>] ? icmp_send+0x37e/0x630
 [<ffffffffa0160077>] ? igb_xmit_frame_ring_adv+0x617/0xc20 [igb]
 [<ffffffff81047214>] ? lock_timer_base+0x34/0x70
 [<ffffffff812bc6b8>] ? dev_hard_start_xmit+0x528/0x750
 [<ffffffffa017bb3d>] ? nf_ct_invert_tuple+0x6d/0x90 [nf_conntrack]
 [<ffffffffa02a232d>] ? reject_tg+0x2cd/0x3e0 [ipt_REJECT]
 [<ffffffffa0159bec>] ? ipt_do_table+0x34c/0x5d0 [ip_tables]
 [<ffffffff8131b084>] ? fib_validate_source+0x104/0x2c0
 [<ffffffff812e3fef>] ? rt_intern_hash+0x51f/0x5a0
 [<ffffffff812e0e7e>] ? nf_iterate+0x5e/0x90
 [<ffffffff812e7e70>] ? ip_local_deliver_finish+0x0/0x1f0
 [<ffffffff812e10e6>] ? nf_hook_slow+0x76/0xf0
 [<ffffffff812e7e70>] ? ip_local_deliver_finish+0x0/0x1f0
 [<ffffffff812e7e58>] ? ip_local_deliver+0x78/0x90
 [<ffffffff812ba68d>] ? __netif_receive_skb+0x3cd/0x5e0
 [<ffffffff812bec25>] ? process_backlog+0x85/0x160
 [<ffffffff812bee0d>] ? net_rx_action+0x10d/0x210
 [<ffffffff81040211>] ? __do_softirq+0xb1/0x1d0
 [<ffffffff810816b9>] ? handle_IRQ_event+0x49/0x150
 [<ffffffff81003b0c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100503a>] ? do_softirq+0x4a/0x80
 [<ffffffff810045ba>] ? do_IRQ+0x6a/0xe0
 [<ffffffff81349b93>] ? ret_from_intr+0x0/0xa
 <EOI>
 [<ffffffff8100a34c>] ? mwait_idle+0x7c/0xd0
 [<ffffffff81001c12>] ? cpu_idle+0x42/0xb0
Code: 1d 00 48 81 fb 00 58 4c 81 0f 84 86 00 00 00 4c 8d 63 e8 48 8b 05
47 17 1f 00 41 2b 44 24 28 48 39 e8 72 71 48 8b 13 48 8b 43 08 <48> 89
42 08 48 89 10 48 89 5b 08 48 89 1
b f0 ff 43 14 48 c7 c7
RIP  [<ffffffff812e714a>] cleanup_once+0x4a/0x1f0
 RSP <ffff8800cfd03710>
CR2: 0000000000000008


