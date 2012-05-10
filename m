From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Memory exhaust issue with only IPsec policies configured
 on continuous traffic
Date: Thu, 10 May 2012 07:32:03 +0200
Message-ID: <1336627923.12504.128.camel@edumazet-glaptop>
References: <F0B93D0554724543876B9A180DC988575B8867@039-SN1MPN1-001.039d.mgd.msft.net>
	 <CAETiZ-QTWN2U=hmaCS39Q8hzNysjam+eS5FSi-EYO7cXtTbGKQ@mail.gmail.com>
	 <CAETiZ-QvamMJxfGJDK4CiKngELNevmOXnh7M=UGnkH61XrT5dw@mail.gmail.com>
	 <1336627627.12504.127.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, benjamin.thery@bull.net,
	davem@davemloft.net, pstaszewski@itcare.pl
To: Nikhil Agarwal <hi2nikhil@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336627627.12504.127.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-10 at 07:27 +0200, Eric Dumazet wrote:

> Yep, we can use DST_NOCACHE
> 

Please try following patch :

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5773f5d..172c251 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2896,6 +2896,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
+		new->flags |= DST_NOCACHE;
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
