From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] netfilter: {ipt,ebt}_ULOG: rise warning on deprecation
Date: Wed,  5 Jun 2013 22:40:26 +0200
Message-ID: <1370464832-4216-6-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This target has been superseded by NFLOG. Spot a warning
so we prepare removal in a couple of years.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netns/x_tables.h    |    6 ++++++
 net/bridge/netfilter/ebt_ulog.c |    6 ++++++
 net/ipv4/netfilter/Kconfig      |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c   |    6 ++++++
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index c24060e..02fe40f 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -15,5 +15,11 @@ struct netns_xt {
 	struct ebt_table *frame_filter;
 	struct ebt_table *frame_nat;
 #endif
+#if IS_ENABLED(CONFIG_IP_NF_TARGET_ULOG)
+	bool ulog_warn_deprecated;
+#endif
+#if IS_ENABLED(CONFIG_BRIDGE_EBT_ULOG)
+	bool ebt_ulog_warn_deprecated;
+#endif
 };
 #endif
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index fc1905c..2ec6c19 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -267,6 +267,12 @@ static int ebt_ulog_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ebt_ulog_info *uloginfo = par->targinfo;
 
+	if (!par->net->xt.ebt_ulog_warn_deprecated) {
+		pr_info("ebt_ulog is deprecated and it will be removed soon, "
+			"use ebt_nflog instead\n");
+		par->net->xt.ebt_ulog_warn_deprecated = true;
+	}
+
 	if (uloginfo->nlgroup > 31)
 		return -EINVAL;
 
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index e7916c1..4e90280 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -111,7 +111,7 @@ config IP_NF_TARGET_REJECT
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 config IP_NF_TARGET_ULOG
-	tristate "ULOG target support"
+	tristate "ULOG target support (obsolete)"
 	default m if NETFILTER_ADVANCED=n
 	---help---
 
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index f8a222cb..c1953d0 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -325,6 +325,12 @@ static int ulog_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ulog_info *loginfo = par->targinfo;
 
+	if (!par->net->xt.ulog_warn_deprecated) {
+		pr_info("ULOG is deprecated and it will be removed soon, "
+			"use NFLOG instead\n");
+		par->net->xt.ulog_warn_deprecated = true;
+	}
+
 	if (loginfo->prefix[sizeof(loginfo->prefix) - 1] != '\0') {
 		pr_debug("prefix not null-terminated\n");
 		return -EINVAL;
-- 
1.7.10.4

