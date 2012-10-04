From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v3 08/11] crypto: pass crypto_user module to netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:26 +0800
Message-ID: <1349325689-16104-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.done to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 crypto/crypto_user.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 6bba414..f08297b 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -430,13 +430,15 @@ static struct crypto_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
+	struct module *module;
 } crypto_dispatch[CRYPTO_NR_MSGTYPES] = {
 	[CRYPTO_MSG_NEWALG	- CRYPTO_MSG_BASE] = { .doit = crypto_add_alg},
 	[CRYPTO_MSG_DELALG	- CRYPTO_MSG_BASE] = { .doit = crypto_del_alg},
 	[CRYPTO_MSG_UPDATEALG	- CRYPTO_MSG_BASE] = { .doit = crypto_update_alg},
 	[CRYPTO_MSG_GETALG	- CRYPTO_MSG_BASE] = { .doit = crypto_report,
 						       .dump = crypto_dump_report,
-						       .done = crypto_dump_report_done},
+						       .done = crypto_dump_report_done,
+						       .module = THIS_MODULE},
 };
 
 static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -471,6 +473,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				.dump = link->dump,
 				.done = link->done,
 				.min_dump_alloc = dump_alloc,
+				.module = link->module,
 			};
 			return netlink_dump_start(crypto_nlsk, skb, nlh, &c);
 		}
-- 
1.7.7.6
