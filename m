From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/8] vxge: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:35 -0700
Message-ID: <20110404210805.288930078@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43884 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755747Ab1DDWSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:17 -0400
Content-Disposition: inline; filename=vxge-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix up incorrect docbook comment

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxge/vxge-ethtool.c	2011-04-04 11:56:50.004060423 -0700
+++ b/drivers/net/vxge/vxge-ethtool.c	2011-04-04 11:58:47.045259090 -0700
@@ -134,22 +134,29 @@ static void vxge_ethtool_gregs(struct ne
 /**
  * vxge_ethtool_idnic - To physically identify the nic on the system.
  * @dev : device pointer.
- * @id : pointer to the structure with identification parameters given by
- * ethtool.
+ * @state : requested LED state
  *
  * Used to physically identify the NIC on the system.
- * The Link LED will blink for a time specified by the user.
- * Return value:
  * 0 on success
  */
-static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
+static int vxge_ethtool_idnic(struct net_device *dev,
+			      enum ethtool_phys_id_state state)
 {
 	struct vxgedev *vdev = netdev_priv(dev);
 	struct __vxge_hw_device *hldev = vdev->devh;
 
-	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
-	msleep_interruptible(data ? (data * HZ) : VXGE_MAX_FLICKER_TIME);
-	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_OFF);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_OFF);
+		break;
+
+	default:
+		return -EINVAL;
+	}
 
 	return 0;
 }
@@ -1183,7 +1190,7 @@ static const struct ethtool_ops vxge_eth
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= vxge_ethtool_op_set_tso,
 	.get_strings		= vxge_ethtool_get_strings,
-	.phys_id		= vxge_ethtool_idnic,
+	.set_phys_id		= vxge_ethtool_idnic,
 	.get_sset_count		= vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	= vxge_get_ethtool_stats,
 	.set_flags		= vxge_set_flags,


