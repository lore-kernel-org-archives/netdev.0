From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 4/6] niu: Use eth_skb_pad helper
Date: Wed, 03 Dec 2014 08:17:52 -0800
Message-ID: <20141203161752.9223.4795.stgit@ahduyck-vm-fedora20>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700AbaLCQRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:17:55 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the standard layout for padding an ethernet frame with the
eth_skb_pad call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/sun/niu.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 904fd1a..4aaa324 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6651,13 +6651,8 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (skb->len < ETH_ZLEN) {
-		unsigned int pad_bytes = ETH_ZLEN - skb->len;
-
-		if (skb_pad(skb, pad_bytes))
-			goto out;
-		skb_put(skb, pad_bytes);
-	}
+	if (eth_skb_pad(skb))
+		goto out;
 
 	len = sizeof(struct tx_pkt_hdr) + 15;
 	if (skb_headroom(skb) < len) {
