From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 103541] New: netconsole + bonding: WARNING: CPU: 0 PID:
 115 at kernel/softirq.c:150 __local_bh_enable_ip+0x6f/0xa0()
Date: Wed, 26 Aug 2015 08:24:40 -0700
Message-ID: <20150826082440.0d750c90@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33466 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbHZPY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:24:29 -0400
Received: by pacti10 with SMTP id ti10so91396892pac.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 08:24:29 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id eh4sm3590400pbd.27.2015.08.26.08.24.28
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 08:24:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 26 Aug 2015 10:01:30 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 103541] New: netconsole + bonding: WARNING: CPU: 0 PID: 115 at kernel/softirq.c:150 __local_bh_enable_ip+0x6f/0xa0()


https://bugzilla.kernel.org/show_bug.cgi?id=103541

            Bug ID: 103541
           Summary: netconsole + bonding: WARNING: CPU: 0 PID: 115 at
                    kernel/softirq.c:150 __local_bh_enable_ip+0x6f/0xa0()
           Product: Networking
           Version: 2.5
    Kernel Version: 4.1.4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: cbay@excellency.fr
        Regression: No

I upgraded from 3.4 to 4.1 and got a WARNING I'd never seen before:

[   14.389529] bond0: Setting MII monitoring interval to 100
[   14.389653] bond0: MII monitoring cannot be used with ARP monitoring -
disabling ARP monitoring...
[   14.390613] bond0: link status definitely down for interface eth0, disabling
it
[   14.390755] bond0: making interface eth1 the new active one
[   14.390862] ------------[ cut here ]------------
[   14.390866] WARNING: CPU: 0 PID: 115 at kernel/softirq.c:150
__local_bh_enable_ip+0x6f/0xa0()
[   14.390882] Modules linked in: nf_conntrack_ftp ip6t_REJECT nf_reject_ipv6
nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter xt_length xt_NFLOG xt_limit
nf_conntrack_ipv4 nf_defrag_ipv4 xt_recent xt_owner xt_set xt_multiport
xt_conntrack nf_conntrack ip_set_hash_net ip_set nfnetlink_log nfnetlink
ipmi_poweroff ipmi_devintf nfsd nfs_acl auth_rpcgss oid_registry nfs lockd
grace sunrpc netconsole bonding i2c_i801 lpc_ich mfd_core ehci_pci ehci_hcd
ipmi_si ipmi_msghandler igb dca i2c_algo_bit ptp pps_core hwmon usbhid usbcore
usb_common
[   14.390883] CPU: 0 PID: 115 rUID: 0 rGID: 0 Comm: kworker/u16:4 Not tainted
4.1.4 #2
[   14.390884] Hardware name: Supermicro X10SLH-F/X10SLM+-F/X10SLH-F/X10SLM+-F,
BIOS 2.00 04/24/2014
[   14.390887] Workqueue: bond0 bond_mii_monitor [bonding]
[   14.390889]  0000000000000096 ffff8807fa027798 ffffffff9b7388fc
ffff8807fa0277d8
[   14.390890]  ffffffff9b06f4a0 ffff8807fa0277c8 0000000000000200
ffff8807f9f543c8
[   14.390890]  ffff8800016b4780 ffffffffc0210b80 ffff8807fa027830
ffff8807fa0277e8
[   14.390891] Call Trace:
[   14.390894]  [<ffffffff9b7388fc>] dump_stack+0x68/0x74
[   14.390896]  [<ffffffff9b06f4a0>] warn_slowpath_common+0x90/0xd0
[   14.390898]  [<ffffffff9b06f4f5>] warn_slowpath_null+0x15/0x20
[   14.390899]  [<ffffffff9b073a6f>] __local_bh_enable_ip+0x6f/0xa0
[   14.390901]  [<ffffffffc0276c41>] bond_poll_controller+0x101/0x140 [bonding]
[   14.390904]  [<ffffffff9b62915d>] netpoll_poll_dev+0x6d/0x1a0
[   14.390905]  [<ffffffff9b6293fc>] netpoll_send_skb_on_dev+0x16c/0x270
[   14.390906]  [<ffffffff9b6297cf>] netpoll_send_udp+0x2cf/0x420
[   14.390907]  [<ffffffffc029c2d5>] write_msg+0xc5/0x110 [netconsole]
[   14.390910]  [<ffffffff9b0b7080>] call_console_drivers+0xc0/0xe0
[   14.390911]  [<ffffffff9b0b8dc7>] console_unlock+0x317/0x400
[   14.390913]  [<ffffffff9b0b9e4e>] vprintk_emit+0x2ce/0x530
[   14.390914]  [<ffffffff9b0ba0ca>] vprintk_default+0x1a/0x20
[   14.390915]  [<ffffffff9b7387a5>] printk+0x6c/0x6e
[   14.390917]  [<ffffffff9b0ba0ca>] ? vprintk_default+0x1a/0x20
[   14.390918]  [<ffffffff9b7387a5>] ? printk+0x6c/0x6e
[   14.390919]  [<ffffffff9b092710>] ? check_preempt_curr+0x90/0xb0
[   14.390921]  [<ffffffff9b607182>] __netdev_printk+0x152/0x310
[   14.390923]  [<ffffffff9b6073bf>] netdev_info+0x7f/0x90
[   14.390925]  [<ffffffff9b6073bf>] ? netdev_info+0x7f/0x90
[   14.390927]  [<ffffffff9b0880ca>] ? __queue_work+0x1ba/0x350
[   14.390930]  [<ffffffffc02790bd>] bond_change_active_slave+0x13d/0x6f0
[bonding]
[   14.390932]  [<ffffffffc0279861>] bond_select_active_slave+0x121/0x1f0
[bonding]
[   14.390934]  [<ffffffffc027ab13>] bond_mii_monitor+0x5e3/0x740 [bonding]
[   14.390935]  [<ffffffff9b088b7c>] process_one_work+0x18c/0x4a0
[   14.390936]  [<ffffffff9b088fba>] worker_thread+0x12a/0x5d0
[   14.390938]  [<ffffffff9b088e90>] ? process_one_work+0x4a0/0x4a0
[   14.390939]  [<ffffffff9b08e44b>] kthread+0xdb/0xf0
[   14.390940]  [<ffffffff9b08e370>] ? kthread_freezable_should_stop+0x70/0x70
[   14.390942]  [<ffffffff9b73d5e2>] ret_from_fork+0x42/0x70
[   14.390943]  [<ffffffff9b08e370>] ? kthread_freezable_should_stop+0x70/0x70
[   14.390944] ---[ end trace 4f1bbf12d3a796a0 ]---
[   14.548673] bond0: link status definitely down for interface eth1, disabling
it
[   14.548995] bond0: now running without any active interface!
[   14.590642] bond0: Setting ARP monitoring interval to 500

-- 
You are receiving this mail because:
You are the assignee for the bug.
