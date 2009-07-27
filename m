From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 11/12] net/netlabel: Correct redundant test
Date: Mon, 27 Jul 2009 13:37:29 -0400
Message-ID: <200907271337.30401.paul.moore@hp.com>
References: <Pine.LNX.4.64.0907271815260.2682@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:5977 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbZG0RiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:38:02 -0400
In-Reply-To: <Pine.LNX.4.64.0907271815260.2682@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 27 July 2009 12:15:43 pm Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
>
> entry was tested for NULL near the beginning of the function, followed by a
> return, and there is no intervening modification of its value.
>
> A simplified version of the semantic match that finds this problem is as
> follows: (http://www.emn.fr/x-info/coccinelle/)
>
> // <smpl>
> @r exists@
> local idexpression x;
> expression E;
> position p1,p2;
> @@
>
> if (x == NULL || ...) { ... when forall
>    return ...; }
> ... when != \(x=E\|x--\|x++\|--x\|++x\|x-=E\|x+=E\|x|=E\|x&=E\|&x\)
> (
> *x == NULL
>
> *x != NULL
> )
> // </smpl>
>
> Signed-off-by: Julia Lawall <julia@diku.dk>

Good catch, thanks.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_kapi.c        |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index b0e582f..3ff6f32 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -185,8 +185,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
>  	return 0;
>
>  cfg_unlbl_map_add_failure:
> -	if (entry != NULL)
> -		kfree(entry->domain);
> +	kfree(entry->domain);
>  	kfree(entry);
>  	kfree(addrmap);
>  	kfree(map4);
> @@ -385,8 +384,7 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
>
>  cfg_cipsov4_map_add_failure:
>  	cipso_v4_doi_putdef(doi_def);
> -	if (entry != NULL)
> -		kfree(entry->domain);
> +	kfree(entry->domain);
>  	kfree(entry);
>  	kfree(addrmap);
>  	kfree(addrinfo);

-- 
paul moore
linux @ hp

