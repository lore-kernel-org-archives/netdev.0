From: Johanna Abrahamsson <johanna@mjao.org>
Subject: [PATCH] net: Reduce size of rps_sock_flow_sysctl
Date: Thu, 1 Sep 2016 22:37:01 +0200
Message-ID: <20160901203658.GA4828@fedora-21-dvm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        =?iso-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35874 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754036AbcIAUzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 16:55:13 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so206743wmf.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 13:55:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce size of rps_sock_flow_sysctl to improve readability.

Signed-off-by: Johanna Abrahamsson <johanna@mjao.org>
---
 net/core/sysctl_net_core.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0df2aa6..d0be2ce 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -53,29 +53,29 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);
 
 	if (write) {
-		if (size) {
-			if (size > 1<<29) {
-				/* Enforce limit to prevent overflow */
-				mutex_unlock(&sock_flow_mutex);
-				return -EINVAL;
+		if (!size)
+			goto exit_unlock;
+		if (size > 1 << 29) {
+			/* Enforce limit to prevent overflow */
+			ret = -EINVAL;
+			goto exit_unlock;
+		}
+
+		size = roundup_pow_of_two(size);
+		if (size != orig_size) {
+			sock_table = vmalloc(RPS_SOCK_FLOW_TABLE_SIZE(size));
+			if (!sock_table) {
+				ret = -ENOMEM;
+				goto exit_unlock;
 			}
-			size = roundup_pow_of_two(size);
-			if (size != orig_size) {
-				sock_table =
-				    vmalloc(RPS_SOCK_FLOW_TABLE_SIZE(size));
-				if (!sock_table) {
-					mutex_unlock(&sock_flow_mutex);
-					return -ENOMEM;
-				}
-				rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1;
-				sock_table->mask = size - 1;
-			} else
-				sock_table = orig_sock_table;
+			rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1;
+			sock_table->mask = size - 1;
+		} else {
+			sock_table = orig_sock_table;
+		}
 
-			for (i = 0; i < size; i++)
-				sock_table->ents[i] = RPS_NO_CPU;
-		} else
-			sock_table = NULL;
+		for (i = 0; i < size; i++)
+			sock_table->ents[i] = RPS_NO_CPU;
 
 		if (sock_table != orig_sock_table) {
 			rcu_assign_pointer(rps_sock_flow_table, sock_table);
@@ -89,8 +89,8 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 		}
 	}
 
+exit_unlock:
 	mutex_unlock(&sock_flow_mutex);
-
 	return ret;
 }
 #endif /* CONFIG_RPS */
-- 
2.1.4
