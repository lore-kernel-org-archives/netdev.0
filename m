From: "Vitaly E. Lavrov" <lve@guap.ru>
Subject: [PATCH] veth: remove hardware checksum feature
Date: Thu, 25 Jul 2013 21:20:16 +0400
Message-ID: <51F15E50.8080208@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.guap.ru ([91.151.188.3]:11647 "EHLO ns1.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228Ab3GYRnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 13:43:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network device VETH can't support the feature NETIF_F_HW_CSUM.
All locally generated packets have invalid checksum.
Wrong commit http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8093315a91340bca52549044975d8c7f673b28a1 ( 
kernel 3.9.0 )

Workaround "ethtool -K vethX tx off"

Possible patch:

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 177f911..3db97da 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -254,7 +254,7 @@ static const struct net_device_ops veth_netdev_ops = {
  };

  #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
-                      NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
+                      NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
                        NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
                        NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
--
