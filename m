From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] virtio: simplify the using of received in virtnet_poll
Date: Thu, 26 Mar 2015 15:39:45 +0800
Message-ID: <1427355585-10365-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51596 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbCZHjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:39:47 -0400
Received: from localhost (lirq-optiplex-780.corp.ad.wrs.com [128.224.162.139])
	by mail.windriver.com (8.14.9/8.14.5) with ESMTP id t2Q7dkAC011717
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 00:39:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

received is 0, no need to minus it and use "+=" to reassign it

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 59b0e97..cb54ff7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -749,9 +749,9 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct receive_queue *rq =
 		container_of(napi, struct receive_queue, napi);
-	unsigned int r, received = 0;
+	unsigned int r, received;
 
-	received += virtnet_receive(rq, budget - received);
+	received = virtnet_receive(rq, budget);
 
 	/* Out of packets? */
 	if (received < budget) {
-- 
2.1.0
