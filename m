From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: crash when setting ovs instance over net-next
Date: Thu, 5 Feb 2015 09:32:45 +0200
Message-ID: <54D31C9D.9040607@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0055.outbound.protection.outlook.com ([157.56.112.55]:23936
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750710AbbBEHeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 02:34:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With latest net-next (commit 06eb395 "pkt_sched: fq: better control of 
DDOS traffic")
under the below config [2], I see this crash [1], will send you also my 
.config

The user-space bits are openvswitch-2.0.90-1 rpm built from the git.

Or.

[1] crash

general protection fault: 0000 [#1] SMP
Modules linked in: vport_vxlan openvswitch crc32c_generic libcrc32c 
rdma_ucm rdma_cm iw_cm ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib 
vxlan udp_tunnel ip6_udp_tunnel ib_sa ib_mad ib_core ib_addr ipv6 
mlx4_core dm_mirror dm_region_hash dm_log dm_mod igb ptp pps_core sg 
joydev microcode ehci_pci ehci_hcd pcspkr rng_core ioatdma dca shpchp 
button sr_mod ext3 jbd floppy usb_storage sd_mod ata_generic ata_piix 
libata scsi_mod uhci_hcd radeon ttm drm_kms_helper hwmon
CPU: 1 PID: 2818 Comm: upcall_2 Tainted: G          I 
3.19.0-rc6-net-next+ #457
Hardware name: Supermicro X7DWU/X7DWU, BIOS  1.1 04/30/2008
task: ffff8802244d1000 ti: ffff880213de8000 task.ti: ffff880213de8000
RIP: 0010:[<ffffffff8111df0e>] [<ffffffff8111df0e>] kfree+0xac/0x196
RSP: 0018:ffff880213deb998  EFLAGS: 00010207
RAX: ffffea0000000000 RBX: 5709530001977006 RCX: 0000000000000028
RDX: 0000000000000001 RSI: 0000000000000000 RDI: 5709530001977006
RBP: ffff880213deb9c8 R08: 0000000000000000 R09: 0000000000000000
R10: ffff880213deb9d8 R11: 0000000000000000 R12: 015c112c00065dc0
R13: ffffffffa060bd87 R14: ffff880223f12240 R15: ffff880215038288
FS:  00007fb5ed7b5700(0000) GS:ffff88022fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000465e40 CR3: 0000000213273000 CR4: 00000000000007e0
Stack:
  ffff88022485e800 ffff880215038220 ffff880215038220 ffff88022485e800
  ffff880223f12240 ffff880215038288 ffff880213deb9e8 ffffffffa060bd87
  ffff880215038220 ffff880215194800 ffff880213deb9f8 ffffffffa060bde0
Call Trace:
  [<ffffffffa060bd87>] flow_free+0x21/0x59 [openvswitch]
  [<ffffffffa060bde0>] ovs_flow_free+0x21/0x23 [openvswitch]
  [<ffffffffa0605b4a>] ovs_packet_cmd_execute+0x2f3/0x35f [openvswitch]
  [<ffffffffa0605995>] ? ovs_packet_cmd_execute+0x13e/0x35f [openvswitch]
  [<ffffffff811fe6fb>] ? nla_parse+0x4f/0xec
  [<ffffffff8139a2fc>] genl_family_rcv_msg+0x26d/0x2c9
  [<ffffffff8107620f>] ? __lock_acquire+0x90e/0x9aa
  [<ffffffff8139a3be>] genl_rcv_msg+0x66/0x89
  [<ffffffff8139a358>] ? genl_family_rcv_msg+0x2c9/0x2c9
  [<ffffffff81399591>] netlink_rcv_skb+0x3e/0x95
  [<ffffffff81399898>] ? genl_rcv+0x18/0x37
  [<ffffffff813998a7>] genl_rcv+0x27/0x37
  [<ffffffff81399033>] netlink_unicast+0x103/0x191
  [<ffffffff81399382>] netlink_sendmsg+0x2c1/0x310
  [<ffffffff811007ad>] ? might_fault+0x50/0xa0
  [<ffffffff8135c773>] do_sock_sendmsg+0x5f/0x7a
  [<ffffffff8135c799>] sock_sendmsg+0xb/0xd
  [<ffffffff8135cacf>] ___sys_sendmsg+0x1a3/0x218
  [<ffffffff8113e54b>] ? get_close_on_exec+0x86/0x86
  [<ffffffff8115a9d0>] ? fsnotify+0x32c/0x348
  [<ffffffff8115a720>] ? fsnotify+0x7c/0x348
  [<ffffffff8113e5f5>] ? __fget+0xaa/0xbf
  [<ffffffff8113e54b>] ? get_close_on_exec+0x86/0x86
  [<ffffffff8135cccd>] __sys_sendmsg+0x3d/0x5e
  [<ffffffff8135cd02>] SyS_sendmsg+0x14/0x16
  [<ffffffff81411852>] system_call_fastpath+0x12/0x17
Code: b8 00 00 00 80 ff 77 00 00 eb 07 48 8b 05 1b 81 8f 00 4e 8d 24 20 
48 b8 00 00 00 00 00 ea ff ff 49 c1 ec 0c 49 c1 e4 06 49 01 c4 <49> 8b 
04 24 66 85 c0 79 10 49 8b 44 24 30 49 8b 14 24 66 85 d2
RIP  [<ffffffff8111df0e>] kfree+0xac/0x196
  RSP <ffff880213deb998>
---[ end trace 7f18bf585a5b229c ]---


[2] config
$ ovs-vsctl show
0ea2d6c6-93d0-4e5d-ad99-d47213bb0bf1
     Bridge ovs-tun
         Port "vxlan0"
             Interface "vxlan0"
                 type: vxlan
                 options: {dst_port="4789", key="98", 
remote_ip="192.168.31.18"}
         Port ovs-tun
             Interface ovs-tun
                 type: internal
         Port "veth3"
             Interface "veth3"
         Port "veth1"
             Interface "veth1"
     ovs_version: "2.0.90"
