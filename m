From: pablo@netfilter.org
Subject: [PATCH 1/7] netfilter: xt_hashlimit: use _ALL macro to reject unknown flag bits
Date: Thu, 17 May 2012 01:06:38 +0200
Message-ID: <1337209604-3412-2-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

David Miller says:
     The canonical way to validate if the set bits are in a valid
     range is to have a "_ALL" macro, and test:
     if (val & ~XT_HASHLIMIT_ALL)
         goto err;"

make it so.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_hashlimit.h |    6 ++++--
 net/netfilter/xt_hashlimit.c           |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index 05fe799..c42e52f 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -22,10 +22,12 @@ enum {
 	XT_HASHLIMIT_HASH_SPT = 1 << 3,
 	XT_HASHLIMIT_INVERT   = 1 << 4,
 	XT_HASHLIMIT_BYTES    = 1 << 5,
+};
 #ifdef __KERNEL__
-	XT_HASHLIMIT_MAX      = 1 << 6,
+#define XT_HASHLIMIT_ALL (XT_HASHLIMIT_HASH_DIP | XT_HASHLIMIT_HASH_DPT | \
+			  XT_HASHLIMIT_HASH_SIP | XT_HASHLIMIT_HASH_SPT | \
+			  XT_HASHLIMIT_INVERT | XT_HASHLIMIT_BYTES)
 #endif
-};
 
 struct hashlimit_cfg {
 	__u32 mode;	  /* bitmask of XT_HASHLIMIT_HASH_* */
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 5d5af1d..26a668a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -647,7 +647,7 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 			return -EINVAL;
 	}
 
-	if (info->cfg.mode >= XT_HASHLIMIT_MAX) {
+	if (info->cfg.mode & ~XT_HASHLIMIT_ALL) {
 		pr_info("Unknown mode mask %X, kernel too old?\n",
 						info->cfg.mode);
 		return -EINVAL;
-- 
1.7.10

