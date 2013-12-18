From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e: more print_hex_dump use
Date: Tue, 17 Dec 2013 22:44:33 -0800
Message-ID: <1387349082-18506-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab3LRGoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:54 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Take advantage of print_hex_dump() in another couple places to
clean up the code.

Change-Id: Ib618e75f928308c0afd0d8d74105da0c6577a024
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 30 ++++++++++----------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index abac831..aaa2b5c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -362,7 +362,7 @@ static ssize_t i40e_dbg_command_read(struct file *filp, char __user *buffer,
 }
 
 /**
- * i40e_dbg_dump_vsi_seid - handles dump vsi seid write into pokem datum
+ * i40e_dbg_dump_vsi_seid - handles dump vsi seid write into command datum
  * @pf: the i40e_pf created in command write
  * @seid: the seid the user put in
  **/
@@ -707,8 +707,13 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 {
 	struct i40e_adminq_ring *ring;
 	struct i40e_hw *hw = &pf->hw;
+	char hdr[32];
 	int i;
 
+	snprintf(hdr, sizeof(hdr), "%s %s:         ",
+		 dev_driver_string(&pf->pdev->dev),
+		 dev_name(&pf->pdev->dev));
+
 	/* first the send (command) ring, then the receive (event) ring */
 	dev_info(&pf->pdev->dev, "AdminQ Tx Ring\n");
 	ring = &(hw->aq.asq);
@@ -718,14 +723,8 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 			 "   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
 			 i, d->flags, d->opcode, d->datalen, d->retval,
 			 d->cookie_high, d->cookie_low);
-		dev_info(&pf->pdev->dev,
-			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			 d->params.raw[12], d->params.raw[13],
-			 d->params.raw[14], d->params.raw[15]);
+		print_hex_dump(KERN_INFO, hdr, DUMP_PREFIX_NONE,
+			       16, 1, d->params.raw, 16, 0);
 	}
 
 	dev_info(&pf->pdev->dev, "AdminQ Rx Ring\n");
@@ -736,14 +735,8 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 			 "   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
 			 i, d->flags, d->opcode, d->datalen, d->retval,
 			 d->cookie_high, d->cookie_low);
-		dev_info(&pf->pdev->dev,
-			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			 d->params.raw[12], d->params.raw[13],
-			 d->params.raw[14], d->params.raw[15]);
+		print_hex_dump(KERN_INFO, hdr, DUMP_PREFIX_NONE,
+			       16, 1, d->params.raw, 16, 0);
 	}
 }
 
@@ -973,8 +966,7 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 
 	veb = i40e_dbg_find_veb(pf, seid);
 	if (!veb) {
-		dev_info(&pf->pdev->dev,
-			 "%d: can't find veb\n", seid);
+		dev_info(&pf->pdev->dev, "can't find veb %d\n", seid);
 		return;
 	}
 	dev_info(&pf->pdev->dev,
-- 
1.8.3.1
