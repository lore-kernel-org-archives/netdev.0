From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] fix net-core kernel-doc
Date: Thu, 22 Jun 2006 15:14:43 -0700
Message-ID: <20060622151443.24dd8d9e.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:57565 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1030426AbWFVWWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 18:22:25 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 15:22:19 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Warning(/var/linsrc/linux-2617-g4//include/linux/skbuff.h:304): No description found for parameter 'dma_cookie'
Warning(/var/linsrc/linux-2617-g4//include/net/sock.h:1274): No description found for parameter 'copied_early'
Warning(/var/linsrc/linux-2617-g4//net/core/dev.c:3309): No description found for parameter 'chan'
Warning(/var/linsrc/linux-2617-g4//net/core/dev.c:3309): No description found for parameter 'event'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/linux/skbuff.h |    2 ++
 include/net/sock.h     |    1 +
 net/core/dev.c         |    4 ++--
 3 files changed, 5 insertions(+), 2 deletions(-)

--- linux-2617-g4.orig/include/linux/skbuff.h
+++ linux-2617-g4/include/linux/skbuff.h
@@ -209,6 +209,8 @@ enum {
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
+ *	@dma_cookie: a cookie to one of several possible DMA operations
+ *		done by skb DMA functions
  *	@secmark: security marking
  */
 
--- linux-2617-g4.orig/include/net/sock.h
+++ linux-2617-g4/include/net/sock.h
@@ -1265,6 +1265,7 @@ sock_recv_timestamp(struct msghdr *msg, 
  * sk_eat_skb - Release a skb if it is no longer needed
  * @sk: socket to eat this skb from
  * @skb: socket buffer to eat
+ * @copied_early: flag indicating whether DMA operations copied this data early
  *
  * This routine must be called with interrupts disabled or with the socket
  * locked so that the sk_buff queue operation is ok.
--- linux-2617-g4.orig/net/core/dev.c
+++ linux-2617-g4/net/core/dev.c
@@ -3301,8 +3301,8 @@ static void net_dma_rebalance(void)
 /**
  * netdev_dma_event - event callback for the net_dma_client
  * @client: should always be net_dma_client
- * @chan:
- * @event:
+ * @chan: DMA channel for the event
+ * @event: event type
  */
 static void netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
 	enum dma_event event)


---
