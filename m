From: kaber@trash.net
Subject: [PATCH 17/20] netfilter: ipset: fix return code for destroy when sets are in use
Date: Thu, 16 Jun 2011 21:47:17 +0200
Message-ID: <1308253640-29942-18-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262Ab1FPTr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:47:27 -0400
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 64e7b04..80a1262 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -776,7 +776,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < ip_set_max; i++) {
 			if (ip_set_list[i] != NULL && ip_set_list[i]->ref) {
-				ret = IPSET_ERR_BUSY;
+				ret = -IPSET_ERR_BUSY;
 				goto out;
 			}
 		}
-- 
1.7.2.3

