From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
 handle packets
Date: Mon, 18 Feb 2013 21:50:52 +0200
Message-ID: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1872 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab3BRT5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 14:57:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device is not able to handle checksumming it will
be handled in dev_xmit

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
Changes from v1: fixed email address

 net/ipv4/ip_gre.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a56f118..cdc31ac 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -745,12 +745,9 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
 			goto error;
 		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
 		return skb;
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		err = skb_checksum_help(skb);
-		if (unlikely(err))
-			goto error;
 	}
-	skb->ip_summed = CHECKSUM_NONE;
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
 
 	return skb;
 
-- 
1.7.7.2
