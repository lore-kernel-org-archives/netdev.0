From: "Underwood, JohnX" <johnx.underwood@intel.com>
Subject: RE: [net-next 10/16] i40e: add check for null VSI
Date: Fri, 19 Feb 2016 19:15:53 +0000
Message-ID: <49FCCD093EDAFE45B73804AC3C1112E52E5CC6@ORSMSX116.amr.corp.intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1455875651-21696-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56489 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1428530AbcBSTPz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 14:15:55 -0500
In-Reply-To: <1455875651-21696-11-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ACK

-----Original Message-----
From: Kirsher, Jeffrey T 
Sent: Friday, February 19, 2016 1:54 AM
To: davem@davemloft.net
Cc: Underwood, JohnX; netdev@vger.kernel.org; nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com; Kirsher, Jeffrey T
Subject: [net-next 10/16] i40e: add check for null VSI

From: John Underwood <johnx.underwood@intel.com>

Return from i40e_vsi_reinit_setup() if vsi param is NULL.
This makes this code consistent with all the other code that checks for NULL before using one of the VSI pointers accessed with an indexed variable. (Indexed VSI pointers are intentionally set to NULL in i40e_vsi_clear() and i40e_remove().

Change-ID: I3bc8b909c70fd2439334eeae994d151f61480985
Signed-off-by: John Underwood <johnx.underwood@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 05def9f..3ff3e83 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9583,10 +9583,15 @@ vector_setup_out:
  **/
 static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)  {
-	struct i40e_pf *pf = vsi->back;
+	struct i40e_pf *pf;
 	u8 enabled_tc;
 	int ret;
 
+	if (!vsi)
+		return NULL;
+
+	pf = vsi->back;
+
 	i40e_put_lump(pf->qp_pile, vsi->base_queue, vsi->idx);
 	i40e_vsi_clear_rings(vsi);
 
