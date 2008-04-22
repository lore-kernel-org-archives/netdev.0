From: David Miller <davem@davemloft.net>
Subject: Re: [6/6] [VIRTIO] net: Allow receiving SG packets
Date: Mon, 21 Apr 2008 19:55:21 -0700 (PDT)
Message-ID: <20080421.195521.71448202.davem@davemloft.net>
References: <200804220506.16887.rusty@rustcorp.com.au>
	<20080421.130418.01258045.davem@davemloft.net>
	<200804221250.27909.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754256AbYDVCzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 22:55:19 -0400
In-Reply-To: <200804221250.27909.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 22 Apr 2008 12:50:27 +1000

> But I was curious as to why the +2 in the MAX_SKB_FRAGS definition?

To be honest I have no idea.

When Alexey added the TSO changeset way back then, it had the
"+2", from the history-2.6 tree:

commit 80223d5186f73bf42a7e260c66c9cb9f7d8ec9cf
Author: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date:   Wed Aug 28 11:52:03 2002 -0700

    [NET]: Add TCP segmentation offload core infrastructure.

 ...
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a812681..9b6e6ad 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -109,7 +109,8 @@ struct sk_buff_head {
 
 struct sk_buff;
 
-#define MAX_SKB_FRAGS 6
+/* To allow 64K frame to be packed as single skb without frag_list */
+#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
 
 typedef struct skb_frag_struct skb_frag_t;
 
