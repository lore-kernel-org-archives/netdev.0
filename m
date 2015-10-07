From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/18] i40e/i40evf: fix a potential type compare issue
Date: Wed,  7 Oct 2015 15:46:59 -0700
Message-ID: <1444258032-41476-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579AbbJGWrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:23 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Rework an if expression to assure there is no type compare problem between
a size and a possible negative number.

Change-ID: I4921fcc96abfcf69490efce020a9e4007f251c99
Reported-by: Helin Zhang <helin.zhang@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 3 +--
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index ca81b0b..12fbbdd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -144,8 +144,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])) ||
-	    aq_rc < 0)
+	if (!((u32)aq_rc < (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0]))))
 		return -ERANGE;
 
 	return aq_to_posix[aq_rc];
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index e62e951..a3eae5d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -144,8 +144,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])) ||
-	    aq_rc < 0)
+	if (!((u32)aq_rc < (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0]))))
 		return -ERANGE;
 
 	return aq_to_posix[aq_rc];
-- 
2.4.3
