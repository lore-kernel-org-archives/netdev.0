From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/5] niu: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 14:44:12 -0800
Message-ID: <20141125224412.1867.96319.stgit@ahduyck-vm-fedora20>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbaKYWoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 17:44:14 -0500
In-Reply-To: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
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
