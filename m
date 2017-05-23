From: gfree.wind@vip.163.com
Subject: [PATCH net-next] net: rfs: Don't reset RFS entries when nothing changed
Date: Tue, 23 May 2017 08:45:11 +0800
Message-ID: <1495500311-81095-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:49161 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965422AbdEWApn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 20:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

When the new RFS table size specified by sysctl equals the old one,
there is nothing changed actually. So it is unnecessary to reset the
RFS table entris.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 net/core/sysctl_net_core.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index ea23254..80b6a7e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -69,11 +69,12 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 				}
 				rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1;
 				sock_table->mask = size - 1;
+
+				for (i = 0; i < size; i++)
+					sock_table->ents[i] = RPS_NO_CPU;
 			} else
 				sock_table = orig_sock_table;
 
-			for (i = 0; i < size; i++)
-				sock_table->ents[i] = RPS_NO_CPU;
 		} else
 			sock_table = NULL;
 
-- 
1.9.1
