From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 18:38:02 +0100
Message-ID: <20130324173802.GD12968@order.stressinduktion.org>
References: <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com> <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com> <1364145768.29473.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55203 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab3CXRiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 13:38:03 -0400
Content-Disposition: inline
In-Reply-To: <1364145768.29473.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 10:22:48AM -0700, Eric Dumazet wrote:
> What could be tried is to remove the possibility of page spanning.
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 441f5bf..d0f4dd1 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1849,7 +1849,7 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
>  		kfree_skb(skb);
>  }
>  
> -#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
> +#define NETDEV_FRAG_PAGE_MAX_ORDER 0
>  #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
>  #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE

Doesn't change anything. :(

We tested it on a v3.8 kernel so I changed the definition in
net/core/skbuff.c. I hope this doesn't change the outcome.

Btw, reports about this bug are dating back to 2008 so I don't think
that a recent change in the kernel broke it.

Thanks,

  Hannes
