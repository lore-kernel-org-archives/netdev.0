From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: comment rx_handler results
Date: Sat, 5 Mar 2011 16:13:32 +0100
Message-ID: <20110305151331.GE8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-8-git-send-email-jpirko@redhat.com>
 <1299329330.4277.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460Ab1CEPOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 10:14:11 -0500
Content-Disposition: inline
In-Reply-To: <1299329330.4277.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 48a9638..26e03f9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -391,10 +391,14 @@ enum gro_result {
 typedef enum gro_result gro_result_t;
 
 enum rx_handler_result {
-	RX_HANDLER_CONSUMED,
-	RX_HANDLER_ANOTHER,
-	RX_HANDLER_EXACT,
-	RX_HANDLER_PASS,
+	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
+				   do not process it further. */
+	RX_HANDLER_ANOTHER,	/* Do another round in receive path.
+				   This is indicated in case skb->dev
+				   was changed by rx_handler */
+	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
+	RX_HANDLER_PASS,	/* Do nothing, pass the skb as if
+				   no rx_handler was called */
 };
 typedef enum rx_handler_result rx_handler_result_t;
 typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
-- 
1.7.4

