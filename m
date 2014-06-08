From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Fix incorrect feature configuration status
Date: Sun,  8 Jun 2014 07:33:50 -0700
Message-ID: <1402238037-20661-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64920 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535AbaFHOeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:06 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch fixes an issue where FD SB/ATR and NTUPLE configurations status are
reported erroneously. Without this patch, driver reports FDir without further
information.

Change-ID: I5bdd2871b7f2db1e5f5e76c741ae6a0dc603b453
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 00fdc30..8ab3c88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8237,11 +8237,12 @@ static void i40e_print_features(struct i40e_pf *pf)
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
 		buf += sprintf(buf, "RSS ");
-	buf += sprintf(buf, "FDir ");
 	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
-		buf += sprintf(buf, "ATR ");
-	if (pf->flags & I40E_FLAG_FD_SB_ENABLED)
+		buf += sprintf(buf, "FD_ATR ");
+	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
+		buf += sprintf(buf, "FD_SB ");
 		buf += sprintf(buf, "NTUPLE ");
+	}
 	if (pf->flags & I40E_FLAG_DCB_ENABLED)
 		buf += sprintf(buf, "DCB ");
 	if (pf->flags & I40E_FLAG_PTP)
-- 
1.9.3
