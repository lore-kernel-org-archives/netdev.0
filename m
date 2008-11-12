From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: ifdef struct sock::sk_async_wait_queue
Date: Wed, 12 Nov 2008 15:13:08 +0300
Message-ID: <20081112121308.GA4759@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@netdev.vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:14285 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbYKLMJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:09:40 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1021833ugf.37
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 04:09:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every user is under CONFIG_NET_DMA already, so ifdef field as well.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/sock.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -239,7 +239,9 @@ struct sock {
 	int			sk_sndbuf;
 	struct sk_buff_head	sk_receive_queue;
 	struct sk_buff_head	sk_write_queue;
+#ifdef CONFIG_NET_DMA
 	struct sk_buff_head	sk_async_wait_queue;
+#endif
 	int			sk_wmem_queued;
 	int			sk_forward_alloc;
 	gfp_t			sk_allocation;
