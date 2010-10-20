From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.36-rc7: net/bridge causes temporary network I/O lockups [2]
Date: Wed, 20 Oct 2010 14:16:31 +0800
Message-ID: <20101020061631.GA21679@gondor.apana.org.au>
References: <4CB9EBC3.4070905@freenet.de> <20101018161656.GA2403@gondor.apana.org.au> <4CBCB014.9080108@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Patrick Ringl <patrick_@freenet.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CBCB014.9080108@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 18, 2010 at 10:37:40PM +0200, Patrick Ringl wrote:
>
> Anything else I could possibly provide? :-)

Yes, testing :)

First of all I'd like to rule out (or in) the IPv6 query code,
which is clearly generating a bogus packet (wrong payload_len).

So can you apply this patch and see if it makes the problem
go away? Please take packet dumps so we know that the IPv6 query
is no longer being sent.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index eb5b256..66f39d7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -832,11 +832,6 @@ static void br_multicast_send_query(struct net_bridge *br,
 	br_group.proto = htons(ETH_P_IP);
 	__br_multicast_send_query(br, port, &br_group);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	br_group.proto = htons(ETH_P_IPV6);
-	__br_multicast_send_query(br, port, &br_group);
-#endif
-
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
