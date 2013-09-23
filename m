From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] i40e: fix error return code in i40e_probe()
Date: Mon, 23 Sep 2013 10:47:55 +0800
Message-ID: <CAPgLHd8qwuJ4ry-DVExF7mv83FBqYts_7wMO8xikdeL+3e+yUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:58684 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab3IWCr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 22:47:57 -0400
Received: by mail-bk0-f51.google.com with SMTP id mx10so986139bkb.10
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 19:47:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -ENOMEM in the memory alloc error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 601d482..117e014 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7060,8 +7060,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	len = sizeof(struct i40e_vsi *) * pf->hw.func_caps.num_vsis;
 	pf->vsi = kzalloc(len, GFP_KERNEL);
-	if (!pf->vsi)
+	if (!pf->vsi) {
+		err = -ENOMEM;
 		goto err_switch_setup;
+	}
 
 	err = i40e_setup_pf_switch(pf);
 	if (err) {
