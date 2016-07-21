From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v2] net/faraday: Disallow using reversed MAC address from hardware
Date: Thu, 21 Jul 2016 11:42:54 +1000
Message-ID: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org,
	David.Laight@ACULAB.COM, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55745 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbcGUBnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:43:01 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6L1ckQo056119
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 21:43:01 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24aenv2v4k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 21:43:00 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 21 Jul 2016 11:42:58 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C0D822BB0045
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:42:56 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6L1guvj16580636
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:42:56 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6L1gtIs007168
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:42:56 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initial MAC address is retrieved from hardware if it's not
provided by device-tree. The reserved MAC address from hardware
will be used if non-reserved MAC address is invalid. It will
cause mismatched MAC address seen by hardware and software.

This disallows using the reserved hardware MAC address to avoid
the mismatched MAC address seen by hardware and software.

Fixes: 113ce107afe9 ("net/faraday: Read MAC address from chip")
Suggested-by: David Laight <David.Laight@ACULAB.COM>
Suggested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
v2: Add "net-next" in the subject
---
 drivers/net/ethernet/faraday/ftgmac100.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2d4c7ea..36361f8 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -163,15 +163,6 @@ static void ftgmac100_setup_mac(struct ftgmac100 *priv)
 	mac[4] = (l >> 8) & 0xff;
 	mac[5] = l & 0xff;
 
-	if (!is_valid_ether_addr(mac)) {
-		mac[5] = (m >> 8) & 0xff;
-		mac[4] = m & 0xff;
-		mac[3] = (l >> 24) & 0xff;
-		mac[2] = (l >> 16) & 0xff;
-		mac[1] = (l >>  8) & 0xff;
-		mac[0] = l & 0xff;
-	}
-
 	if (is_valid_ether_addr(mac)) {
 		ether_addr_copy(priv->netdev->dev_addr, mac);
 		dev_info(priv->dev, "Read MAC address %pM from chip\n", mac);
-- 
2.1.0
