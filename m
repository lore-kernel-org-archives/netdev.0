From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/8] netpoll: Add netpoll_tx_running
Date: Fri, 11 Jun 2010 12:12:49 +1000
Message-ID: <E1OMtjl-0006PB-9z@gondolin.me.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38030 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760084Ab0FKCMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 22:12:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Add netpoll_tx_running

This patch adds the helper netpoll_tx_running for use within
ndo_start_xmit.  It returns non-zero if ndo_start_xmit is being
invoked by netpoll, and zero otherwise.

This is currently implemented by simply looking at the hardirq
count.  This is because for all non-netpoll uses of ndo_start_xmit,
IRQs must be enabled while netpoll always disables IRQs before
calling ndo_start_xmit.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netpoll.h |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f3ad74a..4c77fe7 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -116,6 +116,11 @@ static inline void netpoll_poll_unlock(void *have)
 	}
 }
 
+static inline int netpoll_tx_running(struct net_device *dev)
+{
+	return irqs_disabled();
+}
+
 #else
 static inline int netpoll_rx(struct sk_buff *skb)
 {
@@ -139,6 +144,10 @@ static inline void netpoll_poll_unlock(void *have)
 static inline void netpoll_netdev_init(struct net_device *dev)
 {
 }
+static inline int netpoll_tx_running(struct net_device *dev)
+{
+	return 0;
+}
 #endif
 
 #endif
