From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/9] net: ipmr: remove SLAB_PANIC
Date: Sat, 21 Nov 2015 06:23:33 -0800
Message-ID: <1448115813.22599.289.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
	 <1448110902-28793-8-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36521 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbbKUOXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:23:35 -0500
Received: by pacdm15 with SMTP id dm15so145300090pac.3
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:23:35 -0800 (PST)
In-Reply-To: <1448110902-28793-8-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-11-21 at 14:01 +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> It's not necessary to panic upon allocation failure, returning an error
> at that point is okay because user-space won't be able to use any of the
> ops since they didn't get registered and the default table is null.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/ipv4/ipmr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index a006d96d6cd9..2c7fa584a274 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -2675,7 +2675,7 @@ int __init ip_mr_init(void)
>  
>  	mrt_cachep = kmem_cache_create("ip_mrt_cache",
>  				       sizeof(struct mfc_cache),
> -				       0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
> +				       0, SLAB_HWCACHE_ALIGN,
>  				       NULL);
>  	if (!mrt_cachep)
>  		return -ENOMEM;

This runs at boot time.

I very much prefer a panic instead of having to deal with a host with a
probable bug in mm layer at this point.

For IPv6, it is a different matter as it might be a module, thus
ip6_mr_init() does not use SLAB_PANIC
