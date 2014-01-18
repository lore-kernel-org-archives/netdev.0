From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: move the netdev_add_tso_features() to
 bonding module
Date: Sat, 18 Jan 2014 12:48:01 +0100
Message-ID: <20140118114801.GA30549@redhat.com>
References: <52DA3BE5.5020500@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbaARLvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 06:51:07 -0500
Content-Disposition: inline
In-Reply-To: <52DA3BE5.5020500@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 04:31:33PM +0800, Ding Tianhong wrote:
>The function netdev_add_tso_features() was only be used for bonding,
>so no need to export it in netdevice.h, move it to bonding module.

Eric added it for a reason - like, other drivers might use it. Do you know
if team, bridge, vlan etc. might use it?

Thanks.

>
>Cc: Eric Dumazet <edumazet@google.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 12 +++++++++++-
> include/linux/netdevice.h       | 10 ----------
> 2 files changed, 11 insertions(+), 11 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e06c445..4cfe14e 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1045,6 +1045,16 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
>
> /*---------------------------------- IOCTL ----------------------------------*/
>
>+/* Allow TSO being used on stacked device:
>+ * Performing the GSO segmentation before last device
>+ * is a performance improvement.
>+ */
>+static netdev_features_t bond_add_tso_features(netdev_features_t features,
>+					       netdev_features_t mask)
>+{
>+	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
>+}
>+
> static netdev_features_t bond_fix_features(struct net_device *dev,
> 					   netdev_features_t features)
> {
>@@ -1068,7 +1078,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
> 						     slave->dev->features,
> 						     mask);
> 	}
>-	features = netdev_add_tso_features(features, mask);
>+	features = bond_add_tso_features(features, mask);
>
> 	return features;
> }
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index a2a70cc..1be74ea 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -3010,16 +3010,6 @@ static inline netdev_features_t netdev_get_wanted_features(
> netdev_features_t netdev_increment_features(netdev_features_t all,
> 	netdev_features_t one, netdev_features_t mask);
>
>-/* Allow TSO being used on stacked device :
>- * Performing the GSO segmentation before last device
>- * is a performance improvement.
>- */
>-static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
>-							netdev_features_t mask)
>-{
>-	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
>-}
>-
> int __netdev_update_features(struct net_device *dev);
> void netdev_update_features(struct net_device *dev);
> void netdev_change_features(struct net_device *dev);
>-- 
>1.8.0
>
>
