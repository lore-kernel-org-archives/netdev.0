From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: add a sock pointer to ip_queue_xmit() and
 friends
Date: Tue, 15 Apr 2014 13:16:36 -0400 (EDT)
Message-ID: <20140415.131636.1847117096992048895.davem@davemloft.net>
References: <1397520840.4222.65.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHz2CGW_Eh5P_Z4=a-tfnp-S_62bZRXk2pLxes7ufEdfr0hwAQ@mail.gmail.com>
	<1397572392.4222.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, netdev@vger.kernel.org,
	lucien.xin@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaDORQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 13:16:38 -0400
In-Reply-To: <1397572392.4222.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Apr 2014 07:33:12 -0700

> diff --git a/net/core/dst.c b/net/core/dst.c
> index ca4231ec7347..7443c2725c9c 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -142,12 +142,12 @@ loop:
>  	mutex_unlock(&dst_gc_mutex);
>  }
>  
> -int dst_discard(struct sk_buff *skb)
> +int dst_discard_sk(struct sock *sk, struct sk_buff *skb)
>  {
>  	kfree_skb(skb);
>  	return 0;
>  }
> -EXPORT_SYMBOL(dst_discard);
> +EXPORT_SYMBOL(dst_discard_sk);
>  
>  const u32 dst_default_metrics[RTAX_MAX + 1] = {
>  	/* This initializer is needed to force linker to place this variable

This doesn't compile, I'd expect to see hunks such as:

@@ -184,7 +184,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->xfrm = NULL;
 #endif
 	dst->input = dst_discard;
-	dst->output = dst_discard;
+	dst->output = dst_discard_sk;
 	dst->error = 0;
 	dst->obsolete = initial_obsolete;
 	dst->header_len = 0;

for this file, but I don't.  Maybe you posted an outdated revision of your
patch?  There also aren't the necessary decnet and XFRM changes, layers
which also use dst->output().

Anyways, I'm splitting up your patches and sorting this out.
