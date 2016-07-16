From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 1/1]NET:AX25:NETROM Corrects the returned added header
 length.
Date: Sat, 16 Jul 2016 10:50:06 +0100
Message-ID: <201607160950.u6G9o6qr015904@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mdfmta005.mxout.tch.inty.net ([91.221.169.46]:38014 "EHLO
	smtp.demon.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751374AbcGPJ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 05:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 1/1]NET:AX25:NETROM Corrects the returned added header length.
Corrects the returned added header length.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/netrom/nr_dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 988f542..07b9fe4 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -93,9 +93,9 @@ static int nr_header(struct sk_buff *skb, struct net_device *dev,
 	*buff++ = NR_PROTOEXT;
 
 	if (daddr != NULL)
-		return 37;
+		return NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 
-	return -37;
+	return -(NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 }
 
 static int __must_check nr_set_mac_address(struct net_device *dev, void *addr)
