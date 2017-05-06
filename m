From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Sat,  6 May 2017 10:07:31 -0600
Message-ID: <20170506160734.47084-4-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32825 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752298AbdEFQHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:47 -0400
Received: by mail-pf0-f196.google.com with SMTP id b23so4395433pfc.0
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:47 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new flag to denote lightweight netdevices. Add helper to identify
such devices.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f47c8712398a..08151fd34973 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1401,6 +1401,7 @@ enum netdev_priv_flags {
 	IFF_RXFH_CONFIGURED		= 1<<25,
 	IFF_PHONY_HEADROOM		= 1<<26,
 	IFF_MACSEC			= 1<<27,
+	IFF_LWT_NETDEV			= 1<<28,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1430,6 +1431,7 @@ enum netdev_priv_flags {
 #define IFF_TEAM			IFF_TEAM
 #define IFF_RXFH_CONFIGURED		IFF_RXFH_CONFIGURED
 #define IFF_MACSEC			IFF_MACSEC
+#define IFF_LWT_NETDEV			IFF_LWT_NETDEV
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -4137,6 +4139,11 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
 	skb->mac_len = mac_len;
 }
 
+static inline bool netif_is_lwd(struct net_device *dev)
+{
+	return !!(dev->priv_flags & IFF_LWT_NETDEV);
+}
+
 static inline bool netif_is_macsec(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACSEC;
-- 
2.11.0 (Apple Git-81)
