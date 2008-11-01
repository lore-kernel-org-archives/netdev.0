From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net: add documentation for skb recycling
Date: Sat, 1 Nov 2008 03:59:29 +0100
Message-ID: <20081101025929.GA13377@xi.wantstofly.org>
References: <20081020190654.49d4e5d2@extreme> <20081021031732.GO4129@xi.wantstofly.org> <20081026.230500.268424963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, rdunlap@xenotime.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42638 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbYKADWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 23:22:33 -0400
Content-Disposition: inline
In-Reply-To: <20081026.230500.268424963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2008 at 11:05:00PM -0700, David Miller wrote:

> > How about tweaking this slightly and saying:
> > 
> >  * 	Checks that the skb passed in is not shared or cloned, and
> >  *	that it is linear and its head portion at least as large as
> >  *	skb_size so that it can be recycled as a receive buffer.
> >  * 	If these conditions are met, this function does any necessary
> >  *	reference count dropping and cleans up the skbuff as if it
> >  *	just came from __alloc_skb().
> 
> I like this tweak, someone please send me the final version with
> proper signoffs etc.

How about this:



From: Stephen Hemminger <shemminger@vyatta.com>
Subject: net: add documentation for skb recycling

Commit 04a4bb55bcf35b63d40fd2725e58599ff8310dd7 ("net: add
skb_recycle_check() to enable netdriver skb recycling") added a
method for network drivers to recycle skbuffs, but while use of
this mechanism was documented in the commit message, it should
really have been added as a docbook comment as well -- this
patch does that.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4e22e3a..ebb6b94 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -449,6 +449,18 @@ void kfree_skb(struct sk_buff *skb)
 	__kfree_skb(skb);
 }
 
+/**
+ *	skb_recycle_check - check if skb can be reused for receive
+ *	@skb: buffer
+ *	@skb_size: minimum receive buffer size
+ *
+ *	Checks that the skb passed in is not shared or cloned, and
+ *	that it is linear and its head portion at least as large as
+ *	skb_size so that it can be recycled as a receive buffer.
+ *	If these conditions are met, this function does any necessary
+ *	reference count dropping and cleans up the skbuff as if it
+ *	just came from __alloc_skb().
+ */
 int skb_recycle_check(struct sk_buff *skb, int skb_size)
 {
 	struct skb_shared_info *shinfo;
