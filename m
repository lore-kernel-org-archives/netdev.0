From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] Couple of classifier fixes
Date: Fri, 17 Jul 2015 22:38:42 +0200
Message-ID: <cover.1437163466.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56616 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbGQUi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a couple of panics in the form of (analogous for
cls_flow{,er}):

[  912.759276] BUG: unable to handle kernel NULL pointer dereference at (null)
[  912.759373] IP: [<ffffffffa09d4d6d>] cls_bpf_change+0x23d/0x268 [cls_bpf]
[  912.759441] PGD 8783c067 PUD 5f684067 PMD 0 
[  912.759491] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC 
[  912.759543] Modules linked in: cls_bpf(E) act_gact [...]
[  912.772734] CPU: 3 PID: 10489 Comm: tc Tainted: G        W   E   4.2.0-rc2+ #73
[  912.775004] Hardware name: Apple Inc. MacBookAir5,1/Mac-66F35F19FE2A0D05, BIOS MBA51.88Z.00EF.B02.1211271028 11/27/2012
[  912.777327] task: ffff88025eaa8000 ti: ffff88005f734000 task.ti: ffff88005f734000
[  912.779662] RIP: 0010:[<ffffffffa09d4d6d>]  [<ffffffffa09d4d6d>] cls_bpf_change+0x23d/0x268 [cls_bpf]
[  912.781991] RSP: 0018:ffff88005f7379c8  EFLAGS: 00010286
[  912.784183] RAX: ffff880201d64e48 RBX: 0000000000000000 RCX: ffff880201d64e40
[  912.786402] RDX: 0000000000000000 RSI: ffffffffa09d51c0 RDI: ffffffffa09d51a6
[  912.788625] RBP: ffff88005f737a68 R08: 0000000000000000 R09: 0000000000000000
[  912.790854] R10: 0000000000000001 R11: 0000000000000001 R12: ffff880078ab5a80
[  912.793082] R13: ffff880232b31570 R14: ffff88005f737ae0 R15: ffff8801e215d1d0
[  912.795181] FS:  00007f3c0c80d740(0000) GS:ffff880265400000(0000) knlGS:0000000000000000
[  912.797281] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  912.799402] CR2: 0000000000000000 CR3: 000000005460f000 CR4: 00000000001407e0
[  912.799403] Stack:
[  912.799407]  ffffffff00000000 ffff88023ea18000 000000005f737a08 0000000000000000
[  912.799415]  ffffffff81f06140 ffff880201d64e40 0000000000000000 ffff88023ea1804c
[  912.799418]  0000000000000000 ffff88023ea18044 ffff88023ea18030 ffff88023ea18038
[  912.799418] Call Trace:
[  912.799437]  [<ffffffff816d5685>] tc_ctl_tfilter+0x335/0x910
[  912.799443]  [<ffffffff813622a8>] ? security_capable+0x48/0x60
[  912.799448]  [<ffffffff816b90e5>] rtnetlink_rcv_msg+0x95/0x240
[  912.799454]  [<ffffffff810f612d>] ? trace_hardirqs_on+0xd/0x10
[  912.799456]  [<ffffffff816b902f>] ? rtnetlink_rcv+0x1f/0x40
[  912.799459]  [<ffffffff816b902f>] ? rtnetlink_rcv+0x1f/0x40
[  912.799461]  [<ffffffff816b9050>] ? rtnetlink_rcv+0x40/0x40
[  912.799464]  [<ffffffff816df38f>] netlink_rcv_skb+0xaf/0xc0
[  912.799467]  [<ffffffff816b903e>] rtnetlink_rcv+0x2e/0x40
[  912.799469]  [<ffffffff816deaef>] netlink_unicast+0xef/0x1b0
[  912.799471]  [<ffffffff816defa0>] netlink_sendmsg+0x3f0/0x620
[  912.799476]  [<ffffffff81687028>] sock_sendmsg+0x38/0x50
[  912.799479]  [<ffffffff81687938>] ___sys_sendmsg+0x288/0x290
[  912.799482]  [<ffffffff810f7852>] ? __lock_acquire+0x572/0x2050
[  912.799488]  [<ffffffff810265db>] ? native_sched_clock+0x2b/0x90
[  912.799493]  [<ffffffff8116135f>] ? __audit_syscall_entry+0xaf/0x100
[  912.799497]  [<ffffffff8116135f>] ? __audit_syscall_entry+0xaf/0x100
[  912.799501]  [<ffffffff8112aa19>] ? current_kernel_time+0x69/0xd0
[  912.799505]  [<ffffffff81266f16>] ? __fget_light+0x66/0x90
[  912.799508]  [<ffffffff81688812>] __sys_sendmsg+0x42/0x80
[  912.799510]  [<ffffffff81688862>] SyS_sendmsg+0x12/0x20
[  912.799515]  [<ffffffff817f9a6e>] entry_SYSCALL_64_fastpath+0x12/0x76
[  912.799540] Code: 4d 88 49 8b 57 08 48 89 51 08 49 8b 57 10 48 89 c8 48 83 c0 08 48
                     89 51 10 48 8b 51 10 48 c7 c6 c0 51 9d a0 48 c7 c7 a6 51 9d a0 <48>
                     89 02 48 8b 51 08 48 89 42 08 48 b8 00 02 20 00 00 00 ad de 
[  912.799544] RIP  [<ffffffffa09d4d6d>] cls_bpf_change+0x23d/0x268 [cls_bpf]
[  912.799544]  RSP <ffff88005f7379c8>
[  912.799545] CR2: 0000000000000000
[  912.807380] ---[ end trace a6440067cfdc7c29 ]---

I've split them into 3 patches, so they can be backported easier
when needed.

Thanks!

Daniel Borkmann (3):
  sched: cls_bpf: fix panic on filter replace
  sched: cls_flower: fix panic on filter replace
  sched: cls_flow: fix panic on filter replace

 net/sched/cls_bpf.c    | 2 +-
 net/sched/cls_flow.c   | 5 +++--
 net/sched/cls_flower.c | 2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

-- 
1.9.3
