From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 11/24] drivers/ptp/ptp_pch: Convert to module_pci_driver
Date: Mon, 27 May 2013 10:29:03 +0800
Message-ID: <1369621743-7732-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>,
	<gregkh@linuxfoundation.org>
To: <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use module_pci_driver instead of init/exit, make code clean

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/ptp/ptp_pch.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index bea9451..e63ca00 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -705,23 +705,7 @@ static struct pci_driver pch_driver = {
 	.resume = pch_resume,
 };
 
-static void __exit ptp_pch_exit(void)
-{
-	pci_unregister_driver(&pch_driver);
-}
-
-static s32 __init ptp_pch_init(void)
-{
-	s32 ret;
-
-	/* register the driver with the pci core */
-	ret = pci_register_driver(&pch_driver);
-
-	return ret;
-}
-
-module_init(ptp_pch_init);
-module_exit(ptp_pch_exit);
+module_pci_driver(pch_driver);
 
 module_param_string(station,
 		    pch_param.station, sizeof(pch_param.station), 0444);
-- 
1.7.1
