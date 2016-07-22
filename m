From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] i40e: Remove redundant memset
Date: Fri, 22 Jul 2016 00:36:36 -0700
Message-ID: <1469172999-8969-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amitoj Kaur Chawla <amitoj1606@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37308 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357AbcGVHgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:49 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Remove redundant call to memset before a call to memcpy.

The Coccinelle semantic patch used to make this change is as follows:
@@
expression e1,e2,e3,e4;
@@

- memset(e1,e2,e3);
  memcpy(e1,e4,e3);

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2351a08..753c3b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7916,7 +7916,6 @@ static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
 	u8 *rss_lut;
 	int ret, i;
 
-	memset(&rss_key, 0, sizeof(rss_key));
 	memcpy(&rss_key, seed, sizeof(rss_key));
 
 	rss_lut = kzalloc(pf->rss_table_size, GFP_KERNEL);
-- 
2.5.5
