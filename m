From: =?UTF-8?q?C=C3=A9dric=20Le=20Goater?= <clg@kaod.org>
Subject: [PATCH] net/ncsi: fix checksum validation in response packet
Date: Fri, 14 Apr 2017 10:56:37 +0200
Message-ID: <1492160197-13816-1-git-send-email-clg@kaod.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Joel Stanley <joel@jms.id.au>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?C=C3=A9dric=20Le=20Goater?= <clg@kaod.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.mo178.mail-out.ovh.net ([46.105.39.61]:40792 "EHLO
        2.mo178.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdDNLXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 07:23:36 -0400
Received: from player715.ha.ovh.net (b9.ovh.net [213.186.33.59])
        by mo178.mail-out.ovh.net (Postfix) with ESMTP id 0BFF531896
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:56:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

htonl was used instead of ntohl. Surely a typo.

Signed-off-by: Cédric Le Goater <clg@kaod.org>
---
 net/ncsi/ncsi-rsp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 087db775b3dc..d375286b79f2 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -52,7 +52,7 @@ static int ncsi_validate_rsp_pkt(struct ncsi_request *nr,
 
 	checksum = ncsi_calculate_checksum((unsigned char *)h,
 					   sizeof(*h) + payload - 4);
-	if (*pchecksum != htonl(checksum))
+	if (*pchecksum != ntohl(checksum))
 		return -EINVAL;
 
 	return 0;
-- 
2.7.4
