From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/18] netfilter: nfnetlink_acct: validate NFACCT_FILTER parameters
Date: Tue, 15 Mar 2016 02:27:46 +0100
Message-ID: <1458005282-24665-3-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Turnbull <phil.turnbull@oracle.com>

nfacct_filter_alloc doesn't validate the NFACCT_FILTER_MASK and
NFACCT_FILTER_VALUE parameters which can trigger a NULL pointer
dereference. CAP_NET_ADMIN is required to trigger the bug.

Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 5274b04..4c2b4c0 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -242,6 +242,9 @@ nfacct_filter_alloc(const struct nlattr * const attr)
 	if (err < 0)
 		return ERR_PTR(err);
 
+	if (!tb[NFACCT_FILTER_MASK] || !tb[NFACCT_FILTER_VALUE])
+		return ERR_PTR(-EINVAL);
+
 	filter = kzalloc(sizeof(struct nfacct_filter), GFP_KERNEL);
 	if (!filter)
 		return ERR_PTR(-ENOMEM);
-- 
2.1.4

