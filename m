From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 1/2] irda: use GFP_KERNEL in irda_create()
Date: Fri,  5 Apr 2013 22:41:27 +0200
Message-ID: <1365194488-23462-2-git-send-email-minipli@googlemail.com>
References: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:34149 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162658Ab3DEUlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 16:41:49 -0400
Received: by mail-bk0-f42.google.com with SMTP id jc3so2280033bkc.15
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 13:41:48 -0700 (PDT)
In-Reply-To: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irda_create() is called from user context only, therefore has no need
for GFP_ATOMIC.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/irda/af_irda.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index d28e7f0..2846cf5 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1120,7 +1120,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
 	}
 
 	/* Allocate networking socket */
-	sk = sk_alloc(net, PF_IRDA, GFP_ATOMIC, &irda_proto);
+	sk = sk_alloc(net, PF_IRDA, GFP_KERNEL, &irda_proto);
 	if (sk == NULL)
 		return -ENOMEM;
 
-- 
1.7.10.4
