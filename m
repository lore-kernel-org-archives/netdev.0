From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH net-next 1/5] net, atm/ambassader: convert skb->tail into skb_tail_pointer(skb)
Date: Fri, 14 Jun 2013 17:58:31 +0900
Message-ID: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, Simon Horman <horms@verge.net.au>,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:39004 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab3FNI6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 04:58:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change set of 27a884dc, "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
converted skb->tail from pointer into sk_buff_data_t. It missed skb->tail
in drivers/atm/ambassador.c.
This patch converts skb->tail into skb_tail_pointer(skb).

Found by inspection. Compile tested only.

Cc: Simon Horman <horms@verge.net.au>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/atm/ambassador.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 77a7480..62a7607 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -1403,7 +1403,7 @@ static void amb_free_rx_skb (struct atm_vcc * atm_vcc, struct sk_buff * skb) {
   rx.host_address = cpu_to_be32 (virt_to_bus (skb->data));
   
   skb->data = skb->head;
-  skb->tail = skb->head;
+  skb_reset_tail_pointer(skb);
   skb->len = 0;
   
   if (!rx_give (dev, &rx, pool)) {
-- 
1.7.10.4
