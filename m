From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in driver initialization
Date: Sun, 25 May 2014 00:24:46 +0530
Message-ID: <5380EAF6.1090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: steve.glendinning@shawell.net, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:47048 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaEXSyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 14:54:50 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so5688685pbc.37
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 11:54:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As smsc driver supports carrier detection, it should unset NOCARRIER
flag only after carrier state determination. By default that flag
is off so driver should set it before starting auto-negotiation

Signed-off-by: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index a0fc151..69016a5 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2525,6 +2525,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
 
+	netif_carrier_off(dev);
+
 	return 0;
 
 out_unregister_netdev_5:
-- 
1.8.3.2
