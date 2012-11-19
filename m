From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net,
	batman: don't crash on zero length strings in routing_algo
Date: Mon, 19 Nov 2012 15:08:15 -0500
Message-ID: <1353355695-23252-1-git-send-email-sasha.levin@oracle.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: lindner_marek-LWAfsSFWpa4@public.gmane.org, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org, ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

The code that works with routing_algo assumes that the string passed is non
empty, this assumption is wrong:

sh-4.2# echo -ne '\0' > /sys/module/batman_adv/parameters/routing_algo
[   34.531340] BUG: unable to handle kernel paging request at ffff880015142fff
[   34.539191] IP: [<ffffffff8390ac7a>] batadv_param_set_ra+0x3a/0x90
[   34.541128] PGD 5027063 PUD 502b063 PMD 1bfc6067 PTE 15142160
[   34.541128] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   34.541128] CPU 0
[   34.541128] Pid: 6612, comm: sh Tainted: G        W    3.7.0-rc6-sasha-00024-g33da443-dirty #157
[   34.541128] RIP: 0010:[<ffffffff8390ac7a>]  [<ffffffff8390ac7a>] batadv_param_set_ra+0x3a/0x90
[   34.541128] RSP: 0018:ffff880014f81e48  EFLAGS: 00010292
[   34.541128] RAX: 000000000000003b RBX: ffff880015143000 RCX: 0000000000000006
[   34.550025] RDX: 0000000000000006 RSI: ffff8800151cb960 RDI: 0000000000000282
[   34.550025] RBP: ffff880014f81e68 R08: 0000000000000003 R09: 0000000000000000
[   34.550025] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880015142fff
[   34.550025] R13: ffffffff84e6b390 R14: ffff880014f86a00 R15: ffffffff83c35170
[   34.550025] FS:  00007f9ebc796700(0000) GS:ffff88001a600000(0000) knlGS:0000000000000000
[   34.550025] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   34.550025] CR2: ffff880015142fff CR3: 000000001522f000 CR4: 00000000000406f0
[   34.550025] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   34.550025] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   34.550025] Process sh (pid: 6612, threadinfo ffff880014f80000, task ffff8800151cb000)
[   34.550025] Stack:
[   34.550025]  ffff880014f81e68 ffff8800198ee020 0000000000000001 ffff880015143000
[   34.550025]  ffff880014f81e98 ffffffff81133776 ffff880014f81ea8 ffff880014f86a20
[   34.550025]  ffff880014f81f50 ffff880019d86d20 ffff880014f81ea8 ffffffff811335f8
[   34.550025] Call Trace:
[   34.550025]  [<ffffffff81133776>] param_attr_store+0x46/0x80
[   34.550025]  [<ffffffff811335f8>] module_attr_store+0x18/0x40
[   34.550025]  [<ffffffff812ed751>] sysfs_write_file+0x101/0x170
[   34.550025]  [<ffffffff8126fcb8>] vfs_write+0xb8/0x180
[   34.550025]  [<ffffffff8126fe70>] sys_write+0x50/0xa0
[   34.550025]  [<ffffffff83b30018>] tracesys+0xe1/0xe6
[   34.550025] Code: 4c 89 65 f0 4c 89 6d f8 49 89 f5 e8 71 c5 0b fe 48 c7 c7 38 2e df 84 4c 8d 60 ff 48 89 c6 31 c0 4c 89 e2 49 01 dc e8 a6 d8 15 00 <41> 80 3c 24 0a 75 05 41 c6 04 24 00 48 89 df e8 62 ff ff ff 48
[   34.550025] RIP  [<ffffffff8390ac7a>] batadv_param_set_ra+0x3a/0x90
[   34.550025]  RSP <ffff880014f81e48>
[   34.550025] CR2: ffff880015142fff
[   34.550025] ---[ end trace 6c53b662c574774b ]---

Signed-off-by: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index dc33a0c..3b8e368 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -426,7 +426,7 @@ static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 	char *algo_name = (char *)val;
 	size_t name_len = strlen(algo_name);
 
-	if (algo_name[name_len - 1] == '\n')
+	if (name_len > 0 && algo_name[name_len - 1] == '\n')
 		algo_name[name_len - 1] = '\0';
 
 	bat_algo_ops = batadv_algo_get(algo_name);
-- 
1.8.0
