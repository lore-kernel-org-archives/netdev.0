From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 15:06:30 +0800
Message-ID: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <jiri@resnulli.us>, <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51080 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbENHGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 03:06:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we get a neighbour through looking up arp cache or creating a
new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
already taken. But we don't put the refcount again after it's used,
which make the neighbour entry leaked.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/net/ethernet/rocker/rocker.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1fc006b..7504540 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3053,6 +3053,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	else
 		neigh_event_send(n, NULL);
 
+	neigh_release(n);
 	return err;
 }
 
-- 
1.7.9.5
