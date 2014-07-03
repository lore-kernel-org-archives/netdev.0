From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e/i40evf: Force a shifted '1' to be unsigned
Date: Wed,  2 Jul 2014 19:40:22 -0700
Message-ID: <1404355233-30123-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56262 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbaGCClJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:09 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

Force a shifted '1' to be unsiged to avoid shifting a signed int

Change-ID: I688cbd082af0f2e1df548fda25847a5ca04babcf
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_hmc.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
index b45d8fe..732a026 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
@@ -127,7 +127,7 @@ struct i40e_hmc_info {
 		((((type) == I40E_SD_TYPE_PAGED) ? 0 : 1) <<		\
 		I40E_PFHMC_SDDATALOW_PMSDTYPE_SHIFT) |			\
 		(1 << I40E_PFHMC_SDDATALOW_PMSDVALID_SHIFT);		\
-	val3 = (sd_index) | (1 << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
+	val3 = (sd_index) | (1u << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
 	wr32((hw), I40E_PFHMC_SDDATAHIGH, val1);			\
 	wr32((hw), I40E_PFHMC_SDDATALOW, val2);				\
 	wr32((hw), I40E_PFHMC_SDCMD, val3);				\
@@ -146,7 +146,7 @@ struct i40e_hmc_info {
 		I40E_PFHMC_SDDATALOW_PMSDBPCOUNT_SHIFT) |		\
 		((((type) == I40E_SD_TYPE_PAGED) ? 0 : 1) <<		\
 		I40E_PFHMC_SDDATALOW_PMSDTYPE_SHIFT);			\
-	val3 = (sd_index) | (1 << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
+	val3 = (sd_index) | (1u << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
 	wr32((hw), I40E_PFHMC_SDDATAHIGH, 0);				\
 	wr32((hw), I40E_PFHMC_SDDATALOW, val2);				\
 	wr32((hw), I40E_PFHMC_SDCMD, val3);				\
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
index a2ad9a4..931c880 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
@@ -127,7 +127,7 @@ struct i40e_hmc_info {
 		((((type) == I40E_SD_TYPE_PAGED) ? 0 : 1) <<		\
 		I40E_PFHMC_SDDATALOW_PMSDTYPE_SHIFT) |			\
 		(1 << I40E_PFHMC_SDDATALOW_PMSDVALID_SHIFT);		\
-	val3 = (sd_index) | (1 << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
+	val3 = (sd_index) | (1u << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
 	wr32((hw), I40E_PFHMC_SDDATAHIGH, val1);			\
 	wr32((hw), I40E_PFHMC_SDDATALOW, val2);				\
 	wr32((hw), I40E_PFHMC_SDCMD, val3);				\
@@ -146,7 +146,7 @@ struct i40e_hmc_info {
 		I40E_PFHMC_SDDATALOW_PMSDBPCOUNT_SHIFT) |		\
 		((((type) == I40E_SD_TYPE_PAGED) ? 0 : 1) <<		\
 		I40E_PFHMC_SDDATALOW_PMSDTYPE_SHIFT);			\
-	val3 = (sd_index) | (1 << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
+	val3 = (sd_index) | (1u << I40E_PFHMC_SDCMD_PMSDWR_SHIFT);	\
 	wr32((hw), I40E_PFHMC_SDDATAHIGH, 0);				\
 	wr32((hw), I40E_PFHMC_SDDATALOW, val2);				\
 	wr32((hw), I40E_PFHMC_SDCMD, val3);				\
-- 
1.9.3
