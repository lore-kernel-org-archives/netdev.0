From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ethtool_op_get_rx_csum() should be public
 and exported
Date: Mon, 27 Jul 2009 11:18:11 +0200
Message-ID: <4A6D70D3.8030408@gmail.com>
References: <1248305902.1061.84.camel@w-sridhar.beaverton.ibm.com> <20090726.194957.162341485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33052 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbZG0JSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 05:18:16 -0400
In-Reply-To: <20090726.194957.162341485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Wed, 22 Jul 2009 16:38:22 -0700
>=20
>> [PATCH net-next-2.6] ethtool: add device independent rx_csum and get=
_flags routines
>>
>> This helps avoid error messages with ethtool -k on devices that
>> don't provide device specific routines.
>>
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>=20
> Applied.

I wonder if ethtool_op_get_rx_csum() should be static or is meant to be=
 used by drivers ?

I guess it should be public and exported like ethtool_op_get_tx_csum()

[PATCH] net: ethtool_op_get_rx_csum() should be public and exported

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/ethtool.h |    1 +
 net/core/ethtool.c      |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9b660bd..90c4a36 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -368,6 +368,7 @@ struct net_device;
=20
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
+u32 ethtool_op_get_rx_csum(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index cf36ff4..44e5711 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -34,11 +34,13 @@ u32 ethtool_op_get_rx_csum(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_rx_csum);
=20
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
 }
+EXPORT_SYMBOL(ethtool_op_get_tx_csum);
=20
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
@@ -1125,7 +1127,6 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_sg);
 EXPORT_SYMBOL(ethtool_op_get_tso);
-EXPORT_SYMBOL(ethtool_op_get_tx_csum);
 EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
