From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] caif: move the dereference below the NULL test
Date: Mon, 10 Sep 2012 12:38:27 +0800
Message-ID: <CAPgLHd-MBQnrU9tS0VFw-O7yvs47r3waHqGm1SRS4GA72Pn1hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43527 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab2IJEi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 00:38:28 -0400
Received: by qaas11 with SMTP id s11so679168qaa.19
        for <netdev@vger.kernel.org>; Sun, 09 Sep 2012 21:38:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The dereference should be moved below the NULL test.

spatch with a semantic match is used to found this.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/caif/cfsrvl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index dd485f6..ba217e9 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -211,9 +211,10 @@ void caif_client_register_refcnt(struct cflayer *adapt_layer,
 					void (*put)(struct cflayer *lyr))
 {
 	struct cfsrvl *service;
-	service = container_of(adapt_layer->dn, struct cfsrvl, layer);
 
-	WARN_ON(adapt_layer == NULL || adapt_layer->dn == NULL);
+	if (WARN_ON(adapt_layer == NULL || adapt_layer->dn == NULL))
+		return;
+	service = container_of(adapt_layer->dn, struct cfsrvl, layer);
 	service->hold = hold;
 	service->put = put;
 }
