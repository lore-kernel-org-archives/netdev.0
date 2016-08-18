From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Force register writes to mitigate sync issues with iwarp VF driver
Date: Thu, 18 Aug 2016 14:57:29 -0700
Message-ID: <1471557456-136741-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14339 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754020AbcHSCjr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 22:39:47 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

This patch is a fix for the bug i.e. unable to create iwarp device
in VF. This is a sync issue and the iwarp device open is called even
before the PCI register writes are done.

Forcing the PCI register writes to happen just before it exits the
function.

Change-ID: I60c6a2c709da89e845f2764cc50ce8b7373c8c44
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 8726269..90b435c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -793,7 +793,8 @@ static int i40e_client_setup_qvlist(struct i40e_info *ldev,
 			wr32(hw, I40E_PFINT_AEQCTL, reg);
 		}
 	}
-
+	/* Mitigate sync problems with iwarp VF driver */
+	i40e_flush(hw);
 	return 0;
 err:
 	kfree(ldev->qvlist_info);
-- 
2.7.4
