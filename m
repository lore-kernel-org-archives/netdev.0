From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] skbuff: skb_mac_header_was_set is always true on >32 bit
Date: Wed, 17 Jun 2009 08:23:27 -0700
Message-ID: <20090617082327.196eda07@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38568 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbZFQPXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 11:23:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at the crash in log_martians(), one suspect is that the check for
mac header being set is not correct.  The value of mac_header defaults to
0 on allocation, therefore skb_mac_header_was_set will always be true on
platforms using NET_SKBUFF_USES_OFFSET.

Arnaldo, is this correct?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/skbuff.c	2009-06-17 08:16:46.235188728 -0700
+++ b/net/core/skbuff.c	2009-06-17 08:17:25.810314332 -0700
@@ -201,6 +201,10 @@ struct sk_buff *__alloc_skb(unsigned int
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header = ~0U;
+#endif
+
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
