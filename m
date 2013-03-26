From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/3] net: ethernet: atheros: add CONFIG_PM_SLEEP to
 suspend/resume functions
Date: Tue, 26 Mar 2013 16:03:25 +0900
Message-ID: <001c01ce29f0$02ccd030$08667090$%han@samsung.com>
References: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:28939 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677Ab3CZHD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 03:03:28 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MK900EXVA9PS9O0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 26 Mar 2013 16:03:27 +0900 (KST)
In-reply-to: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CONFIG_PM_SLEEP to suspend/resume functions to fix the following
build warning when CONFIG_PM_SLEEP is not selected. This is because
sleep PM callbacks defined by SIMPLE_DEV_PM_OPS are only used when
the CONFIG_PM_SLEEP is enabled.

drivers/net/ethernet/atheros/atlx/atl1.c:2861:12: warning: 'atl1_resume' defined but not used [-Wunused-function]

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 5b0d993..9948fee 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2774,7 +2774,7 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int atl1_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
-- 
1.7.2.5
