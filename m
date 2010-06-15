From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: udp: Add UFO to NETIF_F_SOFTWARE_GSO
Date: Tue, 15 Jun 2010 16:21:04 +1000
Message-ID: <20100615062104.GA4779@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33769 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750964Ab0FOGVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:21:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

udp: Add UFO to NETIF_F_SOFTWARE_GSO

This patch adds UFO to the list of GSO features with a software
fallback.  This allows UFO to be used even if the hardware does
not support it.

In particular, this allows us to test the UFO fallback, as it
has been reported to not work in some cases.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40291f3..ea48a43 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -847,7 +847,8 @@ struct net_device {
 #define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
 
 	/* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				 NETIF_F_TSO6 | NETIF_F_UFO)
 
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
