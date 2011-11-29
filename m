From: Paul Moore <paul@paul-moore.com>
Subject: Re: [patch] net/netlabel: copy and paste bug in netlbl_cfg_unlbl_map_add()
Date: Tue, 29 Nov 2011 12:47:54 -0500
Message-ID: <2892320.ttUs8EtPs3@sifl>
References: <20111124071820.GB14122@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45096 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab1K2RsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 12:48:00 -0500
In-Reply-To: <20111124071820.GB14122@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, November 24, 2011 10:18:20 AM Dan Carpenter wrote:
> This was copy and pasted from the IPv4 code.  We're calling the
> ip4 version of that function and map4 is NULL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 8ed67dcc..3735297 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -162,8 +162,8 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
>  			map6->list.addr.s6_addr32[3] &= mask6->s6_addr32[3];
>  			map6->list.mask = *mask6;
>  			map6->list.valid = 1;
> -			ret_val = netlbl_af4list_add(&map4->list,
> -						     &addrmap->list4);
> +			ret_val = netlbl_af6list_add(&map6->list,
> +						     &addrmap->list6);
>  			if (ret_val != 0)
>  				goto cfg_unlbl_map_add_failure;
>  			break;

Thanks for fixing this.  I actually stumbled across this just last week while 
working on the CALIPSO stuff and queued up a patch but didn't get a chance to 
verify it before Thanksgiving - you just saved me the effort :)

-- 
paul moore
www.paul-moore.com
