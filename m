From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 02:56:59 -0700 (PDT)
Message-ID: <20090616.025659.224075454.davem@davemloft.net>
References: <20090616.021955.243374916.davem@davemloft.net>
	<20090616104417.657d6682@lxorguk.ukuu.org.uk>
	<20090616094813.GA1686@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbZFPJ44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:56:56 -0400
In-Reply-To: <20090616094813.GA1686@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 16 Jun 2009 11:48:13 +0200

> I think David's larger point was that what looked to me like more 
> widespread breakage was in fact limited to [a]x25, a comparatively 
> rarely used (and rarely tested) corner of the kernel.
> 
> I turned them off and that solved the problems here. (and i suspect 
> the real fix wont be far away either) Thanks everyone.

This code path has been broken, basically, forever.  It does a
lock_sock() from a timer, which has that might_sleep() check, and
essentially always has.

It would have warned this way years ago if someone had triggered it.

The code has been this way forever, so something else changed to start
triggering this on you.

I still am curious what in the world opens those sockets for you,
nothing normal should be doing so.

Can you satisfy my curiosity by turning X25 back on and booting
with this patch?  Thanks.

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index ed80af8..5214a38 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -494,6 +494,10 @@ static int x25_create(struct net *net, struct socket *sock, int protocol)
 	struct x25_sock *x25;
 	int rc = -ESOCKTNOSUPPORT;
 
+#if 1
+	printk(KERN_INFO "[%s:%d]: Creates X25 socket.\n",
+	       current->comm, current->pid);
+#endif
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
 
