From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH v2] net: driver: smsc: set NOCARRIER flag in dev at driver
 initialization
Date: Tue, 03 Jun 2014 22:13:48 +0530
Message-ID: <538DFB44.6060902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:65038 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965011AbaFCQny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 12:43:54 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so4914655pdj.29
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 09:43:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As smsc driver supports carrier detection, it should unset NOCARRIER
flag only after carrier state determination. By default that flag
is off so driver should set it before starting auto-negotiation

Signed-off-by: Balakumaran <Balakumaran.Kannan@ap.sony.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index a0fc151..5e13fa5 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2477,6 +2477,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 		goto out_disable_resources;
 	}
 
+	netif_carrier_off(dev);
+
 	retval = register_netdev(dev);
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error %i registering device", retval);
-- 
1.8.2.1
