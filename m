From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/6) bridge: make dev->features unsigned
Date: Thu, 26 May 2005 11:04:14 -0700
Message-ID: <20050526110414.75f59a1f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============025217167001802654=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============025217167001802654==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

The features field in netdevice is really a bitmask, and bitmask's should
be unsigned.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: bridge/net/core/ethtool.c
===================================================================
--- bridge.orig/net/core/ethtool.c
+++ bridge/net/core/ethtool.c
@@ -682,7 +682,7 @@ int dev_ethtool(struct ifreq *ifr)
 	void __user *useraddr = ifr->ifr_data;
 	u32 ethcmd;
 	int rc;
-	int old_features;
+	unsigned long old_features;
 
 	/*
 	 * XXX: This can be pushed down into the ethtool_* handlers that
Index: bridge/include/linux/netdevice.h
===================================================================
--- bridge.orig/include/linux/netdevice.h
+++ bridge/include/linux/netdevice.h
@@ -401,7 +401,7 @@ struct net_device
 	} reg_state;
 
 	/* Net device features */
-	int			features;
+	unsigned long		features;
 #define NETIF_F_SG		1	/* Scatter/gather IO. */
 #define NETIF_F_IP_CSUM		2	/* Can checksum only TCP/UDP over IPv4. */
 #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */

--===============025217167001802654==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============025217167001802654==--
