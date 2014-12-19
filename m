From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ethernet: use IS_ERR_OR_NULL as much as possible
Date: Fri, 19 Dec 2014 13:20:57 +0800
Message-ID: <1418966457-23294-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47186 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaLSFVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 00:21:03 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so467443pde.15
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 21:21:02 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id w15sm3547578pbs.59.2014.12.18.21.21.00
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Dec 2014 21:21:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c  | 2 +-
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bb48a61..2e6e504 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7858,7 +7858,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 
 	segs = skb_gso_segment(skb, tp->dev->features &
 				    ~(NETIF_F_TSO | NETIF_F_TSO6));
-	if (IS_ERR(segs) || !segs)
+	if (IS_ERR_OR_NULL(segs))
 		goto tg3_tso_bug_end;
 
 	do {
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 14a1c5c..254dbe4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6876,7 +6876,7 @@ static void r8169_csum_workaround(struct rtl8169_private *tp,
 
 		features &= ~(NETIF_F_SG | NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 		segs = skb_gso_segment(skb, features);
-		if (IS_ERR(segs) || !segs)
+		if (IS_ERR_OR_NULL(segs))
 			goto drop;
 
 		do {
-- 
2.1.0
