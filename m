From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 4/5] netfilter: nfnetlink: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:38 +0530
Message-ID: <1490085879-1827-5-git-send-email-singhalsimran0@gmail.com>
References: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some functions like kmalloc/kzalloc return NULL on failure. When NULL
represents failure, !x is commonly used.

This was done using Coccinelle:
@@
expression *e;
identifier l1;
@@
e = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\)(...);
...
- e == NULL
+ !e

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14.

 net/netfilter/nfnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 68eda920..c39f16c 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -232,7 +232,7 @@ static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err)
 	struct nfnl_err *nfnl_err;
 
 	nfnl_err = kmalloc(sizeof(struct nfnl_err), GFP_KERNEL);
-	if (nfnl_err == NULL)
+	if (!nfnl_err)
 		return -ENOMEM;
 
 	nfnl_err->nlh = nlh;
-- 
2.7.4
