From: roy.qing.li@gmail.com
Subject: [PATCH RESEND] staging: csr: fix the reset of skb mac header
Date: Thu, 13 Jun 2013 20:12:14 +0800
Message-ID: <1371125534-17360-1-git-send-email-roy.qing.li@gmail.com>
Cc: gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36213 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3FMMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 08:12:27 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so5117859pdi.13
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 05:12:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

mac_header can be offset if NET_SKBUFF_DATA_USES_OFFSET is set, so
we should call skb_reset_mac_header to reset mac_header.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/staging/csr/monitor.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/csr/monitor.c b/drivers/staging/csr/monitor.c
index c8e20e4..e11f6cb 100644
--- a/drivers/staging/csr/monitor.c
+++ b/drivers/staging/csr/monitor.c
@@ -188,7 +188,7 @@ netrx_radiotap(unifi_priv_t *priv,
 
 
     skb->dev = dev;
-    skb->mac_header = skb->data;
+    skb_reset_mac_header(skb);
     skb->pkt_type = PACKET_OTHERHOST;
     skb->protocol = __constant_htons(ETH_P_80211_RAW);
     memset(skb->cb, 0, sizeof(skb->cb));
-- 
1.7.10.4
