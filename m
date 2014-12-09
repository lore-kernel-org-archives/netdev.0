From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/13] i40e: add range check to i40e_aq_rc_to_posix
Date: Tue,  9 Dec 2014 13:26:12 -0800
Message-ID: <1418160380-29847-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60967 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088AbaLIV00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:26 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Just to be sure, add a range check to avoid any possible
array index-out-of-bound issues.

CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Change-ID: I9323bee6732c2a47599816e1d6c6b3a1f8dcbf54
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2:
 - modified the patch to use ARRAY_SIZE() macro as suggested by Sergei Shtylyov

 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 618fe96..2c68bf7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
 		-EFBIG,      /* I40E_AQ_RC_EFBIG */
 	};
 
+	if (aq_rc >= ARRAY_SIZE(aq_to_posix))
+		return -ERANGE;
 	return aq_to_posix[aq_rc];
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index d5d3c93..0ffb8d1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
 		-EFBIG,      /* I40E_AQ_RC_EFBIG */
 	};
 
+	if (aq_rc >= ARRAY_SIZE(aq_to_posix))
+		return -ERANGE;
 	return aq_to_posix[aq_rc];
 }
 
-- 
1.9.3
