From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 5/5] netfilter: xt_TEE: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:39 +0530
Message-ID: <1490085879-1827-6-git-send-email-singhalsimran0@gmail.com>
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

 net/netfilter/xt_TEE.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 86b0580..5df3282 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -95,7 +95,7 @@ static int tee_tg_check(const struct xt_tgchk_param *par)
 			return -EINVAL;
 
 		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-		if (priv == NULL)
+		if (!priv)
 			return -ENOMEM;
 
 		priv->tginfo  = info;
-- 
2.7.4
