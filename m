From: weiyj_lk@163.com
Subject: [PATCH] rocker: fix error return code in rocker_probe()
Date: Thu, 16 Apr 2015 20:21:02 +0800
Message-ID: <1429186862-20989-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:60560 "EHLO m12-16.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbbDPM10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 08:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -EINVAL from the invalid PCI region size error
handling case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/rocker/rocker.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 5cecec2..0cc17f5 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4293,6 +4293,7 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	if (pci_resource_len(pdev, 0) < ROCKER_PCI_BAR0_SIZE) {
 		dev_err(&pdev->dev, "invalid PCI region size\n");
+		err = -EINVAL;
 		goto err_pci_resource_len_check;
 	}
 
