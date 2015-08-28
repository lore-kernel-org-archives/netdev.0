From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: xt_TEE: use IS_ENABLED(CONFIG_NF_DUP_IPV6)
Date: Sat, 29 Aug 2015 00:50:14 +0200
Message-ID: <1440802217-13080-7-git-send-email-pablo@netfilter.org>
References: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of IS_ENABLED(CONFIG_IPV6), otherwise we hit:

et/built-in.o: In function `tee_tg6':
>> xt_TEE.c:(.text+0x6cd8c): undefined reference to `nf_dup_ipv6'

when:

 CONFIG_IPV6=y
 CONFIG_NF_DUP_IPV4=y
 # CONFIG_NF_DUP_IPV6 is not set
 CONFIG_NETFILTER_XT_TARGET_TEE=y

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TEE.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 49fee6a..fd980aa 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -37,7 +37,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_NF_DUP_IPV6)
 static unsigned int
 tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -129,7 +129,7 @@ static struct xt_target tee_tg_reg[] __read_mostly = {
 		.destroy    = tee_tg_destroy,
 		.me         = THIS_MODULE,
 	},
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_NF_DUP_IPV6)
 	{
 		.name       = "TEE",
 		.revision   = 1,
-- 
1.7.10.4

