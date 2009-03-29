From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 2/10] Staging: epl: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:24:32 +0400
Message-ID: <20090329152432.GB11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:25905 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbZC2PYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:24:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/epl/VirtualEthernetLinux.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/epl/VirtualEthernetLinux.c b/drivers/staging/epl/VirtualEthernetLinux.c
index 21206c4..077724a 100644
--- a/drivers/staging/epl/VirtualEthernetLinux.c
+++ b/drivers/staging/epl/VirtualEthernetLinux.c
@@ -284,6 +284,17 @@ static tEplKernel VEthRecvFrame(tEplFrameInfo * pFrameInfo_p)
 	return Ret;
 }
 
+static const struct net_device_ops epl_netdev_ops = {
+	.ndo_open		= VEthOpen,
+	.ndo_stop		= VEthClose,
+	.ndo_get_stats		= VEthGetStats,
+	.ndo_start_xmit		= VEthXmit,
+	.ndo_tx_timeout		= VEthTimeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 tEplKernel VEthAddInstance(tEplDllkInitParam *pInitParam_p)
 {
 	tEplKernel Ret = kEplSuccessful;
@@ -299,11 +310,7 @@ tEplKernel VEthAddInstance(tEplDllkInitParam *pInitParam_p)
 		goto Exit;
 	}
 
-	pVEthNetDevice_g->open = VEthOpen;
-	pVEthNetDevice_g->stop = VEthClose;
-	pVEthNetDevice_g->get_stats = VEthGetStats;
-	pVEthNetDevice_g->hard_start_xmit = VEthXmit;
-	pVEthNetDevice_g->tx_timeout = VEthTimeout;
+	pVEthNetDevice_g->netdev_ops = &epl_netdev_ops;
 	pVEthNetDevice_g->watchdog_timeo = EPL_VETH_TX_TIMEOUT;
 	pVEthNetDevice_g->destructor = free_netdev;
 
