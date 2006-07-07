From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] remove CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
Date: Fri, 7 Jul 2006 11:10:08 +0200
Message-ID: <20060707091008.GB2543@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:33202 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1750978AbWGGJKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 05:10:12 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skbuff.h has an #ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB to allow
architectures to reimplement __dev_alloc_skb.  It's not set on any
architecture and now that we have an architecture-overrideable
NET_SKB_PAD there is not point at all to have one either.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-06 14:21:20.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-06 15:11:00.000000000 +0200
@@ -1066,7 +1066,6 @@
 		kfree_skb(skb);
 }
 
-#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
 /**
  *	__dev_alloc_skb - allocate an skbuff for sending
  *	@length: length to allocate
@@ -1087,9 +1086,6 @@
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
 }
-#else
-extern struct sk_buff *__dev_alloc_skb(unsigned int length, int gfp_mask);
-#endif
 
 /**
  *	dev_alloc_skb - allocate an skbuff for sending
