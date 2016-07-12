From: weiyj_lk@163.com
Subject: [PATCH -next] ixgbe: Add missing destroy_workqueue() on error in ixgbe_init_module()
Date: Tue, 12 Jul 2016 15:17:02 +0000
Message-ID: <1468336622-10538-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:45436 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbcGLPRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 11:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing destroy_workqueue() before return from
ixgbe_init_module() in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ef82cf9..c5c3d68 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -10109,6 +10109,7 @@ static int __init ixgbe_init_module(void)
 
 	ret = pci_register_driver(&ixgbe_driver);
 	if (ret) {
+		destroy_workqueue(ixgbe_wq);
 		ixgbe_dbg_exit();
 		return ret;
 	}
