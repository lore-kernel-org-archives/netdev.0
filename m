From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 87111] New: hlist_for_each_entry_rcu()  returns invalid
 pointer causing kernel to OOPS
Date: Wed, 29 Oct 2014 08:57:48 -0700
Message-ID: <20141029085748.58c8d07c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:46061 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933459AbaJ2P56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 11:57:58 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so3220131pdb.7
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 08:57:57 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id nv7sm2249140pdb.68.2014.10.29.08.57.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Oct 2014 08:57:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 29 Oct 2014 07:16:13 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 87111] New: hlist_for_each_entry_rcu()  returns invalid pointer causing kernel to OOPS


https://bugzilla.kernel.org/show_bug.cgi?id=87111

            Bug ID: 87111
           Summary: hlist_for_each_entry_rcu()  returns invalid pointer
                    causing kernel to OOPS
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.24
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: jith131986@gmail.com
        Regression: No

Created attachment 155781
  --> https://bugzilla.kernel.org/attachment.cgi?id=155781&action=edit
nf_nat.ko objdump for analysing IP and offset to see exact line where kernel
panic happened

In my setup linux stack is only used for layer 2 network services. when layer 2
packet is recieved by linux for layer 2 functionality, in nf_nat kernel module
hlist_for_each_entry_rcu()(where IP points)  function return an invalid pointer
resulting in Oops panic. I have attached panic dump and nf_nat.ko objdump for
further analysis.

Would like to know the issue is seen/reported before and fixed ?. If not is it 
possible to get cause or solution for the same.

Pasting the panic dump below and attaching nf_nat.ko objdump

<1>BUG: unable to handle kernel NULL pointer dereference at 000000000000003e
<1>IP: [<ffffffffa003794b>] nf_nat_setup_info+0x1ab/0x740 [nf_nat]
<6>PGD 641576067 PUD 7dd9f3067 PMD 0 
<0>Oops: 0000 [#1] PREEMPT SMP 
<0>last sysfs file:
/sys/devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1:1.0/host5/scsi_host/host5/proc_name
<6>CPU 3 
<6>Modules linked in: bridge stp llc ixgbe igb ftdi_sio usbserial xt_connlimit
xt_tcpudp xt_mark iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_conntrack iptable_filter ip_tables x_tables
<6>Pid: 0, comm: swapper Tainted: P        W  2.6.32.24 #1 S5520UR
<6>RIP: e030:[<ffffffffa003794b>]  [<ffffffffa003794b>]
nf_nat_setup_info+0x1ab/0x740 [nf_nat]
<6>RSP: e02b:ffff88002808d910  EFLAGS: 00010282
<6>RAX: 0000000000000000 RBX: ffff880381313b58 RCX: 0000000000000000
<6>RDX: 0000000000000018 RSI: 000000007049f4f6 RDI: ffff88002808d9b0
<6>RBP: ffff88002808da10 R08: ffffffff81393e80 R09: ffffffffa0040790
<6>R10: 0000000000004000 R11: 000000000000002c R12: ffff88002808da20
<6>R13: ffff8807fc8ebfd8 R14: ffff880396c3bb70 R15: 0000000000000000
<6>FS:  00007fde2cd296f0(0000) GS:ffff88002808a000(0000) knlGS:0000000000000000
<6>CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
<6>CR2: 000000000000003e CR3: 000000079ab27000 CR4: 0000000000002660
<6>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<6>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<6>Process swapper (pid: 0, threadinfo ffff8807fc8ea000, task ffff8807fc8da050)
<0>Stack:
<6> 0000000000000000 ffff88002808d980 ffff88002808da2c ffff88002808da2e
<6><0> ffff8807fc8ea000 ffff8807fc8ebfd8 0000000000000100 0000000000000100
<6><0> 0000000000000000 0000000000010001 00000000002ace3f ffff88002809a720
<0>Call Trace:
<0> <IRQ> 
<6> [<ffffffff81048b07>] ? local_bh_enable+0x77/0xc0
<6> [<ffffffffa0009945>] ? ipt_do_table+0x2a5/0x3e0 [ip_tables]
<6> [<ffffffffa00400cf>] alloc_null_binding+0x3f/0x70 [iptable_nat]
<6> [<ffffffffa00402fb>] nf_nat_rule_find+0x1fb/0x390 [iptable_nat]
<6> [<ffffffff8138ca3f>] nf_iterate+0x5f/0x90
<6> [<ffffffff81393e80>] ? ip_local_deliver_finish+0x0/0x1e0
<6> [<ffffffff8138cdb0>] nf_hook_slow+0xb0/0x110
<6> [<ffffffff81393e80>] ? ip_local_deliver_finish+0x0/0x1e0
<6> [<ffffffff81394559>] ip_local_deliver+0x69/0x90
<6> [<ffffffff81393ba6>] ip_rcv_finish+0x146/0x420
<6> [<ffffffff8139440d>] ip_rcv+0x27d/0x360
<6> [<ffffffff81371747>] netif_receive_skb+0x2b7/0x390
<6> [<ffffffffa12cce50>] br_handle_frame_finish+0x130/0x170 [bridge]
<6> [<ffffffffa12d1458>] br_netfilter_fini+0x6a8/0x810 [bridge]
<6> [<ffffffff8138cdb0>] ? nf_hook_slow+0xb0/0x110
<6> [<ffffffffa12d1270>] ? br_netfilter_fini+0x4c0/0x810 [bridge]
<6> [<ffffffffa12d2389>] nf_bridge_copy_header+0xdc9/0x10e0 [bridge]
<6> [<ffffffff8138ca3f>] nf_iterate+0x5f/0x90
<6> [<ffffffffa12ccd20>] ? br_handle_frame_finish+0x0/0x170 [bridge]
<6> [<ffffffff8138cdb0>] nf_hook_slow+0xb0/0x110
<6> [<ffffffffa12ccd20>] ? br_handle_frame_finish+0x0/0x170 [bridge]
<6> [<ffffffffa12ccfe6>] br_handle_frame+0x156/0x2b0 [bridge]
<6> [<ffffffff813f2ab8>] ? vlan_skb_recv+0x1a8/0x2f0
<6> [<ffffffff81371699>] netif_receive_skb+0x209/0x390
<6> [<ffffffff81374d79>] process_backlog+0x89/0xc0
<6> [<ffffffff81374b7f>] net_rx_action+0x7f/0x160
<6> [<ffffffffa0078165>] ? igb_reinit_locked+0x1995/0x2900 [igb]
<6> [<ffffffff810484f8>] __do_softirq+0xa8/0x130
<6> [<ffffffff810755a8>] ? handle_level_irq+0xe8/0x130
<6> [<ffffffff81014efc>] call_softirq+0x1c/0x30
<6> [<ffffffff81016765>] do_softirq+0x65/0xa0
<6> [<ffffffff81048358>] irq_exit+0x48/0x50
<6> [<ffffffff81228ddd>] xen_evtchn_do_upcall+0x3d/0x60
<6> [<ffffffff81014f4e>] xen_do_hypervisor_callback+0x1e/0x30
<0> <EOI> 
<6> [<ffffffff810093aa>] ? hypercall_page+0x3aa/0x1010
<6> [<ffffffff810093aa>] ? hypercall_page+0x3aa/0x1010
<6> [<ffffffff8100f8d0>] ? xen_safe_halt+0x10/0x20
<6> [<ffffffff8100c4d5>] ? xen_idle+0x45/0x70
<6> [<ffffffff81012d78>] ? cpu_idle+0x58/0x90
<6> [<ffffffff810101c9>] ? xen_irq_enable_direct_end+0x0/0x7
<6> [<ffffffff8140a86e>] ? cpu_bringup_and_idle+0xe/0x10
<0>Code: ff ff ff 49 8d 44 24 0c 48 89 85 10 ff ff ff eb 0c 48 8b 1b 48 85 db
0f 84 f1 00 00 00 48 8b 4b 20 48 8b 03 48 8d 51 18 0f 18 08 <0f> b6 42 26 3a 45
c6 75 dd 8b 02 3b 45 a0 75 d6 0f b7 42 10 66 
<1>RIP  [<ffffffffa003794b>] nf_nat_setup_info+0x1ab/0x740 [nf_nat]
<6> RSP <ffff88002808d910>
<0>CR2: 000000000000003e


WARN  paging error trying to follow 0x0000000000000000 - level 2, cr3
000000058ea67000

-- 
You are receiving this mail because:
You are the assignee for the bug.
