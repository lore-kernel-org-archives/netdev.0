From: Dave Jones <davej@redhat.com>
Subject: tc related lockdep warning.
Date: Sun, 24 Sep 2006 17:29:33 -0400
Message-ID: <20060924212933.GB20123@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:20108 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751542AbWIXV3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 17:29:40 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k8OLTdOR001026
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 17:29:40 -0400
Received: from pressure.kernelslacker.org (vpn-248-6.boston.redhat.com [10.13.248.6])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k8OLTY53024945
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 17:29:34 -0400
Received: from pressure.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by pressure.kernelslacker.org (8.13.8/8.13.8) with ESMTP id k8OLTYkm026761
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 17:29:34 -0400
Received: (from davej@localhost)
	by pressure.kernelslacker.org (8.13.8/8.13.8/Submit) id k8OLTXGq026760
	for netdev@vger.kernel.org; Sun, 24 Sep 2006 17:29:33 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


=================================
[ INFO: inconsistent lock state ]
---------------------------------
inconsistent {softirq-on-R} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
 (police_lock){-+--}, at: [<f8d304fd>] tcf_police_destroy+0x24/0x8f [act_police]
{softirq-on-R} state was registered at:
  [<c043bdd6>] lock_acquire+0x4b/0x6d
  [<c061495a>] _read_lock+0x19/0x28
  [<f8d3026a>] tcf_act_police_locate+0x26a/0x363 [act_police]
  [<c05cacc3>] tcf_action_init_1+0x113/0x1a7
  [<c05c97c9>] tcf_exts_validate+0x3c/0x85
  [<f8d4337c>] u32_set_parms+0x26/0x131 [cls_u32]
  [<f8d43dc7>] u32_change+0x2fc/0x371 [cls_u32]
  [<c05c9f44>] tc_ctl_tfilter+0x417/0x487
  [<c05c0d67>] rtnetlink_rcv_msg+0x1b3/0x1d6
  [<c05ccef3>] netlink_run_queue+0x69/0xfe
  [<c05c0b6a>] rtnetlink_rcv+0x29/0x42
  [<c05cd380>] netlink_data_ready+0x12/0x50
  [<c05cc3e8>] netlink_sendskb+0x1f/0x37
  [<c05cccc1>] netlink_unicast+0x1a1/0x1bb
  [<c05cd361>] netlink_sendmsg+0x275/0x282
  [<c05aff4a>] sock_sendmsg+0xe8/0x103
  [<c05b074d>] sys_sendmsg+0x14d/0x1a8
  [<c05b1937>] sys_socketcall+0x16b/0x186
  [<c0403fb7>] syscall_call+0x7/0xb
irq event stamp: 278833666
hardirqs last  enabled at (278833666): [<c04290b9>] tasklet_action+0x30/0xca
hardirqs last disabled at (278833665): [<c0429095>] tasklet_action+0xc/0xca
softirqs last  enabled at (278833650): [<c0429083>] __do_softirq+0xec/0xf2
softirqs last disabled at (278833659): [<c0406683>] do_softirq+0x5a/0xbe

other info that might help us debug this:
1 lock held by swapper/0:
 #0:  (qdisc_tree_lock){-+-.}, at: [<c05c7737>] __qdisc_destroy+0x20/0x85

stack backtrace:
 [<c04051ed>] show_trace_log_lvl+0x58/0x16a
 [<c04057fa>] show_trace+0xd/0x10
 [<c0405913>] dump_stack+0x19/0x1b
 [<c043a20b>] print_usage_bug+0x1cf/0x1dc
 [<c043a5e4>] mark_lock+0x124/0x353
 [<c043b2a0>] __lock_acquire+0x3d7/0x99c
 [<c043bdd6>] lock_acquire+0x4b/0x6d
 [<c06148a5>] _write_lock_bh+0x1e/0x2d
 [<f8d304fd>] tcf_police_destroy+0x24/0x8f [act_police]
 [<f8d30590>] tcf_act_police_cleanup+0x28/0x33 [act_police]
 [<c05ca1a1>] tcf_action_destroy+0x20/0x84
 [<c05c9784>] tcf_exts_destroy+0x16/0x1f
 [<f8d43114>] u32_destroy_key+0x30/0x50 [cls_u32]
 [<f8d4314f>] u32_clear_hnode+0x1b/0x2e [cls_u32]
 [<f8d4319a>] u32_destroy_hnode+0x38/0x81 [cls_u32]
 [<f8d4322d>] u32_destroy+0x4a/0xc9 [cls_u32]
 [<f8d340f9>] ingress_destroy+0x1a/0x5c [sch_ingress]
 [<c05c774d>] __qdisc_destroy+0x36/0x85
 [<c043438f>] __rcu_process_callbacks+0xfe/0x169
 [<c04346f0>] rcu_process_callbacks+0x23/0x45
 [<c04290ee>] tasklet_action+0x65/0xca
 [<c042900f>] __do_softirq+0x78/0xf2
 [<c0406683>] do_softirq+0x5a/0xbe
 [<c0428eb8>] irq_exit+0x3d/0x3f
 [<c04179df>] smp_apic_timer_interrupt+0x73/0x78
 [<c0404b12>] apic_timer_interrupt+0x2a/0x30
DWARF2 unwinder stuck at apic_timer_interrupt+0x2a/0x30
Leftover inexact backtrace:
