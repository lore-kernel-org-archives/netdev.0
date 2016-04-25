From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/8] net: Disable segmentation if checksumming is
 not supported
Date: Mon, 25 Apr 2016 11:31:01 -0700
Message-ID: <20160425183101.11331.82561.stgit@ahduyck-xeon-server>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36374 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbcDYSbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:31:03 -0400
Received: by mail-pa0-f54.google.com with SMTP id bt5so14103394pac.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:31:03 -0700 (PDT)
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
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
index 6324bc9267f7..d6d9f286c4e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2815,7 +2815,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, type)) {
-		features &= ~NETIF_F_CSUM_MASK;
+		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
