From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 4/4] netfilter: Fix format string of nfnetlink_queue proc file
Date: Fri, 13 Mar 2015 12:31:16 +0100
Message-ID: <1426246276-15839-5-git-send-email-richard@nod.at>
References: <1426246276-15839-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:14388 "EHLO
	mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbbCMLhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 07:37:14 -0400
In-Reply-To: <1426246276-15839-1-git-send-email-richard@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 1b7f7b8..2121ab5 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1243,7 +1243,7 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfqnl_instance *inst = v;
 
-	seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
+	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n",
 		   inst->queue_num,
 		   inst->peer_portid, inst->queue_total,
 		   inst->copy_mode, inst->copy_range,
-- 
1.8.4.5
