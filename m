From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 7 Sep 2016 13:16:59 +1000
Message-ID: <20160907131659.2c6f8789@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Joe Perches <joe@perches.com>,
        Wu Fengguang <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/qlogic/qed/qed_dcbx.c

between commit:

  561ed23331df ("qed: fix kzalloc-simple.cocci warnings")

from the net tree and commit:

  2591c280c375 ("qed: Remove OOM messages")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 3656d2fd673d,be7b3dc7c9a7..000000000000
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@@ -1189,11 -1172,9 +1186,9 @@@ int qed_dcbx_get_config_params(struct q
  		return 0;
  	}
  
 -	dcbx_info = kmalloc(sizeof(*dcbx_info), GFP_KERNEL);
 +	dcbx_info = kzalloc(sizeof(*dcbx_info), GFP_KERNEL);
- 	if (!dcbx_info) {
- 		DP_ERR(p_hwfn, "Failed to allocate struct qed_dcbx_info\n");
+ 	if (!dcbx_info)
  		return -ENOMEM;
- 	}
  
  	rc = qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB);
  	if (rc) {
@@@ -1226,11 -1207,9 +1221,9 @@@ static struct qed_dcbx_get *qed_dcbnl_g
  {
  	struct qed_dcbx_get *dcbx_info;
  
 -	dcbx_info = kmalloc(sizeof(*dcbx_info), GFP_KERNEL);
 +	dcbx_info = kzalloc(sizeof(*dcbx_info), GFP_KERNEL);
- 	if (!dcbx_info) {
- 		DP_ERR(hwfn->cdev, "Failed to allocate memory for dcbx_info\n");
+ 	if (!dcbx_info)
  		return NULL;
- 	}
  
  	if (qed_dcbx_query_params(hwfn, dcbx_info, type)) {
  		kfree(dcbx_info);
