From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] decnet: Move rtm_dn_policy to dn_route to make it
 available if !CONFIG_DECNET_ROUTER
Date: Fri, 22 Mar 2013 16:50:29 +0000
Message-ID: <20130322165029.GB19293@casper.infradead.org>
References: <5b888618a6aebfebf496c91482794a606b3bb094.1363885020.git.tgraf@suug.ch>
 <1363889099.2707.14.camel@menhir>
 <20130322142735.GA11368@casper.infradead.org>
 <20130322.103135.962113441677649820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60555 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161023Ab3CVQua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:50:30 -0400
Content-Disposition: inline
In-Reply-To: <20130322.103135.962113441677649820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise build fails with CONFIG_DECNET && !CONFIG_DECNET_ROUTER

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/decnet/dn_fib.c   | 14 --------------
 net/decnet/dn_route.c | 14 ++++++++++++++
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index f093059..57dc159 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -489,20 +489,6 @@ void dn_fib_select_multipath(const struct flowidn *fld, struct dn_fib_res *res)
 	spin_unlock_bh(&dn_fib_multipath_lock);
 }
 
-const struct nla_policy rtm_dn_policy[RTA_MAX + 1] = {
-	[RTA_DST]		= { .type = NLA_U16 },
-	[RTA_SRC]		= { .type = NLA_U16 },
-	[RTA_IIF]		= { .type = NLA_U32 },
-	[RTA_OIF]		= { .type = NLA_U32 },
-	[RTA_GATEWAY]		= { .type = NLA_U16 },
-	[RTA_PRIORITY]		= { .type = NLA_U32 },
-	[RTA_PREFSRC]		= { .type = NLA_U16 },
-	[RTA_METRICS]		= { .type = NLA_NESTED },
-	[RTA_MULTIPATH]		= { .type = NLA_NESTED },
-	[RTA_TABLE]		= { .type = NLA_U32 },
-	[RTA_MARK]		= { .type = NLA_U32 },
-};
-
 static inline u32 rtm_get_table(struct nlattr *attrs[], u8 table)
 {
 	if (attrs[RTA_TABLE])
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5904429..fe32388 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1613,6 +1613,20 @@ errout:
 	return -EMSGSIZE;
 }
 
+const struct nla_policy rtm_dn_policy[RTA_MAX + 1] = {
+	[RTA_DST]		= { .type = NLA_U16 },
+	[RTA_SRC]		= { .type = NLA_U16 },
+	[RTA_IIF]		= { .type = NLA_U32 },
+	[RTA_OIF]		= { .type = NLA_U32 },
+	[RTA_GATEWAY]		= { .type = NLA_U16 },
+	[RTA_PRIORITY]		= { .type = NLA_U32 },
+	[RTA_PREFSRC]		= { .type = NLA_U16 },
+	[RTA_METRICS]		= { .type = NLA_NESTED },
+	[RTA_MULTIPATH]		= { .type = NLA_NESTED },
+	[RTA_TABLE]		= { .type = NLA_U32 },
+	[RTA_MARK]		= { .type = NLA_U32 },
+};
+
 /*
  * This is called by both endnodes and routers now.
  */
