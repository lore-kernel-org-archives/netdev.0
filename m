From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: _MASK vs _SHIFT typo in i40e_handle_mdd_event()
Date: Wed, 22 Oct 2014 20:06:29 -0700
Message-ID: <1414033589-7544-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17198 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379AbaJWDGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 23:06:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We accidentally mask by the _SHIFT variable.  It means that "event" is
always zero.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ed5f1c1..c3a7f4a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6151,7 +6151,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 				I40E_GL_MDET_TX_PF_NUM_SHIFT;
 		u8 vf_num = (reg & I40E_GL_MDET_TX_VF_NUM_MASK) >>
 				I40E_GL_MDET_TX_VF_NUM_SHIFT;
-		u8 event = (reg & I40E_GL_MDET_TX_EVENT_SHIFT) >>
+		u8 event = (reg & I40E_GL_MDET_TX_EVENT_MASK) >>
 				I40E_GL_MDET_TX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK) >>
 				I40E_GL_MDET_TX_QUEUE_SHIFT;
@@ -6165,7 +6165,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 	if (reg & I40E_GL_MDET_RX_VALID_MASK) {
 		u8 func = (reg & I40E_GL_MDET_RX_FUNCTION_MASK) >>
 				I40E_GL_MDET_RX_FUNCTION_SHIFT;
-		u8 event = (reg & I40E_GL_MDET_RX_EVENT_SHIFT) >>
+		u8 event = (reg & I40E_GL_MDET_RX_EVENT_MASK) >>
 				I40E_GL_MDET_RX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK) >>
 				I40E_GL_MDET_RX_QUEUE_SHIFT;
-- 
1.9.3
