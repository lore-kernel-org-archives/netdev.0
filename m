From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 2/2] irda: use GFP_KERNEL in irda_connect_response()
Date: Fri,  5 Apr 2013 22:41:28 +0200
Message-ID: <1365194488-23462-3-git-send-email-minipli@googlemail.com>
References: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:44863 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162519Ab3DEUlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 16:41:50 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so2280559bkc.2
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 13:41:49 -0700 (PDT)
In-Reply-To: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only call site of irda_connect_response() is irda_accept() -- a
function called from user context only. Therefore it has no need for
GFP_ATOMIC.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/irda/af_irda.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 2846cf5..a7f6ef1 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -305,8 +305,7 @@ static void irda_connect_response(struct irda_sock *self)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
-			GFP_ATOMIC);
+	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER, GFP_KERNEL);
 	if (skb == NULL) {
 		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
 			   __func__);
-- 
1.7.10.4
