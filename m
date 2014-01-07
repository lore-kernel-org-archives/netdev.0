From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qlcnic: use vzalloc() instead of vmalloc()/memset(0)
Date: Tue, 7 Jan 2014 21:48:24 +0800
Message-ID: <CAPgLHd9kdVxAPmxcyZeRpJC7_s8HGyefA+CoYkhhz9pEM2xGKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:52825 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaAGNsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 08:48:25 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so234762bkz.41
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 05:48:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Use vzalloc() instead of vmalloc() and memset(0).

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index b529667..16912e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -935,11 +935,10 @@ static ssize_t qlcnic_sysfs_read_pci_config(struct file *file,
 		return QL_STATUS_INVALID_PARAM;
 
 	pci_info_sz = pci_func_count * sizeof(*pci_info);
-	pci_info = vmalloc(pci_info_sz);
+	pci_info = vzalloc(pci_info_sz);
 	if (!pci_info)
 		return -ENOMEM;
 
-	memset(pci_info, 0, pci_info_sz);
 	memset(buf, 0, pci_cfg_sz);
 	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
 
