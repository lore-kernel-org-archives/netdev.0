From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 14:15:11 -0800
Message-ID: <20081125141511.5eedb12a@infradead.org>
References: <1227631323.3109.7.camel@achroite>
	<20081125095432.04d73b01@infradead.org>
	<1227636139.3109.11.camel@achroite>
	<20081125.135434.164058659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34137 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbYKYWOQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 17:14:16 -0500
In-Reply-To: <20081125.135434.164058659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008 13:54:34 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > I think there may be some value in them: users who want to help
> > debug this can experiment to see which configurations or traffic
> > types do or don't result in invalid truesize.
> 
> Agreed, netlimit'ing this is the best way to go.

ok

>From 84515e1255c0ec2437cb62cd59de6ed9d6465fa1 Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Tue, 25 Nov 2008 08:30:04 -0800
Subject: [PATCH] net: make skb_truesize_bug() call WARN()

The truesize message check is important enough to make it print "BUG" to the
user console... lets also make it important enough to spit a backtrace/module list
etc so that kerneloops.org can track them.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 391be91..a939215 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -149,7 +149,7 @@ void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 
 void skb_truesize_bug(struct sk_buff *skb)
 {
-	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
+	WARN(net_ratelimit(), KERN_ERR "SKB BUG: Invalid truesize (%u) "
 	       "len=%u, sizeof(sk_buff)=%Zd\n",
 	       skb->truesize, skb->len, sizeof(struct sk_buff));
 }
-- 
1.6.0.3



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
