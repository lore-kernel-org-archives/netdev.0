From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: convert to net_device_ops
Date: Fri,  9 Jan 2009 18:43:49 -0800
Message-ID: <1231555429-32020-1-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@linux-foundation.org>,
	wimax@linuxwimax.org
To: David Miller <davem@davemloft.net>
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/wimax/i2400m/netdev.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 63fe708..57159e4 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -493,6 +493,14 @@ error_skb_realloc:
 		i2400m, buf, buf_len);
 }
 
+static const struct net_device_ops i2400m_netdev_ops = {
+	.ndo_open = i2400m_open,
+	.ndo_stop = i2400m_stop,
+	.ndo_start_xmit = i2400m_hard_start_xmit,
+	.ndo_tx_timeout = i2400m_tx_timeout,
+	.ndo_change_mtu = i2400m_change_mtu,
+};
+
 
 /**
  * i2400m_netdev_setup - Setup setup @net_dev's i2400m private data
@@ -513,11 +521,7 @@ void i2400m_netdev_setup(struct net_device *net_dev)
 		& (~IFF_BROADCAST	/* i2400m is P2P */
 		   & ~IFF_MULTICAST);
 	net_dev->watchdog_timeo = I2400M_TX_TIMEOUT;
-	net_dev->open = i2400m_open;
-	net_dev->stop = i2400m_stop;
-	net_dev->hard_start_xmit = i2400m_hard_start_xmit;
-	net_dev->change_mtu = i2400m_change_mtu;
-	net_dev->tx_timeout = i2400m_tx_timeout;
+	net_dev->netdev_ops = &i2400m_netdev_ops;
 	d_fnend(3, NULL, "(net_dev %p) = void\n", net_dev);
 }
 EXPORT_SYMBOL_GPL(i2400m_netdev_setup);
-- 
1.5.6.5
