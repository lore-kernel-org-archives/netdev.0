From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/77] irda: net_device_ops ioctl fix
Date: Fri, 20 Mar 2009 22:35:33 -0700
Message-ID: <20090321053713.012084771@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36574 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760880AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to reference net_device_ops not old pointer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/irda/irda_device.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/net/irda/irda_device.c	2009-03-19 22:40:30.469964248 -0700
+++ b/net/irda/irda_device.c	2009-03-19 22:42:44.867089916 -0700
@@ -149,13 +149,14 @@ int irda_device_is_receiving(struct net_
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	if (!dev->do_ioctl) {
+	if (!dev->netdev_ops->ndo_do_ioctl) {
 		IRDA_ERROR("%s: do_ioctl not impl. by device driver\n",
 			   __func__);
 		return -1;
 	}
 
-	ret = dev->do_ioctl(dev, (struct ifreq *) &req, SIOCGRECEIVING);
+	ret = (dev->netdev_ops->ndo_do_ioctl)(dev, (struct ifreq *) &req,
+					      SIOCGRECEIVING);
 	if (ret < 0)
 		return ret;
 

-- 

