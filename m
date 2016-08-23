From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: bcm_sf2: Remove redundant dev_err call in bcm_sf2_sw_probe()
Date: Tue, 23 Aug 2016 15:09:03 +0000
Message-ID: <1471964943-742-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35879 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752642AbcHWPXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:23:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so8447419pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:23:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/bcm_sf2.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8e6fe13..3952302 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1643,10 +1643,8 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
 		r = platform_get_resource(pdev, IORESOURCE_MEM, i);
 		*base = devm_ioremap_resource(&pdev->dev, r);
-		if (IS_ERR(*base)) {
-			pr_err("unable to find register: %s\n", reg_names[i]);
+		if (IS_ERR(*base))
 			return PTR_ERR(*base);
-		}
 		base++;
 	}
