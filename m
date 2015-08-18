From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 894/905]
 drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13: sparse: incorrect type
 in assignment (different address spaces)
Date: Mon, 17 Aug 2015 21:25:31 -0700 (PDT)
Message-ID: <20150817.212531.304390415873448459.davem@davemloft.net>
References: <201508180929.kFax186R%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, kbuild-all@01.org, nalreddy@cisco.com,
	netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbHREZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 00:25:32 -0400
In-Reply-To: <201508180929.kFax186R%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Tue, 18 Aug 2015 09:07:32 +0800

> sparse warnings: (new ones prefixed by >>)
> 
>>> drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13: sparse: incorrect type in assignment (different address spaces)
>    drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    expected void *res
>    drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    got void [noderef] <asn:2>*
> 

Thanks, I've committed the following:

====================
[PATCH] enic: Fix sparse warning in vnic_devcmd_init().

>> drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13: sparse: incorrect type in assignment (different address spaces)
   drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    expected void *res
   drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    got void [noderef] <asn:2>*

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index ff2da7e..9f6c641 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -1089,8 +1089,8 @@ EXPORT_SYMBOL(vnic_dev_get_pdev);
 
 int vnic_devcmd_init(struct vnic_dev *vdev)
 {
+	void __iomem *res;
 	int err;
-	void *res;
 
 	res = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD2, 0);
 	if (res) {
-- 
2.1.0
