From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 05/26] atl1: print debug info if rrd error
Date: Mon, 31 Dec 2007 20:22:32 -0600
Message-ID: <1199154173-4058-6-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:64425 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbYAAC2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:16 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some debug dev_printks if we encounter a bad receive return descriptor.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 239641f..262d3ca 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1127,7 +1127,26 @@ static void atl1_intr_rx(struct atl1_adapter *adapter)
 		if (likely(rrd->xsz.valid)) {	/* packet valid */
 chk_rrd:
 			/* check rrd status */
-			if (likely(rrd->num_buf == 1))
+			if (rrd->num_buf != 1) {
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"rx_buf_len = %d\n",
+					adapter->rx_buffer_len);
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"RRD num_buf = %d\n",
+					rrd->num_buf);
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"RRD pkt_len = %d\n",
+					rrd->xsz.xsum_sz.pkt_size);
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"RRD pkt_flg = 0x%08X\n",
+					rrd->pkt_flg);
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"RRD err_flg = 0x%08X\n",
+					rrd->err_flg);
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"RRD vlan_tag = 0x%08X\n",
+					rrd->vlan_tag);
+			} else
 				goto rrd_ok;
 
 			/* rrd seems to be bad */
-- 
1.5.3.3

