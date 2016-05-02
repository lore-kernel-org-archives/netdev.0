From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 1/2] net: Disable segmentation if checksumming is not
 supported
Date: Mon, 02 May 2016 09:25:10 -0700
Message-ID: <20160502162510.11701.82922.stgit@ahduyck-xeon-server>
References: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, ogerlitz@mellanox.com, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35352 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbcEBQZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:25:12 -0400
Received: by mail-pf0-f170.google.com with SMTP id 77so48063957pfv.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:25:12 -0700 (PDT)
In-Reply-To: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of the mlx4 and mlx5 driver they do not support IPv6 checksum
offload for tunnels.  With this being the case we should disable GSO in
addition to the checksum offload features when we find that a device cannot
perform a checksum on a given packet type.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 77a71cd68535..5c925ac50b95 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2802,7 +2802,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, type)) {
-		features &= ~NETIF_F_CSUM_MASK;
+		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
