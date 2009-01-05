From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 3/3] infiniband: ipoib convert to
	net_device_ops
Date: Mon, 5 Jan 2009 13:23:48 -0800
Message-ID: <20090105132348.7cac98cb@extreme>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.828840735@vyatta.com> <adawsd9mppk.fsf@cisco.com>
	<20090105132211.70baefb9@extreme> <20090105132254.052633d7@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hal@lists.openfabrics.org, netdev@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090105132254.052633d7@extreme>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-01-05 13:14:20.970318942 -0800
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-01-05 13:19:46.657819176 -0800
@@ -1013,18 +1013,22 @@ static void ipoib_lro_setup(struct ipoib
 	priv->lro.lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 }
 
+static const struct net_device_ops ipoib_netdev_ops = {
+	.ndo_open		 = ipoib_open,
+	.ndo_stop		 = ipoib_stop,
+	.ndo_change_mtu		 = ipoib_change_mtu,
+	.ndo_start_xmit		 = ipoib_start_xmit,
+	.ndo_tx_timeout	 	 = ipoib_timeout,
+	.ndo_set_multicast_list	 = ipoib_set_mcast_list,
+	.ndo_neigh_setup	 = ipoib_neigh_setup_dev,
+};
+
 static void ipoib_setup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	dev->open		 = ipoib_open;
-	dev->stop		 = ipoib_stop;
-	dev->change_mtu		 = ipoib_change_mtu;
-	dev->hard_start_xmit	 = ipoib_start_xmit;
-	dev->tx_timeout		 = ipoib_timeout;
-	dev->header_ops		 = &ipoib_header_ops;
-	dev->set_multicast_list	 = ipoib_set_mcast_list;
-	dev->neigh_setup	 = ipoib_neigh_setup_dev;
+	dev->netdev_ops		= &ipoib_netdev_ops;
+	dev->header_ops		= &ipoib_header_ops;
 
 	ipoib_set_ethtool_ops(dev);
 
