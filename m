From: Dave Jones <davej@redhat.com>
Subject: Re: ip_rt_bug questions.
Date: Sat, 21 May 2011 13:16:42 -0400
Message-ID: <20110521171642.GA18411@redhat.com>
References: <20110418214809.GA17443@redhat.com>
 <20110418.144909.52209035.davem@davemloft.net>
 <20110418.145023.13728986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662Ab1EURQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 May 2011 13:16:48 -0400
Content-Disposition: inline
In-Reply-To: <20110418.145023.13728986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 02:50:23PM -0700, David Miller wrote:
 > From: David Miller <davem@davemloft.net>
 > Date: Mon, 18 Apr 2011 14:49:09 -0700 (PDT)
 > 
 > > From: Dave Jones <davej@redhat.com>
 > > Date: Mon, 18 Apr 2011 17:48:10 -0400
 > > 
 > >> I managed to trigger this today..
 > >> 
 > >> ip_rt_bug: 0.0.0.0 -> 255.255.255.255, ?
 > >> 
 > >> if this is useful in some way, maybe it should be enhanced
 > >> to print out something else, like a backtrace ?
 > >> 
 > >> Also, should it be a printk_ratelimit() ? Or is there
 > >> ratelimiting done elsewhere in the routing code ?
 > >> 
 > >> or should it just be silenced, leaving just the kfree_skb ?
 > > 
 > > It's a very serious issue, it means we used an input route for
 > > packet output.
 > > 
 > > Kernel version and what you were doing to trigger this?
 > 
 > BTW, if you could modify this thing to spit out a stack
 > trace (probably by using WARN_ON() or similar) that will
 > probably show us where the bug is coming from.

I haven't been able to hit this again since I added the WARN_ON.
But you can guarantee that the next time I see it it will be on
a kernel where I forgot to re-add this.  Could we get this merged
so I don't have to keep remembering it ?

	Dave

Add a stack backtrace to the ip_rt_bug path for debugging

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 99e6e4b..6fb18b7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1687,6 +1687,7 @@ static int ip_rt_bug(struct sk_buff *skb)
 		&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
 		skb->dev ? skb->dev->name : "?");
 	kfree_skb(skb);
+	WARN_ON(1);
 	return 0;
 }
 


