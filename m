From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 05/77] infiniband: convert ipoib to
	net_device_ops
Date: Fri, 20 Mar 2009 22:35:32 -0700
Message-ID: <20090321053712.940955485@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>, rolandd@cisco.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline; filename=ipoib.patch
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

---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-03-19 22:40:30.490964092 -0700
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-03-19 22:42:44.247652266 -0700
@@ -1016,18 +1016,22 @@ static void ipoib_lro_setup(struct ipoib
 	priv->lro.lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 }
 
+static const struct net_device_ops ipoib_netdev_ops = {
+	.ndo_open		 = ipoib_open,
+	.ndo_stop		 = ipoib_stop,
+	.ndo_change_mtu		 = ipoib_change_mtu,
+	.ndo_start_xmit	 	 = ipoib_start_xmit,
+	.ndo_tx_timeout		 = ipoib_timeout,
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
+	dev->netdev_ops		 = &ipoib_netdev_ops;
 	dev->header_ops		 = &ipoib_header_ops;
-	dev->set_multicast_list	 = ipoib_set_mcast_list;
-	dev->neigh_setup	 = ipoib_neigh_setup_dev;
 
 	ipoib_set_ethtool_ops(dev);
 

-- 
