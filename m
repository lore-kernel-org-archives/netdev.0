From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] pktgen: skb bursting via skb->xmit_more API
Date: Wed, 27 Aug 2014 14:36:52 -0700 (PDT)
Message-ID: <20140827.143652.79895672305012694.davem@davemloft.net>
References: <20140827211300.26976.52104.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	hannes@stressinduktion.org, cwang@twopensource.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935548AbaH0Vgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 17:36:53 -0400
In-Reply-To: <20140827211300.26976.52104.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 27 Aug 2014 23:13:00 +0200

> This patch just demonstrates the effect of delaying the HW tailptr,
> the skb->xmit_more API should likely have some wrappers.
> 
> One issue is the possible need to flush/write the tailptr on
> the exit path... marked with FIXME.
 ...
> Performance
>  skb_burst=0  tx:5614370 pps
>  skb_burst=1  tx:5571279 pps ( -1.38 ns (worse))
>  skb_burst=2  tx:6942821 pps ( 35.46 ns)
>  skb_burst=3  tx:7556214 pps ( 11.69 ns)
>  skb_burst=4  tx:7740632 pps ( 3.15 ns)
>  skb_burst=5  tx:7972489 pps ( 3.76 ns)
>  skb_burst=6  tx:8129856 pps ( 2.43 ns)
>  skb_burst=7  tx:8281671 pps ( 2.25 ns)
>  skb_burst=8  tx:8383790 pps ( 1.47 ns)
>  skb_burst=9  tx:8451248 pps ( 0.95 ns)
>  skb_burst=10 tx:8503571 pps ( 0.73 ns)
>  skb_burst=16 tx:8745878 pps ( 3.26 ns)
>  skb_burst=24 tx:8871629 pps ( 1.62 ns)
>  skb_burst=32 tx:8945166 pps ( 0.93 ns)
> 
> skb_burst=(0 vs 32) improvement:
>  (1/5614370*10^9)-(1/8945166*10^9) = 66.32 ns
>   + 3330796 pps

Thanks for doing these tests Jesper.
