From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/08: xt_recent: fix false match
Date: Wed, 24 Feb 2010 18:49:31 +0100 (MET)
Message-ID: <20100224174931.16391.20176.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48774 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757405Ab0BXRtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 12:49:32 -0500
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8ccb92ad41cb311e52ad1b1fe77992c7f47a3b63
Author: Tim Gardner <tim.gardner@canonical.com>
Date:   Tue Feb 23 14:59:12 2010 +0100

    netfilter: xt_recent: fix false match
    
    A rule with a zero hit_count will always match.
    
    Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1278f0a..7073dbb 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -267,7 +267,7 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		for (i = 0; i < e->nstamps; i++) {
 			if (info->seconds && time_after(time, e->stamps[i]))
 				continue;
-			if (++hits >= info->hit_count) {
+			if (info->hit_count && ++hits >= info->hit_count) {
 				ret = !ret;
 				break;
 			}
