From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v2 1/2] 8139too in linux-3.18.0: Fix the lack of pci_disable_device
Date: Sun, 21 Dec 2014 15:36:43 +0800
Message-ID: <5496788B.2030105@163.com>
References: <000001d01c5f$650f3270$2f2d9750$@163.com> <54958534.7070202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shangh@realtek.com.tw,
	bjj13@mails.tsinghua.edu.cn
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:44634 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbaLUHhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 02:37:01 -0500
In-Reply-To: <54958534.7070202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pci_request_regions is failed in rtl8139_init_board, 
pci_disable_device is not called to disable the device which are enabled 
by pci_enable_device, because disable_dev_on_err is not assigned 1.
This patch fix this problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
drivers/net/ethernet/realtek/8139too.c | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c 
b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..49bbcf3 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -783,10 +783,10 @@ static struct net_device 
*rtl8139_init_board(struct pci_dev *pdev)
if (rc)
goto err_out;

+ disable_dev_on_err = 1;
rc = pci_request_regions (pdev, DRV_NAME);
if (rc)
goto err_out;
- disable_dev_on_err = 1;

pci_set_master (pdev);
