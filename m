From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 2/10] ixgb: Fix error in setting Frame Size register
 while changing mtu
Date: Fri, 29 Oct 2004 05:08:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290446130.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-15 13:15:55.000000000 -0700
@@ -1436,8 +1436,8 @@ static struct net_device_stats *ixgb_get
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	uint32_t old_mtu = adapter->rx_buffer_len;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
 	if ((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
 	    || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
@@ -1462,7 +1477,7 @@ static int ixgb_change_mtu(struct net_de
 
 	netdev->mtu = new_mtu;
 
-	if (old_mtu != adapter->rx_buffer_len && netif_running(netdev)) {
+	if(old_max_frame != max_frame && netif_running(netdev)) {
 
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
