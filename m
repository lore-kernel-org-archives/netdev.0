From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Tue, 10 Jul 2012 10:16:55 +0300
Message-ID: <alpine.LRH.2.00.1207101008270.9760@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:44423 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751174Ab2GJHcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 03:32:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Using latest net-next (061a5c316b6526dbc729049a16243ec27937cc31) I
get the below crash during the boot cycle. The crash happens on a set of
nodes which use igb for their onboard 1g nic, as soon as the device goes
up. Another group, that uses a 2nd lab, where the nodes use bnx2 for 1g
NIC doesn't get this crash, but the kernel there is built by a different
.config .

Or.

Bringing up loopback interface:  [  OK  ]
Bringing up interface eth1:
Determining IP information for eth1...IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
igb: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Starting system logger: BUG: unable to handle kernel NULL pointer dereference at 00000000000000ac
IP: [<ffffffff81320393>] fib_rules_tclass+0xf/0x17
PGD 223171067 PUD 22353e067 PMD 0
Oops: 0000 [#1] SMP
CPU 0
Modules linked in:
 ipv6 dm_mirror dm_region_hash dm_log uinput igb ptp pps_core mlx4_ib ib_mad ib_core mlx4_en mlx4_core sg kvm_intel kvm microcode pcspkr rng_core ioatdma dca shpchp dm_mod button sr_mod ext3 jbd sd_mod usb_storage ata_piix libata scsi_mod ehci_hcd uhci_hcd floppy [last unloaded: scsi_wait_scan]

Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc5-12540-g061a5c3-dirty #94 Supermicro X7DWU/X7DWU
RIP: 0010:[<ffffffff81320393>]  [<ffffffff81320393>] fib_rules_tclass+0xf/0x17
RSP: 0018:ffff88022fc03a30  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffff88022fc03b54 RCX: 0000000000000050
RDX: 0000000000000020 RSI: 0000000000000001 RDI: ffff88022fc03a40
RBP: ffff88022fc03a30 R08: ffff88022fc03a70 R09: ffff88022fc03a40
R10: 0000000000000020 R11: ffff880225390a80 R12: 0000000000000001
R13: ffff88021cc7a000 R14: 0000000000000000 R15: ffff8802269c26c0
FS:  0000000000000000(0000) GS:ffff88022fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000000ac CR3: 0000000222aeb000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/0 (pid: 0, threadinfo ffffffff81600000, task ffffffff81613410)
Stack:
 ffff88022fc03ac0 ffffffff81318956 ffff8802fd010010 ffff8802232d5a80
 ffff880222add880 ffff880223269a98 0000000000000020 ffff880200000000
 0000000100000000 ffff000000000000 12311eac2540eaf0 ffff88027e001eac
Call Trace:
 <IRQ>

 [<ffffffff81318956>] fib_validate_source+0x170/0x2a5
 [<ffffffff812e6603>] ip_route_input_common+0x6fe/0xd12
 [<ffffffff812e8380>] ? ip_rcv_finish+0x70/0x457
 [<ffffffff812e8461>] ip_rcv_finish+0x151/0x457
 [<ffffffff812e8380>] ? ip_rcv_finish+0x70/0x457
 [<ffffffff812e89a1>] ip_rcv+0x23a/0x260
 [<ffffffff812beae7>] __netif_receive_skb+0x3ac/0x415
 [<ffffffff812be86f>] ? __netif_receive_skb+0x134/0x415
 [<ffffffff81312ae5>] ? inet_gro_receive+0x81/0x23f
 [<ffffffff812b68da>] ? skb_free_head+0x47/0x49
 [<ffffffff812c035d>] netif_receive_skb+0xee/0xf7
 [<ffffffff812c071d>] ? dev_gro_receive+0x15f/0x2fb
 [<ffffffff812c063a>] ? dev_gro_receive+0x7c/0x2fb
 [<ffffffff81065644>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff812c044c>] napi_skb_finish+0x24/0x56
 [<ffffffff812c0bf0>] napi_gro_receive+0x10f/0x11e
 [<ffffffffa0216e85>] igb_poll+0x843/0xae5 [igb]
 [<ffffffff812c0e01>] ? net_rx_action+0x14c/0x1ee
 [<ffffffff812c0d76>] net_rx_action+0xc1/0x1ee
 [<ffffffff8102f746>] __do_softirq+0xff/0x1de
 [<ffffffff813631cc>] call_softirq+0x1c/0x26
 [<ffffffff81003090>] do_softirq+0x38/0x80
 [<ffffffff8102f41f>] irq_exit+0x4e/0x83
 [<ffffffff810028f9>] do_IRQ+0x98/0xaf
 [<ffffffff8135b52c>] common_interrupt+0x6c/0x6c
 <EOI>

 [<ffffffff810083ec>] ? mwait_idle+0x13c/0x208
 [<ffffffff810083e3>] ? mwait_idle+0x133/0x208
 [<ffffffff810088d1>] cpu_idle+0x6e/0xab
 [<ffffffff81343e13>] rest_init+0xc7/0xce
 [<ffffffff81343d4c>] ? csum_partial_copy_generic+0x16c/0x16c
 [<ffffffff8167fbf3>] start_kernel+0x332/0x33f
 [<ffffffff8167f6f6>] ? kernel_init+0x19d/0x19d
 [<ffffffff8167f2b4>] x86_64_start_reservations+0xb8/0xbd
 [<ffffffff8167f3a6>] x86_64_start_kernel+0xed/0xf4
Code: 81 31 c0 e8 a5 bb dd ff 48 83 c4 28 31 c0 5b 41 5c 41 5d 41 5e 41 5f c9 c3 90 90 90 48 8b 57 20 55 31 c0 48 89 e5 48 85 d2 74 06 <8b> 82 8c 00 00 00 c9 c3 8b 47 7c 33 46 14 85 87 80 00 00 00 55
RIP  [<ffffffff81320393>] fib_rules_tclass+0xf/0x17
 RSP <ffff88022fc03a30>
CR2: 00000000000000ac
---[ end trace e7c6714b8de1c341 ]---
Kernel panic - not syncing: Fatal exception in interrupt
