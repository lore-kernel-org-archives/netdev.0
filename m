From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 6/16 2.5] ixgb: fix error in setting Frame Size register
 while changing mtu
Date: Fri, 15 Oct 2004 06:55:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150629310.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -1437,8 +1437,8 @@ static struct net_device_stats *ixgb_get
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	uint32_t old_mtu = adapter->rx_buffer_len;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
 	if ((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
 	    || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
@@ -1463,7 +1477,7 @@ static int ixgb_change_mtu(struct net_de
 
 	netdev->mtu = new_mtu;
 
-	if (old_mtu != adapter->rx_buffer_len && netif_running(netdev)) {
+	if(old_max_frame != max_frame && netif_running(netdev)) {
 
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
