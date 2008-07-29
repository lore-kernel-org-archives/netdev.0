From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 2/7] drivers/net/ehea/ehea_main.c: Release mutex in error handling code
Date: Tue, 29 Jul 2008 10:14:55 +0200
Message-ID: <200807291014.55388.ossthema@de.ibm.com>
References: <Pine.LNX.4.64.0807210957060.24625@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, raisch@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:11917 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712AbYG2IPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 04:15:10 -0400
In-Reply-To: <Pine.LNX.4.64.0807210957060.24625@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 July 2008 09:57, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The mutex is released on a successful return, so it would seem that it
> should be released on an error return as well.
> 
> The semantic patch finds this problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression l;
> @@
> 
> mutex_lock(l);
> ... when != mutex_unlock(l)
>     when any
>     when strict
> (
> if (...) { ... when != mutex_unlock(l)
> +   mutex_unlock(l);
>     return ...;
> }
> |
> mutex_unlock(l);
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
> diff -u -p a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -2937,9 +2937,9 @@ static void ehea_rereg_mrs(struct work_s
>  				}
>  			}
>  		}
> -       mutex_unlock(&dlpar_mem_lock);
> -       ehea_info("re-initializing driver complete");
> +	ehea_info("re-initializing driver complete");
>  out:
> +	mutex_unlock(&dlpar_mem_lock);
>  	return;
>  }
> 
> --

The patch looks good. 

Acked-by: Jan-Bernd Themann <themann@de.ibm.com>

Thanks,
Jan-Bernd
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
