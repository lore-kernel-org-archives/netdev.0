From: Alan <gnomes@lxorguk.ukuu.org.uk>
Subject: [PATCH] ppp_synctty: remove unneeded NULL check
Date: Wed, 08 Apr 2015 13:58:15 +0100
Message-ID: <20150408125807.30123.91282.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 251.110.2.81.in-addr.arpa ([81.2.110.251]:32914 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbDHM6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 08:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a random whine found by coverity. Had it been NULL it would have
showered us with oopses long before.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 0 files changed

diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index 925d3e2..b5592b8 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -549,7 +549,7 @@ ppp_sync_txmunge(struct syncppp *ap, struct sk_buff *skb)
 
 	ap->last_xmit = jiffies;
 
-	if (skb && ap->flags & SC_LOG_OUTPKT)
+	if (ap->flags & SC_LOG_OUTPKT)
 		ppp_print_buffer ("send buffer", skb->data, skb->len);
 
 	return skb;
