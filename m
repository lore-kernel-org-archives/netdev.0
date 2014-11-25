From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 5/5] r8169: Use eth_skb_pad function
Date: Tue, 25 Nov 2014 14:44:25 -0800
Message-ID: <20141125224425.1867.70460.stgit@ahduyck-vm-fedora20>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbaKYWoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 17:44:32 -0500
In-Reply-To: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace rtl_skb_pad with eth_skb_pad since they do the same thing.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cf154f7..7ff4646 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6832,14 +6832,6 @@ err_out:
 	return -EIO;
 }
 
-static bool rtl_skb_pad(struct sk_buff *skb)
-{
-	if (skb_padto(skb, ETH_ZLEN))
-		return false;
-	skb_put(skb, ETH_ZLEN - skb->len);
-	return true;
-}
-
 static bool rtl_test_hw_pad_bug(struct rtl8169_private *tp, struct sk_buff *skb)
 {
 	return skb->len < ETH_ZLEN && tp->mac_version == RTL_GIGA_MAC_VER_34;
@@ -6980,7 +6972,7 @@ static bool rtl8169_tso_csum_v2(struct rtl8169_private *tp,
 		u8 ip_protocol;
 
 		if (unlikely(rtl_test_hw_pad_bug(tp, skb)))
-			return skb_checksum_help(skb) == 0 && rtl_skb_pad(skb);
+			return skb_checksum_help(skb) == 0 && eth_skb_pad(skb);
 
 		if (transport_offset > TCPHO_MAX) {
 			netif_warn(tp, tx_err, tp->dev,
@@ -7015,7 +7007,7 @@ static bool rtl8169_tso_csum_v2(struct rtl8169_private *tp,
 		opts[1] |= transport_offset << TCPHO_SHIFT;
 	} else {
 		if (unlikely(rtl_test_hw_pad_bug(tp, skb)))
-			return rtl_skb_pad(skb);
+			return eth_skb_pad(skb);
 	}
 
 	return true;
