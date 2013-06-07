From: roy.qing.li@gmail.com
Subject: [PATCH net] taging: csr: fix the skb mac header reset
Date: Fri,  7 Jun 2013 15:19:27 +0800
Message-ID: <1370589567-24043-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:63053 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab3FGHTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 03:19:37 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so1552852pdi.30
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 00:19:37 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id vz8sm1813516pac.20.2013.06.07.00.19.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 00:19:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

mac_header can be offset if NET_SKBUFF_DATA_USES_OFFSET is set, so
we should call skb_reset_mac_header to reset mac_header.

Or it will not work on net-next since "net: Use 16bits for *_headers
fields of struct skbuff" commit is introduced.

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
