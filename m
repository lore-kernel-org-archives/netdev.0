From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Fix mglist corruption that leads to memory corruption
Date: Sat, 12 Feb 2011 09:42:07 +1100
Message-ID: <20110211224207.GA5715@gondor.apana.org.au>
References: <20110211223655.GA5585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ihands@redhat.com, jbacik@redhat.com
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60414 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758305Ab1BKWmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 17:42:09 -0500
Content-Disposition: inline
In-Reply-To: <20110211223655.GA5585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This patch fixes a typo that is not too serious.

bridge: Fix timer typo that may render snooping less effective

In a couple of spots where we are supposed to modify the port
group timer (p->timer) we instead modify the bridge interface
group timer (mp->timer).

The effect of this is mostly harmless.  However, it can cause
port subscriptions to be longer than they should be, thus making
snooping less effective.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f701a21..802d3f8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1177,7 +1178,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
-			mod_timer(&mp->timer, now + max_delay);
+			mod_timer(&p->timer, now + max_delay);
 	}
 
 out:
@@ -1248,7 +1249,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
-			mod_timer(&mp->timer, now + max_delay);
+			mod_timer(&p->timer, now + max_delay);
 	}
 
 out:

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
