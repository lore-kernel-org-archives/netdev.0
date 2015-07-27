From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] lwtunnel: use kfree_skb() instead of vanilla kfree()
Date: Mon, 27 Jul 2015 11:07:47 +0300
Message-ID: <20150727080747.GA2937@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30206 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbG0III (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:08:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree_skb() is correct here.

Fixes: ffce41962ef6 ('lwtunnel: support dst output redirect function')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index bb58826..5f7fae7 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -205,7 +205,7 @@ int __lwtunnel_output(struct sock *sk, struct sk_buff *skb,
 	return ret;
 
 drop:
-	kfree(skb);
+	kfree_skb(skb);
 
 	return ret;
 }
