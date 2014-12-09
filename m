From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: add range check to i40e_aq_rc_to_posix
Date: Tue,  9 Dec 2014 03:22:42 -0800
Message-ID: <1418124170-7495-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43349 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756575AbaLILW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 06:22:58 -0500
In-Reply-To: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Just to be sure, add a range check to avoid any possible
array index-out-of-bound issues.

Change-ID: I9323bee6732c2a47599816e1d6c6b3a1f8dcbf54
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 618fe96..4064b1e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
 		-EFBIG,      /* I40E_AQ_RC_EFBIG */
 	};
 
+	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])))
+		return -ERANGE;
 	return aq_to_posix[aq_rc];
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index d5d3c93..4d63514 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
 		-EFBIG,      /* I40E_AQ_RC_EFBIG */
 	};
 
+	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])))
+		return -ERANGE;
 	return aq_to_posix[aq_rc];
 }
 
-- 
1.9.3
