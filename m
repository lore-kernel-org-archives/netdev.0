From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] qlcnic: add missing destroy_workqueue() on error path in qlcnic_probe()
Date: Tue, 8 Oct 2013 11:32:17 +0800
Message-ID: <CAPgLHd9oA08=1o_DWE0SGeg_7nokr3-WPEAOrG71bYg2C1676A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:41202 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab3JHDcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 23:32:19 -0400
Received: by mail-bk0-f53.google.com with SMTP id d7so2935603bkh.40
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 20:32:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing destroy_workqueue() before return from
qlcnic_probe() in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 21d00a0..f07f2b0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2257,7 +2257,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = qlcnic_alloc_adapter_resources(adapter);
 	if (err)
-		goto err_out_free_netdev;
+		goto err_out_free_wq;
 
 	adapter->dev_rst_time = jiffies;
 	adapter->ahw->revision_id = pdev->revision;
@@ -2396,6 +2396,9 @@ err_out_disable_msi:
 err_out_free_hw:
 	qlcnic_free_adapter_resources(adapter);
 
+err_out_free_wq:
+	destroy_workqueue(adapter->qlcnic_wq);
+
 err_out_free_netdev:
 	free_netdev(netdev);
 
