From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] i40e: rename variable to prevent clash of understanding
Date: Thu, 17 Sep 2015 17:17:53 -0700
Message-ID: <1442535480-65222-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18405 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbbIRASG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:06 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This code returns something that becomes the errno value from ethtool and
passes around a pointer to an errno variable.  This patch changes the name
slightly to differentiate it from the actual user errno variable.

Change-ID: Idaa37845c069e66f4cea072e90f471bb2142454d
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 114 ++++++++++++++---------------
 1 file changed, 57 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 9b83abc..3f2fec9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -592,25 +592,25 @@ i40e_validate_nvm_checksum_exit:
 
 static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 					  struct i40e_nvm_access *cmd,
-					  u8 *bytes, int *errno);
+					  u8 *bytes, int *perrno);
 static i40e_status i40e_nvmupd_state_reading(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
-					     u8 *bytes, int *errno);
+					     u8 *bytes, int *perrno);
 static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
 					     u8 *bytes, int *errno);
 static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 						struct i40e_nvm_access *cmd,
-						int *errno);
+						int *perrno);
 static i40e_status i40e_nvmupd_nvm_erase(struct i40e_hw *hw,
 					 struct i40e_nvm_access *cmd,
-					 int *errno);
+					 int *perrno);
 static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 					 struct i40e_nvm_access *cmd,
-					 u8 *bytes, int *errno);
+					 u8 *bytes, int *perrno);
 static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 					struct i40e_nvm_access *cmd,
-					u8 *bytes, int *errno);
+					u8 *bytes, int *perrno);
 static inline u8 i40e_nvmupd_get_module(u32 val)
 {
 	return (u8)(val & I40E_NVM_MOD_PNT_MASK);
@@ -641,30 +641,30 @@ static char *i40e_nvm_update_state_str[] = {
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * Dispatches command depending on what update state is current
  **/
 i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 				struct i40e_nvm_access *cmd,
-				u8 *bytes, int *errno)
+				u8 *bytes, int *perrno)
 {
 	i40e_status status;
 
 	/* assume success */
-	*errno = 0;
+	*perrno = 0;
 
 	switch (hw->nvmupd_state) {
 	case I40E_NVMUPD_STATE_INIT:
-		status = i40e_nvmupd_state_init(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_state_init(hw, cmd, bytes, perrno);
 		break;
 
 	case I40E_NVMUPD_STATE_READING:
-		status = i40e_nvmupd_state_reading(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_state_reading(hw, cmd, bytes, perrno);
 		break;
 
 	case I40E_NVMUPD_STATE_WRITING:
-		status = i40e_nvmupd_state_writing(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_state_writing(hw, cmd, bytes, perrno);
 		break;
 
 	default:
@@ -672,7 +672,7 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "NVMUPD: no such state %d\n", hw->nvmupd_state);
 		status = I40E_NOT_SUPPORTED;
-		*errno = -ESRCH;
+		*perrno = -ESRCH;
 		break;
 	}
 	return status;
@@ -683,28 +683,28 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * Process legitimate commands of the Init state and conditionally set next
  * state. Reject all other commands.
  **/
 static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 					  struct i40e_nvm_access *cmd,
-					  u8 *bytes, int *errno)
+					  u8 *bytes, int *perrno)
 {
 	i40e_status status = 0;
 	enum i40e_nvmupd_cmd upd_cmd;
 
-	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, errno);
+	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
 
 	switch (upd_cmd) {
 	case I40E_NVMUPD_READ_SA:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
-			status = i40e_nvmupd_nvm_read(hw, cmd, bytes, errno);
+			status = i40e_nvmupd_nvm_read(hw, cmd, bytes, perrno);
 			i40e_release_nvm(hw);
 		}
 		break;
@@ -712,10 +712,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 	case I40E_NVMUPD_READ_SNT:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
-			status = i40e_nvmupd_nvm_read(hw, cmd, bytes, errno);
+			status = i40e_nvmupd_nvm_read(hw, cmd, bytes, perrno);
 			if (status)
 				i40e_release_nvm(hw);
 			else
@@ -726,10 +726,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 	case I40E_NVMUPD_WRITE_ERA:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_WRITE);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
-			status = i40e_nvmupd_nvm_erase(hw, cmd, errno);
+			status = i40e_nvmupd_nvm_erase(hw, cmd, perrno);
 			if (status)
 				i40e_release_nvm(hw);
 			else
@@ -740,10 +740,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 	case I40E_NVMUPD_WRITE_SA:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_WRITE);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
-			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
+			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
 			if (status)
 				i40e_release_nvm(hw);
 			else
@@ -754,10 +754,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 	case I40E_NVMUPD_WRITE_SNT:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_WRITE);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
-			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
+			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
 			if (status)
 				i40e_release_nvm(hw);
 			else
@@ -768,12 +768,12 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 	case I40E_NVMUPD_CSUM_SA:
 		status = i40e_acquire_nvm(hw, I40E_RESOURCE_WRITE);
 		if (status) {
-			*errno = i40e_aq_rc_to_posix(status,
+			*perrno = i40e_aq_rc_to_posix(status,
 						     hw->aq.asq_last_status);
 		} else {
 			status = i40e_update_nvm_checksum(hw);
 			if (status) {
-				*errno = hw->aq.asq_last_status ?
+				*perrno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(status,
 						       hw->aq.asq_last_status) :
 				   -EIO;
@@ -789,7 +789,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			   "NVMUPD: bad cmd %s in init state\n",
 			   i40e_nvm_update_state_str[upd_cmd]);
 		status = I40E_ERR_NVM;
-		*errno = -ESRCH;
+		*perrno = -ESRCH;
 		break;
 	}
 	return status;
@@ -800,28 +800,28 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * NVM ownership is already held.  Process legitimate commands and set any
  * change in state; reject all other commands.
  **/
 static i40e_status i40e_nvmupd_state_reading(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
-					     u8 *bytes, int *errno)
+					     u8 *bytes, int *perrno)
 {
 	i40e_status status;
 	enum i40e_nvmupd_cmd upd_cmd;
 
-	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, errno);
+	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
 
 	switch (upd_cmd) {
 	case I40E_NVMUPD_READ_SA:
 	case I40E_NVMUPD_READ_CON:
-		status = i40e_nvmupd_nvm_read(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_nvm_read(hw, cmd, bytes, perrno);
 		break;
 
 	case I40E_NVMUPD_READ_LCB:
-		status = i40e_nvmupd_nvm_read(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_nvm_read(hw, cmd, bytes, perrno);
 		i40e_release_nvm(hw);
 		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		break;
@@ -831,7 +831,7 @@ static i40e_status i40e_nvmupd_state_reading(struct i40e_hw *hw,
 			   "NVMUPD: bad cmd %s in reading state.\n",
 			   i40e_nvm_update_state_str[upd_cmd]);
 		status = I40E_NOT_SUPPORTED;
-		*errno = -ESRCH;
+		*perrno = -ESRCH;
 		break;
 	}
 	return status;
@@ -842,29 +842,29 @@ static i40e_status i40e_nvmupd_state_reading(struct i40e_hw *hw,
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * NVM ownership is already held.  Process legitimate commands and set any
  * change in state; reject all other commands
  **/
 static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
-					     u8 *bytes, int *errno)
+					     u8 *bytes, int *perrno)
 {
 	i40e_status status;
 	enum i40e_nvmupd_cmd upd_cmd;
 	bool retry_attempt = false;
 
-	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, errno);
+	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
 
 retry:
 	switch (upd_cmd) {
 	case I40E_NVMUPD_WRITE_CON:
-		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
 		break;
 
 	case I40E_NVMUPD_WRITE_LCB:
-		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
+		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
 		if (!status)
 			hw->aq.nvm_release_on_done = true;
 		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
@@ -873,7 +873,7 @@ retry:
 	case I40E_NVMUPD_CSUM_CON:
 		status = i40e_update_nvm_checksum(hw);
 		if (status) {
-			*errno = hw->aq.asq_last_status ?
+			*perrno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(status,
 						       hw->aq.asq_last_status) :
 				   -EIO;
@@ -884,7 +884,7 @@ retry:
 	case I40E_NVMUPD_CSUM_LCB:
 		status = i40e_update_nvm_checksum(hw);
 		if (status)
-			*errno = hw->aq.asq_last_status ?
+			*perrno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(status,
 						       hw->aq.asq_last_status) :
 				   -EIO;
@@ -898,7 +898,7 @@ retry:
 			   "NVMUPD: bad cmd %s in writing state.\n",
 			   i40e_nvm_update_state_str[upd_cmd]);
 		status = I40E_NOT_SUPPORTED;
-		*errno = -ESRCH;
+		*perrno = -ESRCH;
 		break;
 	}
 
@@ -941,13 +941,13 @@ retry:
  * i40e_nvmupd_validate_command - Validate given command
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * Return one of the valid command types or I40E_NVMUPD_INVALID
  **/
 static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 						 struct i40e_nvm_access *cmd,
-						 int *errno)
+						 int *perrno)
 {
 	enum i40e_nvmupd_cmd upd_cmd;
 	u8 transaction;
@@ -963,7 +963,7 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_validate_command data_size %d\n",
 			   cmd->data_size);
-		*errno = -EFAULT;
+		*perrno = -EFAULT;
 		return I40E_NVMUPD_INVALID;
 	}
 
@@ -1020,10 +1020,10 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		   hw->aq.nvm_release_on_done);
 
 	if (upd_cmd == I40E_NVMUPD_INVALID) {
-		*errno = -EFAULT;
+		*perrno = -EFAULT;
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_validate_command returns %d errno %d\n",
-			   upd_cmd, *errno);
+			   upd_cmd, *perrno);
 	}
 	return upd_cmd;
 }
@@ -1033,13 +1033,13 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * cmd structure contains identifiers and data buffer
  **/
 static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 					struct i40e_nvm_access *cmd,
-					u8 *bytes, int *errno)
+					u8 *bytes, int *perrno)
 {
 	i40e_status status;
 	u8 module, transaction;
@@ -1058,7 +1058,7 @@ static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_read status %d aq %d\n",
 			   status, hw->aq.asq_last_status);
-		*errno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
+		*perrno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
 	}
 
 	return status;
@@ -1068,13 +1068,13 @@ static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
  * i40e_nvmupd_nvm_erase - Erase an NVM module
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * module, offset, data_size and data are in cmd structure
  **/
 static i40e_status i40e_nvmupd_nvm_erase(struct i40e_hw *hw,
 					 struct i40e_nvm_access *cmd,
-					 int *errno)
+					 int *perrno)
 {
 	i40e_status status = 0;
 	u8 module, transaction;
@@ -1092,7 +1092,7 @@ static i40e_status i40e_nvmupd_nvm_erase(struct i40e_hw *hw,
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_erase status %d aq %d\n",
 			   status, hw->aq.asq_last_status);
-		*errno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
+		*perrno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
 	}
 
 	return status;
@@ -1103,13 +1103,13 @@ static i40e_status i40e_nvmupd_nvm_erase(struct i40e_hw *hw,
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
  * @bytes: pointer to the data buffer
- * @errno: pointer to return error code
+ * @perrno: pointer to return error code
  *
  * module, offset, data_size and data are in cmd structure
  **/
 static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 					 struct i40e_nvm_access *cmd,
-					 u8 *bytes, int *errno)
+					 u8 *bytes, int *perrno)
 {
 	i40e_status status = 0;
 	u8 module, transaction;
@@ -1128,7 +1128,7 @@ static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_write status %d aq %d\n",
 			   status, hw->aq.asq_last_status);
-		*errno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
+		*perrno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
 	}
 
 	return status;
-- 
2.4.3
