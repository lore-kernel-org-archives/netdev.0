From: pablo@netfilter.org
Subject: [PATCH 2/3] netfilter: xt_AUDIT: only generate audit log when audit enabled
Date: Thu,  7 Mar 2013 12:00:01 +0100
Message-ID: <1362654002-4405-3-git-send-email-pablo@netfilter.org>
References: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

We should stop generting audit log if audit is disabled.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_AUDIT.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index ba92824..3228d7f 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -124,6 +124,9 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_audit_info *info = par->targinfo;
 	struct audit_buffer *ab;
 
+	if (audit_enabled == 0)
+		goto errout;
+
 	ab = audit_log_start(NULL, GFP_ATOMIC, AUDIT_NETFILTER_PKT);
 	if (ab == NULL)
 		goto errout;
-- 
1.7.10.4

