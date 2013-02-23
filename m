From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54281] New: kernel NULL pointer dereference on deleting a
 vlan interface
Date: Sat, 23 Feb 2013 07:26:03 -0800
Message-ID: <20130223072603.594c45e1@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:62471 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab3BWP0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 10:26:13 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so938539pbc.16
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 07:26:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 22 Feb 2013 22:31:22 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54281] New: kernel NULL pointer dereference on deleting a vlan interface


https://bugzilla.kernel.org/show_bug.cgi?id=54281

           Summary: kernel NULL pointer dereference on deleting a vlan
                    interface
           Product: Networking
           Version: 2.5
          Platform: All
        OS/Version: Linux
              Tree: Fedora
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: bugs@syam.in
        Regression: No


I managed to trigger a NULL pointer dereference by perhaps an incorrect usage
of "ip" tool. 

I will be happy to provide more details if necessary. Here is the backtrace for
now.

# ip link  del em1.57
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffffa03c356f>] garp_uninit_applicant+0x2f/0xd0 [garp]
PGD 47ce2f1067 PUD 47cbc15067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu23/cache/index2/shared_cpu_map
CPU 15 
Modules linked in: bridge xt_comment ipt_LOG xt_limit fuse bonding 8021q garp
stp llc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables
ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack
ip6table_filter ip6_tables ipv6 xfs exportfs power_meter dcdbas microcode
sb_edac edac_core iTCO_wdt iTCO_vendor_support shpchp sg tg3 ext4 mbcache jbd2
sr_mod cdrom sd_mod crc_t10dif ahci wmi megaraid_sas dm_mirror dm_region_hash
dm_log dm_mod [last unloaded: speedstep_lib]

Pid: 27564, comm: ip Not tainted 2.6.32-279.el6.x86_64 #1 Dell Inc. PowerEdge
R720/0VWT90
RIP: 0010:[<ffffffffa03c356f>]  [<ffffffffa03c356f>]
garp_uninit_applicant+0x2f/0xd0 [garp]
RSP: 0018:ffff8847ce2e38a8  EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff8823cdc8e020 RCX: ffff8847cc6c0080
RDX: ffffffff81b12200 RSI: ffffffffa03cfa20 RDI: ffff8823cdc8e020
RBP: ffff8847ce2e38c8 R08: ffffffff81b12200 R09: 00000000ffffffff
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8823cdc8e020
R13: ffffffffa03cfa20 R14: 0000000000000000 R15: ffff8823cdab26c0
FS:  00007fe26eef1700(0000) GS:ffff8824aece0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 00000047cce94000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 27564, threadinfo ffff8847ce2e2000, task ffff8847cc6c0080)
Stack:
 ffff8823cdc8e020 0000000000000039 ffff8847cf7b4020 ffffffffa0141d80
<d> ffff8847ce2e38d8 ffffffffa03ce085 ffff8847ce2e3918 ffffffffa03cb420
<d> 00000000ffffffa6 ffffffff8200cec0 ffff8847cc914810 0000000000000001
Call Trace:
 [<ffffffffa03ce085>] vlan_gvrp_uninit_applicant+0x15/0x20 [8021q]
 [<ffffffffa03cb420>] unregister_vlan_dev+0xf0/0x190 [8021q]
 [<ffffffff81448ae0>] rtnl_dellink+0xd0/0x110
 [<ffffffff81448837>] rtnetlink_rcv_msg+0x177/0x290
 [<ffffffff814486c0>] ? rtnetlink_rcv_msg+0x0/0x290
 [<ffffffff81463df9>] netlink_rcv_skb+0xa9/0xd0
 [<ffffffff814486a5>] rtnetlink_rcv+0x25/0x40
 [<ffffffff81463a56>] netlink_unicast+0x2e6/0x300
 [<ffffffff814643e0>] netlink_sendmsg+0x200/0x2e0
 [<ffffffff81428003>] sock_sendmsg+0x123/0x150
 [<ffffffff810920d0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81427c24>] ? move_addr_to_kernel+0x64/0x70
 [<ffffffff81429b56>] __sys_sendmsg+0x406/0x420
 [<ffffffff8104452c>] ? __do_page_fault+0x1ec/0x480
 [<ffffffff8114328b>] ? vma_link+0x9b/0xf0
 [<ffffffff811453bc>] ? do_brk+0x26c/0x350
 [<ffffffff81429d79>] sys_sendmsg+0x49/0x90
 [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
Code: 48 83 ec 20 48 89 1c 24 4c 89 64 24 08 4c 89 6c 24 10 4c 89 74 24 18 0f
1f 44 00 00 8b 06 4c 8b b7 28 04 00 00 49 89 fc 49 89 f5 <49> 8b 1c c6 e8 38 46
08 e1 85 c0 74 6f 41 8b 45 00 49 c7 04 c6 
RIP  [<ffffffffa03c356f>] garp_uninit_applicant+0x2f/0xd0 [garp]
 RSP <ffff8847ce2e38a8>
CR2: 0000000000000000

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
