From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] tap: Mark devices of type "tun" as IFF_DONT_BRIDGE
Date: Wed,  4 Jun 2014 14:06:08 -0400
Message-ID: <1401905168-21559-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbaFDSGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 14:06:13 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s54I6Dst009395
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 14:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tun devices are layer 3 devices and do not work correctly
when bridged.  Mark then as IFF_DONT_BRIDGE so that people
trying to bridge will get an error.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/tun.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ee328ba..0161aa3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -931,6 +931,7 @@ static void tun_net_init(struct net_device *dev)
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+		dev->priv_flags |= IFF_DONT_BRIDGE;
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 
-- 
1.9.0
