From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE:  2.6.34.1: kernel warning at igb_main.c:2080
Date: Fri, 23 Jul 2010 14:48:19 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318FE1DF9DC1@orsmsx508.amr.corp.intel.com>
References: <4C3FA03E.9090802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63346 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756033Ab0GWVsW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 17:48:22 -0400
In-Reply-To: <4C3FA03E.9090802@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

I'm not exactly sure why this happened and there's not a lot of info from the kernel, unfortunately.  I've looked at the location in the code and it doesn't give me much more.  Let me know if it is happening regularly and if you have steps to reliably reproduce it and we can look at it further. 

We do appreciate the report.

Thanks,

Carolyn

>-----Original Message-----
>From: netdev-owner@vger.kernel.org 
>[mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Greear
>Sent: Thursday, July 15, 2010 4:57 PM
>To: NetDev
>Subject: igb: 2.6.34.1: kernel warning at igb_main.c:2080
>
>We just saw this kernel warning on 2.6.34.1 + a few patches 
>from the pending stable queue,
>plus our own hacks (though none to igb).
>
>We were running a modified version of pktgen traffic and at 
>the same time
>bounced the port.
>
>This warning didn't seem to cause any real problems.
>
>Please let us know if you would like any additional information.
>
>]# lspci|grep Ethern
>01:00.0 Ethernet controller: Intel Corporation 82574L Gigabit 
>Network Connection
>02:00.0 Ethernet controller: Intel Corporation 82574L Gigabit 
>Network Connection
>05:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit 
>Network Connection (rev 02)
>05:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit 
>Network Connection (rev 02)
>06:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit 
>Network Connection (rev 02)
>06:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit 
>Network Connection (rev 02)
>
>
>Jul 15 16:36:01 localhost kernel: ------------[ cut here ]------------
>Jul 15 16:36:01 localhost kernel: WARNING: at 
>/home/greearb/git/linux-2.6.dev.34.y/drivers/net/igb/igb_main.c
>:2080 igb_close+0x28/0x9f [igb]()
>Jul 15 16:36:01 localhost kernel: Hardware name: X8STi
>Jul 15 16:36:01 localhost kernel: Modules linked in: bridge 
>arc4 michael_mic wanlink(P) 8021q garp xt_CT iptable_raw 
>ipt_addrtype xt_DSCP xt_dscp xt_string 
>xt_owner xt_NFQUEUE xt_multiport xt_mark xt_iprange 
>xt_hashlimit xt_CONNMARK xt_connmark stp llc veth fuse macvlan 
>bpctl_mod pktgen iscsi_tcp libiscsi_tcp 
>libiscsi scsi_transport_iscsi nfs lockd fscache nfs_acl 
>auth_rpcgss sunrpc ipv6 dm_multipath uinput i2c_i801 iTCO_wdt 
>i2c_core ioatdma e1000e igb pcspkr 
>iTCO_vendor_support dca ata_generic pata_acpi [last unloaded: nf_nat]
>Jul 15 16:36:01 localhost kernel: Pid: 17516, comm: ip 
>Tainted: P           2.6.34.1 #2
>Jul 15 16:36:01 localhost kernel: Call Trace:
>Jul 15 16:36:01 localhost kernel: [<ffffffffa002a37f>] ? 
>igb_close+0x28/0x9f [igb]
>Jul 15 16:36:01 localhost kernel: [<ffffffff81041bb6>] 
>warn_slowpath_common+0x77/0x8f
>Jul 15 16:36:01 localhost kernel: [<ffffffff81041bdd>] 
>warn_slowpath_null+0xf/0x11
>Jul 15 16:36:01 localhost kernel: [<ffffffffa002a37f>] 
>igb_close+0x28/0x9f [igb]
>Jul 15 16:36:01 localhost kernel: [<ffffffff8133c626>] 
>__dev_close+0x73/0x86
>Jul 15 16:36:01 localhost kernel: [<ffffffff8133a719>] 
>__dev_change_flags+0xa8/0x12b
>Jul 15 16:36:01 localhost kernel: [<ffffffff8133c2aa>] 
>dev_change_flags+0x1c/0x51
>Jul 15 16:36:01 localhost kernel: [<ffffffff813466bc>] 
>do_setlink+0x273/0x482
>Jul 15 16:36:01 localhost kernel: [<ffffffff810ab1bb>] ? 
>zone_statistics+0x5e/0x63
>Jul 15 16:36:01 localhost kernel: [<ffffffff8134755e>] 
>rtnl_newlink+0x26c/0x422
>Jul 15 16:36:01 localhost kernel: [<ffffffff81345a06>] ? 
>nla_nest_start+0x1d/0x31
>Jul 15 16:36:01 localhost kernel: [<ffffffff810ca997>] ? 
>virt_to_head_page+0x9/0x2a
>Jul 15 16:36:01 localhost kernel: [<ffffffff813dd1f5>] ? 
>__mutex_lock_common+0x38e/0x3ac
>Jul 15 16:36:01 localhost kernel: [<ffffffff81346ffb>] 
>rtnetlink_rcv_msg+0x1d9/0x1f7
>Jul 15 16:36:01 localhost kernel: [<ffffffff81346e22>] ? 
>rtnetlink_rcv_msg+0x0/0x1f7
>Jul 15 16:36:01 localhost kernel: [<ffffffff81356939>] 
>netlink_rcv_skb+0x3e/0x8e
>Jul 15 16:36:01 localhost kernel: [<ffffffff81346cc9>] 
>rtnetlink_rcv+0x20/0x29
>Jul 15 16:36:01 localhost kernel: [<ffffffff813567b2>] 
>netlink_unicast+0xea/0x151
>Jul 15 16:36:01 localhost kernel: [<ffffffff8133545c>] ? 
>memcpy_fromiovec+0x42/0x73
>Jul 15 16:36:01 localhost kernel: [<ffffffff81357bc8>] 
>netlink_sendmsg+0x242/0x255
>Jul 15 16:36:01 localhost kernel: [<ffffffff8132a771>] ? 
>__sock_recvmsg_nosec+0x29/0x2b
>Jul 15 16:36:01 localhost kernel: [<ffffffff8132bd02>] 
>__sock_sendmsg+0x56/0x5f
>Jul 15 16:36:01 localhost kernel: [<ffffffff8132c127>] 
>sock_sendmsg+0xa3/0xbc
>Jul 15 16:36:01 localhost kernel: [<ffffffff813351e5>] ? 
>copy_from_user+0x28/0x30
>Jul 15 16:36:01 localhost kernel: [<ffffffff8133555e>] ? 
>verify_iovec+0x52/0x95
>Jul 15 16:36:01 localhost kernel: [<ffffffff8132c368>] 
>sys_sendmsg+0x1c6/0x22a
>Jul 15 16:36:01 localhost kernel: [<ffffffff810a277f>] ? 
>lru_cache_add_lru+0x38/0x3d
>Jul 15 16:36:01 localhost kernel: [<ffffffff813de23e>] ? 
>_raw_spin_unlock+0x2d/0x38
>Jul 15 16:36:01 localhost kernel: [<ffffffff810ad802>] ? 
>spin_unlock+0x9/0xb
>Jul 15 16:36:01 localhost kernel: [<ffffffff810b0138>] ? 
>handle_mm_fault+0x6d3/0x6f3
>Jul 15 16:36:01 localhost kernel: [<ffffffff810b3a0a>] ? 
>__vma_link_rb+0x2b/0x2d
>Jul 15 16:36:01 localhost kernel: [<ffffffff810b45f7>] ? 
>vma_link+0xcd/0xcf
>Jul 15 16:36:01 localhost kernel: [<ffffffff810d9369>] ? 
>fget_light+0x39/0x87
>Jul 15 16:36:01 localhost kernel: [<ffffffff81083b91>] ? 
>audit_syscall_entry+0xfe/0x12a
>Jul 15 16:36:01 localhost kernel: [<ffffffff81009ac2>] 
>system_call_fastpath+0x16/0x1b
>Jul 15 16:36:01 localhost kernel: ---[ end trace 75242fae6dbfdf6d ]---
>
>
>Thanks,
>Ben
>
>-- 
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>