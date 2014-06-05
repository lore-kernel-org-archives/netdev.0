From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: systemport: start with carrier off
Date: Thu,  5 Jun 2014 10:22:18 -0700
Message-ID: <1401988938-25940-5-git-send-email-f.fainelli@gmail.com>
References: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:35761 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbaFERWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:22:42 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so1403085pbb.13
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:22:42 -0700 (PDT)
In-Reply-To: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SYSTEMPORT driver uses libphy to determine the carrier state, so
make sure we start with a carrier off until libphy has completed the
link training process.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 54b51db0caf3..141160ef249a 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1595,6 +1595,9 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	 */
 	dev->flags &= ~IFF_MULTICAST;
 
+	/* libphy will adjust the link state accordingly */
+	netif_carrier_off(dev);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register net_device\n");
-- 
1.9.1
