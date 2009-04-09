From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] fs_enet: convert to netdev_ops
Date: Thu, 9 Apr 2009 18:46:53 +0400
Message-ID: <20090409144652.GA4012@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-next@vger.kernel.org, Subrata Modak <subrata@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


Reported-by: Subrata Modak <subrata@linux.vnet.ibm.com>
Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---


 drivers/net/fs_enet/fs_enet-main.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index b037ce9..a9cbc31 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1019,6 +1019,22 @@ out_put_phy:
 #define IS_FEC(match) 0
 #endif
 
+static const struct net_device_ops fs_enet_netdev_ops = {
+	.ndo_open		= fs_enet_open,
+	.ndo_stop		= fs_enet_close,
+	.ndo_get_stats		= fs_enet_get_stats,
+	.ndo_start_xmit		= fs_enet_start_xmit,
+	.ndo_tx_timeout		= fs_timeout,
+	.ndo_set_multicast_list	= fs_set_multicast_list,
+	.ndo_do_ioctl		= fs_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= fs_enet_netpoll,
+#endif
+};
+
 static int __devinit fs_enet_probe(struct of_device *ofdev,
                                    const struct of_device_id *match)
 {
@@ -1093,22 +1109,13 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fep->tx_ring = fpi->tx_ring;
 	fep->rx_ring = fpi->rx_ring;
 
-	ndev->open = fs_enet_open;
-	ndev->hard_start_xmit = fs_enet_start_xmit;
-	ndev->tx_timeout = fs_timeout;
+	ndev->netdev_ops = &fs_enet_netdev_ops;
 	ndev->watchdog_timeo = 2 * HZ;
-	ndev->stop = fs_enet_close;
-	ndev->get_stats = fs_enet_get_stats;
-	ndev->set_multicast_list = fs_set_multicast_list;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = fs_enet_netpoll;
-#endif
 	if (fpi->use_napi)
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
 
 	ndev->ethtool_ops = &fs_ethtool_ops;
-	ndev->do_ioctl = fs_ioctl;
 
 	init_timer(&fep->phy_timer_list);
