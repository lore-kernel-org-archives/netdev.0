From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 1/9] net: Disable segmentation if checksumming
 is not supported
Date: Fri, 29 Apr 2016 15:43:08 -0700
Message-ID: <20160429224308.12418.51424.stgit@ahduyck-xeon-server>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35253 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbcD2WnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:11 -0400
Received: by mail-pa0-f49.google.com with SMTP id iv1so50858225pac.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:10 -0700 (PDT)
In-Reply-To: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
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
index d91dfbec0fc6..673d1f118bfb 100644
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
