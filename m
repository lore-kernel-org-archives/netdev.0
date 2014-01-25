From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix potential incorrect pointer dereference in
 xfrm_bundle_create
Date: Sat, 25 Jan 2014 11:07:45 -0800 (PST)
Message-ID: <20140125.110745.939440249416819926.davem@davemloft.net>
References: <1390675673-20682-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: horia.geanta@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbaAYTH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 14:07:57 -0500
In-Reply-To: <1390675673-20682-1-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Horia Geanta <horia.geanta@freescale.com>
Date: Sat, 25 Jan 2014 20:47:53 +0200

> Return value of xfrm_alloc_dst might be an error code.
> Need to check this before using the pointer safely.
> 
> Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
> ---
>  net/xfrm/xfrm_policy.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 9a91f74..f230f2a 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1541,7 +1541,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
>  
>  	for (; i < nx; i++) {
>  		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
> -		struct dst_entry *dst1 = &xdst->u.dst;
> +		struct dst_entry *dst1;

There is no harm in taking the address of a bad pointer.  The only
trouble is if we actually dereference it, which we are not doing here.

I'm not applying this patch, sorry.
