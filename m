From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 2/2] [IrDA] Incorrect TTP header reservation
Date: Thu, 7 Dec 2006 02:51:17 +0200
Message-ID: <20061207005117.GB21131@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeetlinux@yahoo.co.in, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.19]:20926 "EHLO
	smtp-msa-out19.orange.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S937865AbWLGAvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:51:20 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must reserve SAR + MAX_HEADER bytes for IrLMP to fit in.

Patch from Jeet Chaudhuri <jeetlinux@yahoo.co.in>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/irttp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 252f110..03504f3 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1100,7 +1100,7 @@ int irttp_connect_request(struct tsap_cb
 			return -ENOMEM;
 
 		/* Reserve space for MUX_CONTROL and LAP header */
-		skb_reserve(tx_skb, TTP_MAX_HEADER);
+		skb_reserve(tx_skb, TTP_MAX_HEADER + TTP_SAR_HEADER);
 	} else {
 		tx_skb = userdata;
 		/*
@@ -1349,7 +1349,7 @@ int irttp_connect_response(struct tsap_c
 			return -ENOMEM;
 
 		/* Reserve space for MUX_CONTROL and LAP header */
-		skb_reserve(tx_skb, TTP_MAX_HEADER);
+		skb_reserve(tx_skb, TTP_MAX_HEADER + TTP_SAR_HEADER);
 	} else {
 		tx_skb = userdata;
 		/*
-- 
1.4.2.3

