From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Fix for extra byte swap in tunnel setup
Date: Tue, 20 Sep 2016 20:43:45 -0700
Message-ID: <1474429432-102772-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754843AbcIUDn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:57 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes an issue where we were byte swapping the port
parameter, then byte swapping it again in function execution.
Obviously, that's unnecessary, so take it out of the function calls.
Without this patch, the udp based tunnel configuration would
not be correct.

Change-ID: I788d83c5bd5732170f1a81dbfa0b1ac3ca8ea5b7
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 45b9c67..3fdaf36 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7154,9 +7154,9 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 			pf->pending_udp_bitmap &= ~BIT_ULL(i);
 			port = pf->udp_ports[i].index;
 			if (port)
-				ret = i40e_aq_add_udp_tunnel(hw, ntohs(port),
-						     pf->udp_ports[i].type,
-						     NULL, NULL);
+				ret = i40e_aq_add_udp_tunnel(hw, port,
+							pf->udp_ports[i].type,
+							NULL, NULL);
 			else
 				ret = i40e_aq_del_udp_tunnel(hw, i, NULL);
 
-- 
2.7.4
