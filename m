From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next]vhost: fix condition check for # of outstanding
 dma buffers
Date: Tue, 19 Jul 2011 11:37:58 -0700
Message-ID: <1311100678.8573.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:36535 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab1GSSiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 14:38:19 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6JI65Ug006736
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 14:06:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6JIcHhx115280
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 14:38:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6JEc0Ir015598
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 11:38:05 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/vhost/net.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 70ac604..83cb738 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -189,8 +189,10 @@ static void handle_tx(struct vhost_net *net)
 				break;
 			}
 			/* If more outstanding DMAs, queue the work */
-			if (unlikely(vq->upend_idx - vq->done_idx >
-				     VHOST_MAX_PEND)) {
+			if (unlikely((vq->upend_idx - vq->done_idx >
+					VHOST_MAX_PEND) ||
+				     (vq->upend_idx - vq->done_idx >
+					 VHOST_MAX_PEND - UIO_MAXIOV))) {
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;


