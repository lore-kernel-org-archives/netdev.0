From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] ethernet: print protocol in host byte order
Date: Wed, 21 Apr 2010 09:06:07 +0200
Message-ID: <1271833567.3627.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50727 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab0DUHGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 03:06:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric's recent patch added __force, but this
place would seem to require actually doing
a byte order conversion so the printk is
consistent across architectures.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/ethernet/eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 3584696..0c0d272 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -136,7 +136,7 @@ int eth_rebuild_header(struct sk_buff *skb)
 	default:
 		printk(KERN_DEBUG
 		       "%s: unable to resolve type %X addresses.\n",
-		       dev->name, (__force int)eth->h_proto);
+		       dev->name, ntohs(eth->h_proto));
 
 		memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
 		break;


