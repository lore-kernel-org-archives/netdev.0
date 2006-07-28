From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Fri, 28 Jul 2006 09:08:51 +0200
Message-ID: <20060728070851.GB25174@lst.de>
References: <20060726113136.GA403@lst.de> <20060726.152451.35043090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:44967 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751946AbWG1HJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 03:09:38 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060726.152451.35043090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 03:24:51PM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Wed, 26 Jul 2006 13:31:36 +0200
> 
> > + *	%NULL is returned in there is no free memory. Although this function
> > + *	allocates memory it can be called from an interrupt.
>  ...
> > + *	%NULL is returned in there is no free memory.
> 
> Looks like a typo in both cases, I think you mean
> "NULL is returned _if_ there" not "in there"

Yes, Joe Perches already pointed that out in private.  This typo is copy
and pasted from the dev_alloc_skb kerneldoc, so this patch fixes up all
four occurances:


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-28 09:06:55.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-28 09:07:35.000000000 +0200
@@ -1076,7 +1076,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory.
+ *	%NULL is returned if there is no free memory.
  */
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
@@ -1096,7 +1096,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory. Although this function
+ *	%NULL is returned if there is no free memory. Although this function
  *	allocates memory it can be called from an interrupt.
  */
 static inline struct sk_buff *dev_alloc_skb(unsigned int length)
@@ -1117,7 +1117,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory. Although this function
+ *	%NULL is returned if there is no free memory. Although this function
  *	allocates memory it can be called from an interrupt.
  */
 static inline struct sk_buff *netdev_alloc_skb(struct net_device *dev,
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-07-28 09:06:51.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-07-28 09:07:26.000000000 +0200
@@ -267,7 +267,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory.
+ *	%NULL is returned if there is no free memory.
  */
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
