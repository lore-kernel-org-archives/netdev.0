From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/20][BNX2]: Block MII access when ifdown.
Date: Tue, 01 May 2007 18:12:21 -0700
Message-ID: <1178068341.4820.37.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1718 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946159AbXEBAZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Block MII access when ifdown.

The device may be in D3hot state and should not allow MII register
access.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f98a220..9f0a067 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5562,6 +5562,9 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG: {
 		u32 mii_regval;
 
+		if (!netif_running(dev))
+			return -EAGAIN;
+
 		spin_lock_bh(&bp->phy_lock);
 		err = bnx2_read_phy(bp, data->reg_num & 0x1f, &mii_regval);
 		spin_unlock_bh(&bp->phy_lock);
@@ -5575,6 +5578,9 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		if (!netif_running(dev))
+			return -EAGAIN;
+
 		spin_lock_bh(&bp->phy_lock);
 		err = bnx2_write_phy(bp, data->reg_num & 0x1f, data->val_in);
 		spin_unlock_bh(&bp->phy_lock);


