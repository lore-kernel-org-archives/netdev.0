From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Added missing netif_dormant_off() to generic HDLC
Date: Sun, 16 Jul 2006 14:17:20 +0200
Message-ID: <m33bd1n3qn.fsf@defiant.localdomain>
References: <m3veq3suve.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:18591 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751054AbWGPMRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 08:17:23 -0400
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
In-Reply-To: <m3veq3suve.fsf@defiant.localdomain> (Krzysztof Halasa's message of "Tue, 11 Jul 2006 23:18:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAN: Fixed a problem with PPP/raw HDLC/X.25 protocols not doing
netif_dormant_off() at startup.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index b81263e..fbaab5b 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -107,6 +107,7 @@ int hdlc_ppp_ioctl(struct net_device *de
 		dev->hard_header = NULL;
 		dev->type = ARPHRD_PPP;
 		dev->addr_len = 0;
+		netif_dormant_off(dev);
 		return 0;
 	}
 
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index 9456d31..f15aa6b 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -82,6 +82,7 @@ int hdlc_raw_ioctl(struct net_device *de
 		dev->type = ARPHRD_RAWHDLC;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 		dev->addr_len = 0;
+		netif_dormant_off(dev);
 		return 0;
 	}
 
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index b1285cc..d188498 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -100,6 +100,7 @@ int hdlc_raw_eth_ioctl(struct net_device
 		dev->tx_queue_len = old_qlen;
 		memcpy(dev->dev_addr, "\x00\x01", 2);
                 get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
+		netif_dormant_off(dev);
 		return 0;
 	}
 
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index 07e5eef..a867fb4 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -212,6 +212,7 @@ int hdlc_x25_ioctl(struct net_device *de
 		dev->hard_header = NULL;
 		dev->type = ARPHRD_X25;
 		dev->addr_len = 0;
+		netif_dormant_off(dev);
 		return 0;
 	}
 
