From: kaber@trash.net
Subject: [PATCH 05/13] netfilter: xt_conntrack: warn about use in raw table
Date: Wed,  2 Mar 2011 13:12:45 +0100
Message-ID: <1299067973-15977-6-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

nfct happens to run after the raw table only.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_conntrack.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 4ef1b63..2c0086a 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -272,6 +272,11 @@ static int conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	int ret;
 
+	if (strcmp(par->table, "raw") == 0) {
+		pr_info("state is undetermined at the time of raw table\n");
+		return -EINVAL;
+	}
+
 	ret = nf_ct_l3proto_try_module_get(par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
-- 
1.7.4

