From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/18] i40evf: ethtool RSS fixes
Date: Sat, 28 Feb 2015 03:29:46 -0800
Message-ID: <1425122989-354-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbbB1LaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:00 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add an extra check to make sure that the indirection table pointer is
valid before dereferencing it.

Change-ID: I698adbf3daff03081d01f489dc95a9f1ad8b12f1
Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index c5ffacc..681a5d4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -642,12 +642,14 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	if (!indir)
 		return 0;
 
-	for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
-		hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
-		indir[j++] = hlut_val & 0xff;
-		indir[j++] = (hlut_val >> 8) & 0xff;
-		indir[j++] = (hlut_val >> 16) & 0xff;
-		indir[j++] = (hlut_val >> 24) & 0xff;
+	if (indir) {
+		for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
+			hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
+			indir[j++] = hlut_val & 0xff;
+			indir[j++] = (hlut_val >> 8) & 0xff;
+			indir[j++] = (hlut_val >> 16) & 0xff;
+			indir[j++] = (hlut_val >> 24) & 0xff;
+		}
 	}
 	return 0;
 }
-- 
1.9.3
