From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 3/6] i40e: small clean ups from review
Date: Fri, 27 Sep 2013 05:35:55 -0700
Message-ID: <1380285358-15685-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57204 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384Ab3I0MgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 08:36:03 -0400
In-Reply-To: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As mentioned by Joe Perches clean up a loop flow.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Joe Perches <joe@perches.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 67f8fd5..865bc6b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -174,8 +174,7 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 			 u16 needed, u16 id)
 {
 	int ret = -ENOMEM;
-	int i = 0;
-	int j = 0;
+	int i, j;
 
 	if (!pile || needed == 0 || id >= I40E_PILE_VALID_BIT) {
 		dev_info(&pf->pdev->dev,
@@ -186,7 +185,7 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 
 	/* start the linear search with an imperfect hint */
 	i = pile->search_hint;
-	while (i < pile->num_entries && ret < 0) {
+	while (i < pile->num_entries) {
 		/* skip already allocated entries */
 		if (pile->list[i] & I40E_PILE_VALID_BIT) {
 			i++;
@@ -205,6 +204,7 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 				pile->list[i+j] = id | I40E_PILE_VALID_BIT;
 			ret = i;
 			pile->search_hint = i + j;
+			break;
 		} else {
 			/* not enough, so skip over it and continue looking */
 			i += j;
-- 
1.8.3.1
