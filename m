From: kaber@trash.net
Subject: [PATCH 02/12] netfilter: xtables: fix incorrect return code
Date: Thu, 13 May 2010 18:16:15 +0200
Message-ID: <1273767385-18225-3-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759258Ab0EMQQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:16:30 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_multiport.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index 83b77ce..b21f904 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -117,7 +117,7 @@ static int multiport_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_multiport_v1 *multiinfo = par->matchinfo;
 
 	return check(ip->proto, ip->invflags, multiinfo->flags,
-		     multiinfo->count);
+		     multiinfo->count) ? 0 : -EINVAL;
 }
 
 static int multiport_mt6_check(const struct xt_mtchk_param *par)
@@ -126,7 +126,7 @@ static int multiport_mt6_check(const struct xt_mtchk_param *par)
 	const struct xt_multiport_v1 *multiinfo = par->matchinfo;
 
 	return check(ip->proto, ip->invflags, multiinfo->flags,
-		     multiinfo->count);
+		     multiinfo->count) ? 0 : -EINVAL;
 }
 
 static struct xt_match multiport_mt_reg[] __read_mostly = {
-- 
1.7.0.4

