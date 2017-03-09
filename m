From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 109581] WARNING: CPU: 1 PID: 0 at
 net/sched/sch_hfsc.c:1429 hfsc_dequeue+0x166/0x2da()
Date: Thu, 9 Mar 2017 10:53:29 -0800
Message-ID: <20170309105329.79cd5e44@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36836 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdCISyw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 13:54:52 -0500
Received: by mail-pf0-f179.google.com with SMTP id o126so31965669pfb.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 10:53:32 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id x21sm13911175pfa.71.2017.03.09.10.53.31
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 Mar 2017 10:53:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 09 Mar 2017 12:41:19 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 109581] WARNING: CPU: 1 PID: 0 at net/sched/sch_hfsc.c:1429 hfsc_dequeue+0x166/0x2da()


https://bugzilla.kernel.org/show_bug.cgi?id=109581

--- Comment #33 from Pawel Staszewski (pstaszewski@artcom.pl) ---
Hi all

Update here with kernel 4.10.1
[39542.654334] WARNING: CPU: 26 PID: 0 at net/sched/sch_hfsc.c:1400
hfsc_dequeue+0x13e/0x277
[39542.654335] Modules linked in: bridge stp llc veth bonding ipmi_si
[39542.654341] CPU: 26 PID: 0 Comm: swapper/26 Tainted: G        W  O    4.10.1
#1
[39542.654342] Call Trace:
[39542.654344]  <IRQ>
[39542.654347]  dump_stack+0x63/0x7f
[39542.654349]  __warn+0xc0/0xdb
[39542.654351]  warn_slowpath_null+0x18/0x1a
[39542.654352]  hfsc_dequeue+0x13e/0x277
[39542.654353]  __qdisc_run+0xf0/0x21b
[39542.654355]  net_tx_action+0xdc/0xef
[39542.654356]  __do_softirq+0xbc/0x1c9
[39542.654358]  irq_exit+0x51/0x5f
[39542.654360]  smp_apic_timer_interrupt+0x29/0x34
[39542.654363]  apic_timer_interrupt+0x89/0x90
[39542.654366] RIP: 0010:cpuidle_enter_state+0x148/0x1a3
[39542.654367] RSP: 0018:ffffc90003333e98 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff10
[39542.654368] RAX: ffff88046fc153c0 RBX: 0000000000000001 RCX:
000000000000001f
[39542.654369] RDX: 0000000000000000 RSI: ffff88046fc12b18 RDI:
0000000000000000
[39542.654369] RBP: ffffc90003333ec8 R08: 0000000000000000 R09:
0000000000000000
[39542.654370] R10: ffffc90003333e40 R11: ffff88086d387000 R12:
ffff88046c4f4400
[39542.654371] R13: 000023f6bddd31c7 R14: 0000000000000000 R15:
000023f6bddd0579
[39542.654371]  </IRQ>
[39542.654373]  ? cpuidle_enter_state+0x101/0x1a3
[39542.654374]  cpuidle_enter+0x12/0x14
[39542.654376]  do_idle+0x129/0x1a7
[39542.654378]  cpu_startup_entry+0x1a/0x1f
[39542.654379]  start_secondary+0xd6/0xd9
[39542.654382]  start_cpu+0x14/0x14
[39542.654383] ---[ end trace de75ea4e514f5380 ]---

Typical configuration fot hfsc on vlan interface:
tc qdisc del dev vlan1201 root
tc qdisc add dev vlan1201 handle 1: root hfsc default 100
tc class add dev vlan1201 parent 1: classid 1:100 hfsc ls m2 2100Mbit ul m2
2100Mbit
tc qdisc add dev vlan1201 parent 1:100 handle 100: fq_codel limit 3000 noecn

-- 
You are receiving this mail because:
You are the assignee for the bug.
