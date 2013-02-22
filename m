From: Sasha Levin <sasha.levin@oracle.com>
Subject: batman-adv: gpf in batadv_slide_own_bcast_window
Date: Fri, 22 Feb 2013 11:54:07 -0500
Message-ID: <5127A2AF.9030502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47399 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757639Ab3BVQyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 11:54:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel
I've stumbled on the following:

[ 3148.615130] batman_adv: <98>\<AE><A4><C7>^?: Removing interface: eth0
[ 3148.991938] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3148.993736] Dumping ftrace buffer:
[ 3148.997554]    (ftrace buffer empty)
[ 3148.998426] Modules linked in:
[ 3148.999135] CPU 3
[ 3148.999606] Pid: 6, comm: kworker/u:0 Tainted: G        W    3.8.0-next-20130222-sasha-00038-gba27e20-dirty #11
[ 3149.001223] RIP: 0010:[<ffffffff83d217d8>]  [<ffffffff83d217d8>] batadv_slide_own_bcast_window+0xb8/0x2b0
[ 3149.001223] RSP: 0018:ffff8800b9f4fc58  EFLAGS: 00010246
[ 3149.001223] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000001
[ 3149.001223] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
[ 3149.001223] RBP: ffff8800b9f4fcb8 R08: 0000000000000002 R09: ffff8800b9f63950
[ 3149.001223] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800abad2238
[ 3149.001223] R13: 6b6b6b6b6b6b865b R14: ffff88004c13cda0 R15: 0000000000000001
[ 3149.001223] FS:  0000000000000000(0000) GS:ffff8800bbc00000(0000) knlGS:0000000000000000
[ 3149.001223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3149.001223] CR2: 00007f006711f1d0 CR3: 000000008258e000 CR4: 00000000000406e0
[ 3149.001223] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3149.001223] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3149.001223] Process kworker/u:0 (pid: 6, threadinfo ffff8800b9f4e000, task ffff8800b9f63000)
[ 3149.001223] Stack:
[ 3149.001223]  ffffffff83d21760 ffff8800b9f63000 ffff8800abad2238 0000000000000000
[ 3149.001223]  ffff880068f6c438 0000035e00000001 ffff8800b9f4fc98 0000000000000000
[ 3149.001223]  ffff8800abad2238 ffff88004c13c2a0 ffff88004c13cda0 0000000000000001
[ 3149.001223] Call Trace:
[ 3149.001223]  [<ffffffff83d21760>] ? batadv_slide_own_bcast_window+0x40/0x2b0
[ 3149.001223]  [<ffffffff83d10ee4>] batadv_iv_ogm_schedule+0x254/0x300
[ 3149.001223]  [<ffffffff83d10c90>] ? batadv_iv_ogm_queue_add+0x710/0x710
[ 3149.001223]  [<ffffffff811178bf>] ? local_bh_enable_ip+0xef/0x150
[ 3149.001223]  [<ffffffff83d25a15>] batadv_send_outstanding_bat_ogm_packet+0xc5/0xf0
[ 3149.001223]  [<ffffffff81133ce6>] process_one_work+0x366/0x6a0
[ 3149.001223]  [<ffffffff81133ba8>] ? process_one_work+0x228/0x6a0
[ 3149.001223]  [<ffffffff811345a8>] worker_thread+0x238/0x370
[ 3149.001223]  [<ffffffff81134370>] ? rescuer_thread+0x310/0x310
[ 3149.001223]  [<ffffffff8113eb73>] kthread+0xe3/0xf0
[ 3149.001223]  [<ffffffff8113ea90>] ? flush_kthread_work+0x1f0/0x1f0
[ 3149.001223]  [<ffffffff83dc203c>] ret_from_fork+0x7c/0xb0
[ 3149.001223]  [<ffffffff8113ea90>] ? flush_kthread_work+0x1f0/0x1f0
[ 3149.001223] Code: 31 4b fd 85 c0 74 24 48 c7 c2 50 cd bd 84 be 02 03 00 00 48 c7 c7 b4 da bd 84 c6 05 14 ab 16 02 01 e8 ed 16
46 fd 0f 1f 44 00 00 <49> 8b 55 00 48 89 55 b8 e8 0b 55 41 fd 85 c0 74 37 80 3d ee aa
[ 3149.001223] RIP  [<ffffffff83d217d8>] batadv_slide_own_bcast_window+0xb8/0x2b0
[ 3149.001223]  RSP <ffff8800b9f4fc58>
[ 3149.105631] ---[ end trace ba69e369627c73e7 ]---

Rip points to:

        for (i = 0; i < hash->size; i++) {
                head = &hash->table[i];

                rcu_read_lock();
                hlist_for_each_entry_rcu(orig_node, head, hash_entry) { <--- here
                        spin_lock_bh(&orig_node->ogm_cnt_lock);
                        word_index = hard_iface->if_num * BATADV_NUM_WORDS;
                        word = &(orig_node->bcast_own[word_index]);


Thanks,
Sasha
