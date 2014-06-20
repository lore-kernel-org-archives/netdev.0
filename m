From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40evf: fix off-by-one
Date: Fri, 20 Jun 2014 00:49:45 -0700
Message-ID: <1403250588-14356-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62075 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbaFTHt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:59 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The loop in i40evf_get_rxfh_indir was only reading fifteen registers,
not all sixteen. Change the matching loop in i40evf_set_rxfh_indir at
the same time to make the code more consistent.

Change-ID: I6c182287698e742d1f6ca1a4bcc43cc08df6e1de
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 60407a9..e70e4cd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -632,7 +632,7 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
 	u32 hlut_val;
 	int i, j;
 
-	for (i = 0, j = 0; i < I40E_VFQF_HLUT_MAX_INDEX; i++) {
+	for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
 		hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
 		indir[j++] = hlut_val & 0xff;
 		indir[j++] = (hlut_val >> 8) & 0xff;
@@ -659,7 +659,7 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 	u32 hlut_val;
 	int i, j;
 
-	for (i = 0, j = 0; i < I40E_VFQF_HLUT_MAX_INDEX + 1; i++) {
+	for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
 		hlut_val = indir[j++];
 		hlut_val |= indir[j++] << 8;
 		hlut_val |= indir[j++] << 16;
-- 
1.9.3
