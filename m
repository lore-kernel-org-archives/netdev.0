From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: not all VSIs have rings
Date: Sun,  8 Jun 2014 07:33:52 -0700
Message-ID: <1402238037-20661-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64920 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753538AbaFHOeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:06 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Once more, with feeling: not all VSIs have rings. To assume so is to
invite null pointers to your party.

Change-ID: I576858824468d9712d119fa1015a1f28c27712c4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a8c9612..4502734 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -657,7 +657,7 @@ static void i40e_update_link_xoff_rx(struct i40e_pf *pf)
 	for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
 		struct i40e_vsi *vsi = pf->vsi[v];
 
-		if (!vsi)
+		if (!vsi || !vsi->tx_rings[0])
 			continue;
 
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
@@ -711,7 +711,7 @@ static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
 	for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
 		struct i40e_vsi *vsi = pf->vsi[v];
 
-		if (!vsi)
+		if (!vsi || !vsi->tx_rings[0])
 			continue;
 
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-- 
1.9.3
