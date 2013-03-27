From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] igb: fix error return code in igb_sysfs_init()
Date: Wed, 27 Mar 2013 22:18:58 +0800
Message-ID: <CAPgLHd91Yf2-q1Vh+aTSZ2phqFQC6wbh-ixO6Yh6qu9qsCqnHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	stephen@networkplumber.org, akeem.g.abodunrin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57485 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab3C0OS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:18:59 -0400
Received: by mail-bk0-f46.google.com with SMTP id je9so1799803bkc.5
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 07:18:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/igb/igb_hwmon.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 0478a1a..3b750b2 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -208,6 +208,7 @@ int igb_sysfs_init(struct igb_adapter *adapter)
 	if (client == NULL) {
 		dev_info(&adapter->pdev->dev,
 			"Failed to create new i2c device..\n");
+		rc = -ENOMEM;
 		goto exit;
 	}
 	adapter->i2c_client = client;
