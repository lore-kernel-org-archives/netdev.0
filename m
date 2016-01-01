From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-i40e: Replace variable initialisations by assignments in
 i40e_vc_get_vf_resources_msg()
Date: Fri, 1 Jan 2016 15:32:43 +0100
Message-ID: <56868E0B.5040602@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 15:11:09 +0100

Replace explicit initialisations for four local variables at the beginning
by assignments that will only be performed if the corresponding code
will really be executed.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index aa58a49..e0874f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1172,16 +1172,18 @@ static int i40e_vc_get_version_msg(struct i40e_vf *vf, u8 *msg)
  **/
 static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 {
-	struct i40e_virtchnl_vf_resource *vfres = NULL;
-	struct i40e_pf *pf = vf->pf;
-	i40e_status aq_ret = 0;
+	struct i40e_virtchnl_vf_resource *vfres;
+	struct i40e_pf *pf;
+	i40e_status aq_ret;
 	struct i40e_vsi *vsi;
-	int i = 0, len = 0;
+	int i = 0;
 	int num_vsis = 1;
-	int ret;
+	int len, ret;
 
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
+		vfres = NULL;
+		len = 0;
 		goto err;
 	}
 
@@ -1202,6 +1204,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 				  I40E_VIRTCHNL_VF_OFFLOAD_VLAN;
 
 	vfres->vf_offload_flags = I40E_VIRTCHNL_VF_OFFLOAD_L2;
+	pf = vf->pf;
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!vsi->info.pvid)
 		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_VLAN;
@@ -1231,7 +1234,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 		i++;
 	}
 	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
-
+	aq_ret = 0;
 err:
 	/* send the response back to the VF */
 	ret = i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_GET_VF_RESOURCES,
-- 
2.6.3
