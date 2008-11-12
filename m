From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Tue, 11 Nov 2008 16:45:54 -0800 (PST)
Message-ID: <20081111.164554.143409564.davem@davemloft.net>
References: <20081110.164424.167225199.davem@davemloft.net>
	<20081111110847.GC3665@x200.localdomain>
	<20081111111946.GD3665@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755426AbYKLApy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 19:45:54 -0500
In-Reply-To: <20081111111946.GD3665@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 11 Nov 2008 14:19:46 +0300

> @@ -35,7 +35,9 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
>  	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
>  
>  	if (tb != NULL) {
> +#ifdef CONFIG_NET_NS
>  		tb->ib_net       = hold_net(net);
> +#endif
>  		tb->port      = snum;
>  		tb->fastreuse = 0;
>  		INIT_HLIST_HEAD(&tb->owners);

No, this is exactly what we don't want.

If you have to add ifdefs to core C files, you're doing something
wrong.

All the details of ifdef this or ifdef that should be hidden in the
header files.

You cited an example where there are a ton of ifdefs in some header
fule inline function, but that is EXACTLY how this stuff should be
done.  Those header files are where such ugly implementation details
belong.

When people read actual code, they should be concerning themselves
with control flow, what the code is trying to do, etc. rather then
being continually interrupted with ifdef this and ifdef that.
