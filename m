From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] pktgen: fix xmit test for BQL enabled devices
Date: Mon,  7 Apr 2014 17:18:30 +0200
Message-ID: <1396883910-3064-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbaDGPSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 11:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as in commit 8e2f1a63f221 ("packet: fix packet_direct_xmit
for BQL enabled drivers"), we test for __QUEUE_STATE_STACK_XOFF bit
in pktgen's xmit, which would not fully fill the device's TX ring for
BQL drivers that use netdev_tx_sent_queue(). Fix is to use, similarly
as we do in packet sockets, netif_xmit_frozen_or_drv_stopped() test.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/core/pktgen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d0dac57..d068ec2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3340,7 +3340,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	__netif_tx_lock_bh(txq);
 
-	if (unlikely(netif_xmit_frozen_or_stopped(txq))) {
+	if (unlikely(netif_xmit_frozen_or_drv_stopped(txq))) {
 		ret = NETDEV_TX_BUSY;
 		pkt_dev->last_ok = 0;
 		goto unlock;
-- 
1.7.11.7
