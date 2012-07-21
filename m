From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Sat, 21 Jul 2012 07:40:07 +0200
Message-ID: <1342849207.2626.8196.camel@edumazet-glaptop>
References: <1342824166.2626.8112.camel@edumazet-glaptop>
	 <20120720.155021.1919200619716435427.davem@davemloft.net>
	 <20120720.155412.1512575922394612084.davem@davemloft.net>
	 <20120720.161331.2251326254024647237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54804 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab2GUFkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 01:40:13 -0400
Received: by weyx8 with SMTP id x8so3070459wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 22:40:12 -0700 (PDT)
In-Reply-To: <20120720.161331.2251326254024647237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 16:13 -0700, David Miller wrote:

> 
> ====================
> [PATCH] ipv4: Fix neigh lookup keying over loopback/point-to-point devices.
> 
> We were using a special key "0" for all loopback and point-to-point
> device neigh lookups under ipv4, but we wouldn't use that special
> key for the neigh creation.
> 
> So basically we'd make a new neigh at each and every lookup :-)
> 
> This special case to use only one neigh for these device types
> is of dubious value, so just remove it entirely.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/arp.h |    3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/include/net/arp.h b/include/net/arp.h
> index 4617d98..7f7df93 100644
> --- a/include/net/arp.h
> +++ b/include/net/arp.h
> @@ -21,9 +21,6 @@ static inline struct neighbour *__ipv4_neigh_lookup_noref(struct net_device *dev
>  	struct neighbour *n;
>  	u32 hash_val;
>  
> -	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
> -		key = 0;
> -
>  	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
>  	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
>  	     n != NULL;

Excellent

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX    8024082     0.024     2.443
 Close        5894419     0.025     1.426
 Rename        339732     0.024     0.097
 Unlink       1620260     0.024     1.438
 Deltree          228     0.000     0.001
 Mkdir            114     0.025     0.032
 Qpathinfo    7272340     0.024     1.436
 Qfileinfo    1275230     0.024     1.412
 Qfsinfo      1333479     0.025     0.887
 Sfileinfo     653595     0.025     0.160
 Find         2811797     0.024     1.380
 WriteX       4005005     0.045     2.272
 ReadX        12576354     0.031     6.542
 LockX          26120     0.026     0.059
 UnlockX        26120     0.025     0.052
 Flush         562378     0.025     1.372

Throughput 4202.27 MB/sec  24 clients  24 procs  max_latency=2.343 ms
