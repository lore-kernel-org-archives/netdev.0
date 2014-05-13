From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net v1] af_iucv: wrong mapping of sent and confirmed skbs
Date: Tue, 13 May 2014 14:38:02 +0200
Message-ID: <20140513123802.GA60198@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <ursula.braun@de.ibm.com>

When sending data through IUCV a MESSAGE COMPLETE interrupt
signals that sent data memory can be freed or reused again.
With commit f9c41a62bba3f3f7ef3541b2a025e3371bcbba97
"af_iucv: fix recvmsg by replacing skb_pull() function" the
MESSAGE COMPLETE callback iucv_callback_txdone() identifies
the wrong skb as being confirmed, which leads to data corruption.
This patch fixes the skb mapping logic in iucv_callback_txdone().

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Cc: <stable@vger.kernel.org>
---
 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1830,7 +1830,7 @@ static void iucv_callback_txdone(struct
 		spin_lock_irqsave(&list->lock, flags);
 
 		while (list_skb != (struct sk_buff *)list) {
-			if (msg->tag != IUCV_SKB_CB(list_skb)->tag) {
+			if (msg->tag == IUCV_SKB_CB(list_skb)->tag) {
 				this = list_skb;
 				break;
 			}
