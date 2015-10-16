From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/17] i40e/i40evf: Fix compile issue related to const string
Date: Fri, 16 Oct 2015 05:10:14 -0700
Message-ID: <1444997425-3396-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jingjing Wu <jingjing.wu@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082AbbJPMKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:40 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingjing Wu <jingjing.wu@intel.com>

Add const to functions that return strings that aren't going to be
modified. This addresses some reported compile complaints.

Change-ID: Ic56b1e814ab4d23a50480e7fdec652445f776ee8
Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h | 4 ++--
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index d1ee174..daa6b17 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -87,7 +87,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
  * @hw: pointer to the HW structure
  * @aq_err: the AQ error code to convert
  **/
-char *i40e_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
+const char *i40e_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
 {
 	switch (aq_err) {
 	case I40E_AQ_RC_OK:
@@ -147,7 +147,7 @@ char *i40e_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
  * @hw: pointer to the HW structure
  * @stat_err: the status error code to convert
  **/
-char *i40e_stat_str(struct i40e_hw *hw, i40e_status stat_err)
+const char *i40e_stat_str(struct i40e_hw *hw, i40e_status stat_err)
 {
 	switch (stat_err) {
 	case 0:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 2142e10..875a8cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -632,7 +632,7 @@ static inline u8 i40e_nvmupd_get_transaction(u32 val)
 	return (u8)((val & I40E_NVM_TRANS_MASK) >> I40E_NVM_TRANS_SHIFT);
 }
 
-static char *i40e_nvm_update_state_str[] = {
+static const char * const i40e_nvm_update_state_str[] = {
 	"I40E_NVMUPD_INVALID",
 	"I40E_NVMUPD_READ_CON",
 	"I40E_NVMUPD_READ_SNT",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 4454974..10bf2ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -58,8 +58,8 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask,
 void i40e_idle_aq(struct i40e_hw *hw);
 bool i40e_check_asq_alive(struct i40e_hw *hw);
 i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw, bool unloading);
-char *i40e_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err);
-char *i40e_stat_str(struct i40e_hw *hw, i40e_status stat_err);
+const char *i40e_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err);
+const char *i40e_stat_str(struct i40e_hw *hw, i40e_status stat_err);
 
 i40e_status i40e_aq_get_rss_lut(struct i40e_hw *hw, u16 seid,
 				bool pf_lut, u8 *lut, u16 lut_size);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index b98b642..7435fb3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -87,7 +87,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
  * @hw: pointer to the HW structure
  * @aq_err: the AQ error code to convert
  **/
-char *i40evf_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
+const char *i40evf_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
 {
 	switch (aq_err) {
 	case I40E_AQ_RC_OK:
@@ -147,7 +147,7 @@ char *i40evf_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err)
  * @hw: pointer to the HW structure
  * @stat_err: the status error code to convert
  **/
-char *i40evf_stat_str(struct i40e_hw *hw, i40e_status stat_err)
+const char *i40evf_stat_str(struct i40e_hw *hw, i40e_status stat_err)
 {
 	switch (stat_err) {
 	case 0:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 55ae4b0..8ed0edf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -60,8 +60,8 @@ void i40e_idle_aq(struct i40e_hw *hw);
 void i40evf_resume_aq(struct i40e_hw *hw);
 bool i40evf_check_asq_alive(struct i40e_hw *hw);
 i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw, bool unloading);
-char *i40evf_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err);
-char *i40evf_stat_str(struct i40e_hw *hw, i40e_status stat_err);
+const char *i40evf_aq_str(struct i40e_hw *hw, enum i40e_admin_queue_err aq_err);
+const char *i40evf_stat_str(struct i40e_hw *hw, i40e_status stat_err);
 
 i40e_status i40evf_aq_get_rss_lut(struct i40e_hw *hw, u16 seid,
 				  bool pf_lut, u8 *lut, u16 lut_size);
-- 
2.4.3
