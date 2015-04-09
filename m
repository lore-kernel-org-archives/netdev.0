From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 4/5 v2] netfilter: Fix format string of nfnetlink_queue proc file
Date: Thu,  9 Apr 2015 23:57:16 +0200
Message-ID: <1428616637-21690-4-git-send-email-richard@nod.at>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428616637-21690-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The printed values are all of type unsigned integer, therefore use
%u instead of %d. Otherwise an user can face negative values.

Fixes:
$ cat /proc/net/netfilter/nfnetlink_queue
    0  29508   278 2 65531     0 2004213241 -2129885586  1
    1 -27747     0 2 65531     0     0        0  1
    2 -27748     0 2 65531     0     0        0  1

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/netfilter/nfnetlink_queue_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0aba0b9..017e3cd 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1241,7 +1241,7 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfqnl_instance *inst = v;
 
-	seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
+	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n",
 		   inst->queue_num,
 		   inst->peer_portid, inst->queue_total,
 		   inst->copy_mode, inst->copy_range,
-- 
1.8.4.5
