From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: dsa: Do not check for NULL dst in tag parsers
Date: Fri,  7 Apr 2017 13:41:52 -0700
Message-ID: <20170407204154.9651-2-f.fainelli@gmail.com>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33975 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdDGUmE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:42:04 -0400
Received: by mail-qt0-f196.google.com with SMTP id x35so11235445qtc.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 13:42:04 -0700 (PDT)
In-Reply-To: <20170407204154.9651-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_switch_rcv() already tests for dst == NULL, so there is no need to duplicate
the same check within the tag receive functions.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_brcm.c    | 3 ---
 net/dsa/tag_dsa.c     | 3 ---
 net/dsa/tag_edsa.c    | 3 ---
 net/dsa/tag_qca.c     | 3 ---
 net/dsa/tag_trailer.c | 2 --
 5 files changed, 14 deletions(-)

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index e2ed6cf68261..68d4feef96d4 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -100,9 +100,6 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_port;
 	u8 *brcm_tag;
 
-	if (unlikely(dst == NULL))
-		goto out_drop;
-
 	ds = dst->cpu_switch;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index e42ba906100c..377569c0e4f7 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -77,9 +77,6 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_device;
 	int source_port;
 
-	if (unlikely(dst == NULL))
-		goto out_drop;
-
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		goto out;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 6a9b7a9e4e15..30520ff9c9a2 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -90,9 +90,6 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_device;
 	int source_port;
 
-	if (unlikely(dst == NULL))
-		goto out_drop;
-
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		goto out;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 4e0dad759d04..6579d6db1bc6 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -75,9 +75,6 @@ static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	int port;
 	__be16 *phdr, hdr;
 
-	if (unlikely(!dst))
-		goto out_drop;
-
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (!skb)
 		goto out;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 74c948512550..f5c764ee2968 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -66,8 +66,6 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 	u8 *trailer;
 	int source_port;
 
-	if (unlikely(dst == NULL))
-		goto out_drop;
 	ds = dst->cpu_switch;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
-- 
2.9.3
