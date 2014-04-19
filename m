From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: nft 2.0, NULL pointer dereference in 3.14.1
Date: Sat, 19 Apr 2014 10:36:27 +0300
Message-ID: <52ee4b86089383eb7ae8d2bed17e6f8b@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	Pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47165 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaDSHgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2014 03:36:31 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id BF60848051B
	for <netdev@vger.kernel.org>; Sat, 19 Apr 2014 10:36:27 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

While trying nft got kernel NULL dereference
extreme ~ # nft -v
nftables v0.2 (Support Edward Snowden)
extreme ~ # uname -a
Linux extreme 3.14.1-extreme-stable #1 SMP Sat Apr 19 10:23:48 EEST 2014 
x86_64 Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz GenuineIntel GNU/Linux

Command i tried (nothing else entered before it):
nft add rule filter icmp-chain counter

kernel message:
[   44.071555] Netfilter messages via NETLINK v0.30.
[   44.072253] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000119
[   44.072264] IP: [<ffffffff8171db1f>] netlink_getsockbyportid+0xf/0x70
[   44.072272] PGD 7f2b74067 PUD 7f2b73067 PMD 0
[   44.072277] Oops: 0000 [#1] SMP
[   44.072280] Modules linked in: nfnetlink ftdi_sio usbserial 
usb_storage x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm 
iTCO_wdt iTCO_vendor_support mei_me mei lpc_ich mfd_core
[   44.072301] CPU: 4 PID: 2573 Comm: nft Not tainted 
3.14.1-extreme-stable #1
[   44.072304] Hardware name:                  /DH87MC, BIOS 
MCH8710H.86A.0154.2014.0123.1542 01/23/2014
[   44.072308] task: ffff8807f5195340 ti: ffff8807d4c36000 task.ti: 
ffff8807d4c36000
[   44.072311] RIP: 0010:[<ffffffff8171db1f>]  [<ffffffff8171db1f>] 
netlink_getsockbyportid+0xf/0x70
[   44.072317] RSP: 0018:ffff8807d4c37a90  EFLAGS: 00010202
[   44.072319] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 
0000000000000028
[   44.072322] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
0000000000000000
[   44.072325] RBP: ffff8807d4c37a98 R08: 0000000000000000 R09: 
ffff8807f85b0028
[   44.072328] R10: 00000000ffffffff R11: 0000000000000000 R12: 
ffff8807f5de2900
[   44.072331] R13: 0000000000000000 R14: 0000000000000000 R15: 
0000000000000018
[   44.072335] FS:  00007fa028b25700(0000) GS:ffff88081ed00000(0000) 
knlGS:0000000000000000
[   44.072338] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   44.072341] CR2: 0000000000000119 CR3: 00000007f370d000 CR4: 
00000000001407e0
[   44.072343] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[   44.072346] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[   44.072349] Stack:
[   44.072351]  0000000000000040 ffff8807d4c37ad0 ffffffff8171fd81 
0000000000000000
[   44.072357]  ffff8807f5de2900 ffff8807f5de2900 00000000ffffffa1 
ffff8807f85b1600
[   44.072363]  ffff8807d4c37b08 ffffffff817206c9 ffff8807f85b1600 
ffff8807f5de3400
[   44.072369] Call Trace:
[   44.072373]  [<ffffffff8171fd81>] netlink_unicast+0x91/0x200
[   44.072377]  [<ffffffff817206c9>] netlink_ack+0x99/0x110
[   44.072381]  [<ffffffffa004b951>] nfnetlink_rcv+0x3c1/0x408 
[nfnetlink]
[   44.072385]  [<ffffffff8171fde3>] netlink_unicast+0xf3/0x200
[   44.072389]  [<ffffffff817201ef>] netlink_sendmsg+0x2ff/0x740
[   44.072394]  [<ffffffff81044752>] ? __mmdrop+0x62/0x90
[   44.072398]  [<ffffffff816dafdb>] sock_sendmsg+0x8b/0xc0
[   44.072403]  [<ffffffff812f1af5>] ? 
copy_user_enhanced_fast_string+0x5/0x10
[   44.072406]  [<ffffffff816dbb6c>] ? move_addr_to_kernel+0x2c/0x50
[   44.072410]  [<ffffffff816db423>] ___sys_sendmsg+0x3c3/0x3d0
[   44.072415]  [<ffffffff811301ba>] ? handle_mm_fault+0xa9a/0xc60
[   44.072420]  [<ffffffff811362d6>] ? mmap_region+0x166/0x5a0
[   44.072424]  [<ffffffff817da84c>] ? __do_page_fault+0x1dc/0x510
[   44.072428]  [<ffffffff812b8b2c>] ? apparmor_capable+0x1c/0x60
[   44.072435]  [<ffffffff817d6e9a>] ? _raw_spin_unlock_bh+0x1a/0x20
[   44.072439]  [<ffffffff816dfc86>] ? release_sock+0x106/0x150
[   44.072443]  [<ffffffff816dc212>] __sys_sendmsg+0x42/0x80
[   44.072446]  [<ffffffff816dc262>] SyS_sendmsg+0x12/0x20
[   44.072450]  [<ffffffff817df616>] system_call_fastpath+0x1a/0x1f
[   44.072453] Code: 41 5d 41 5e 5d c3 66 0f 1f 44 00 00 f0 ff 43 4c eb 
e1 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 89 f2 48 89 e5 53 48 
89 fb <0f> b6 b7 19 01 00 00 48 8b 7f 30 e8 f1 fe ff ff 48 89 c7 48 c7
[   44.072963] RIP  [<ffffffff8171db1f>] 
netlink_getsockbyportid+0xf/0x70
[   44.073253]  RSP <ffff8807d4c37a90>
[   44.073524] CR2: 0000000000000119
[   44.074757] ---[ end trace f3a9846ab3cb7550 ]---

Please let me know if more information required.
Thanks!
