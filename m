From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops in 2.6.23-rc5
Date: Sun, 02 Sep 2007 12:19:55 +0800
Message-ID: <E1IRgwF-0004G0-00@gondolin.me.apana.org.au>
References: <alpine.DEB.0.999.0709012236460.6640@sheep.housecafe.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: lists@nerdbynature.de (Christian Kujau)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932819AbXIBEUT@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.999.0709012236460.6640@sheep.housecafe.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Kujau <lists@nerdbynature.de> wrote:
> 
> today I switched from 2.6.22.3 to 2.6.23-rc5 (skipped quite a few -rc 
> versions due to lack of time), and the box keeps panicking under certain 
> circumstances. I suspected disk related problems, because: when the box 
> is up, I usually resume ~10 bittorrent files. When doing this, each
> file (~200MB...1GB) is checked and disk activity is pretty high (20MB/s
> or so), and after 1 minute of doing so the box panicks. Every time.

You want this patch (by davem).

Unfortunately people are travelling so I'm not sure when it'll
get picked up by Linus.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
From: davem@davemloft.net (David Miller)

> ip is at tcp_rto_min+0x20/0x40

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1ee7212..bbad2cd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -560,7 +560,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	struct dst_entry *dst = __sk_dst_get(sk);
 	u32 rto_min = TCP_RTO_MIN;
 
-	if (dst_metric_locked(dst, RTAX_RTO_MIN))
+	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
 		rto_min = dst->metrics[RTAX_RTO_MIN-1];
 	return rto_min;
 }
