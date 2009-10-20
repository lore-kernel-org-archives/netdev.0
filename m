From: Steven King <sfking@fdwdc.com>
Subject: [PATCH v2] fix section mismatch in fec.c
Date: Tue, 20 Oct 2009 16:00:10 -0700
Message-ID: <200910201600.10545.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752839AbZJTXAL@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fec_enet_init is called by both fec_probe and fec_resume, so it shouldn't 
be marked as __init.

Signed-off-by: Steven King <sfking@fdwdc.com>


diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2923438..16a1d58 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1654,7 +1654,7 @@ static const struct net_device_ops fec_netdev_ops = {
   *
   * index is only used in legacy code
   */
-int __init fec_enet_init(struct net_device *dev, int index)
+static int fec_enet_init(struct net_device *dev, int index)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct bufdesc *cbd_base;

-- 
Steven King -- sfking at fdwdc dot com
