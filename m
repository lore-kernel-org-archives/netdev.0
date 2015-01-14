From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: 3.19-rc4:  BUG: unable to handle kernel paging request at ffff880055f15000 ovs_packet_cmd_execute+0x1f/0x229
Date: Wed, 14 Jan 2015 13:14:20 +0100
Message-ID: <1645184106.20150114131420@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	<linux-kernel@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I was testing 3.19-rc4 with openvswitch and encountered the splat below.

#addr2line -e /boot/vmlinux-3.19.0-rc4-creanuc-20150114-doflr-apicpatchv3-apicrevert+ ffffffff818a1690
/mnt/kernelbuild/linux-tip/net/openvswitch/datapath.c:527
--
Sander

[  463.033308] BUG: unable to handle kernel paging request at ffff880055f15000
[  463.072154] IP: [<ffffffff818a1690>] ovs_packet_cmd_execute+0x1f/0x229
[  463.106202] PGD 1e10067 PUD 2097067 PMD 5ff54067 PTE 0
[  463.126940] Oops: 0000 [#1] SMP
[  463.147505] Modules linked in:
[  463.166938] CPU: 2 PID: 3049 Comm: ovs-vswitchd Not tainted 3.19.0-rc4-creanuc-20150114-doflr-apicpatchv3-apicrevert+ #1
[  463.187507] Hardware name:                  /D53427RKE, BIOS RKPPT10H.86A.0017.2013.0425.1251 04/25/2013
[  463.208553] task: ffff880058d30000 ti: ffff880055c38000 task.ti: ffff880055c38000
[  463.229734] RIP: e030:[<ffffffff818a1690>]  [<ffffffff818a1690>] ovs_packet_cmd_execute+0x1f/0x229
[  463.251082] RSP: e02b:ffff880055c3ba48  EFLAGS: 00010296
[  463.271786] RAX: ffff88004fe38818 RBX: ffffffff81ed4cc0 RCX: 0000000000000000
[  463.293072] RDX: ffff880055c3bb00 RSI: ffff880055c3bad0 RDI: ffff8800559dc700
[  463.314521] RBP: ffff8800559dc700 R08: ffffffff81b08d00 R09: 000000007ffff000
[  463.336189] R10: ffff88004fe38814 R11: ffffffff81ed4cc0 R12: ffff880055f14fc0
[  463.356906] R13: ffff88004fe38800 R14: ffff880055f14fc0 R15: ffffffff81b08c60
[  463.377482] FS:  00007f196321c700(0000) GS:ffff88005f700000(0000) knlGS:ffff88005f680000
[  463.398646] CS:  e033 DS: 0000 ES: 0000 CR0: 0000000080050033
[  463.419995] CR2: ffff880055f15000 CR3: 000000005622e000 CR4: 0000000000042660
[  463.441577] Stack:
[  463.462975]  000000000000000c ffff88004fe38814 0000000000000005 ffffffff8130b116
[  463.485114]  ffffffff81ed4cc0 ffffffff81ed4cc0 ffff8800559dc700 ffff880055f14fc0
[  463.507367]  ffff88004fe38800 0000000000000008 ffffffff81b08c60 ffffffff81794364
[  463.530186] Call Trace:
[  463.552330]  [<ffffffff8130b116>] ? nla_parse+0x57/0xe7
[  463.574869]  [<ffffffff81794364>] ? genl_family_rcv_msg+0x243/0x2a9
[  463.597276]  [<ffffffff818ad9a2>] ? __slab_alloc.constprop.63+0x2bb/0x2e5
[  463.619394]  [<ffffffff81794402>] ? genl_rcv_msg+0x38/0x5b
[  463.641361]  [<ffffffff817911a6>] ? __netlink_lookup+0x3a/0x40
[  463.663192]  [<ffffffff817943ca>] ? genl_family_rcv_msg+0x2a9/0x2a9
[  463.685141]  [<ffffffff81793686>] ? netlink_rcv_skb+0x36/0x7c
[  463.706874]  [<ffffffff81793987>] ? genl_rcv+0x1f/0x2c
[  463.729152]  [<ffffffff817930ea>] ? netlink_unicast+0x100/0x19c
[  463.751315]  [<ffffffff8179350d>] ? netlink_sendmsg+0x311/0x36b
[  463.772483]  [<ffffffff8173d574>] ? do_sock_sendmsg+0x62/0x7b
[  463.793309]  [<ffffffff8173e6ce>] ? copy_msghdr_from_user+0x158/0x17c
[  463.814032]  [<ffffffff8173e94c>] ? ___sys_sendmsg+0x11f/0x197
[  463.834595]  [<ffffffff8173ddfd>] ? sock_poll+0xf2/0xfd
[  463.854970]  [<ffffffff81136d27>] ? ep_send_events_proc+0x91/0x153
[  463.875603]  [<ffffffff81136c96>] ? ep_read_events_proc+0x92/0x92
[  463.896168]  [<ffffffff818b6929>] ? _raw_spin_unlock_irqrestore+0x42/0x5b
[  463.917050]  [<ffffffff8113759c>] ? ep_scan_ready_list.isra.14+0x163/0x182
[  463.938458]  [<ffffffff81137820>] ? ep_poll+0x250/0x2c4
[  463.958214]  [<ffffffff8173f410>] ? __sys_sendmsg+0x3b/0x5d
[  463.977581]  [<ffffffff818b6da9>] ? system_call_fastpath+0x12/0x17
[  463.996860] Code: ff 89 d8 5b 5d 41 5c 41 5d 41 5e c3 41 57 41 56 41 55 41 54 55 53 48 83 ec 28 48 8b 46 18 4c 8b 76 20 48 89 44 24 08 49 8b 46 08 <49> 8b 6e 40 48 85 c0 0f 84 e0 01 00 00 49 83 7e 10 00 0f 84 d5
[  464.037236] RIP  [<ffffffff818a1690>] ovs_packet_cmd_execute+0x1f/0x229
[  464.056926]  RSP <ffff880055c3ba48>
[  464.076182] CR2: ffff880055f15000
[  464.095097] ---[ end trace 8bcb28ced5309e55 ]---
