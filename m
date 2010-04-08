From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: KS8851: Possible NULL dereferenced in ks8851_rx_pkts
Date: Thu, 8 Apr 2010 02:03:57 -0500
Message-ID: <z2ocb8016981004080003h7f5ca358r7a1a4106809909ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47135 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758420Ab0DHHD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 03:03:58 -0400
Received: by gyg13 with SMTP id 13so1029316gyg.19
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 00:03:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These changes avoid a possible dereference in skb_reserve when skb is
NULL. I am increasing rx dropped packet count but not sure about how
to handle the dump of frames. Any advice is appreciated.

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index d6dc29b..a1aa757 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -534,8 +534,11 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)

 		if (rxlen > 0) {
 			skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
-			if (!skb) {
+			if (unlikely(!skb)) {
 				/* todo - dump frame and move on */
+				ks_dbg(ks, "No free memory, packet dropped\n");
+				ks->netdev->stats.rx_dropped++;
+				return;
 			}

 			/* two bytes to ensure ip is aligned, and four bytes

Best Regards
Abraham
