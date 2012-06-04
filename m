From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Remove casts to same type
Date: Mon, 4 Jun 2012 17:04:41 +0100
Message-ID: <1338825881.3979.203.camel@deadeye>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30800 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760781Ab2FDQEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 12:04:47 -0400
In-Reply-To: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-03 at 20:41 -0700, Joe Perches wrote:
> Adding casts of objects to the same type is unnecessary
> and confusing for a human reader.
> 
> For example, this cast:
> 
> 	int y;
> 	int *p = (int *)&y;
> 
> I used the coccinelle script below to find and remove these
> unnecessary casts.  I manually removed the conversions this
> script produces of casts with __force and __user.
[...]
> diff --git a/net/9p/client.c b/net/9p/client.c
> index a170893..5cbea90 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -1548,7 +1548,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
>  			kernel_buf = 1;
>  			indata = data;
>  		} else
> -			indata = (char *)udata;
> +			indata = udata;
>  		/*
>  		 * response header len is 11
>  		 * PDU Header(7) + IO Size (4)
[...]

This one is casting char __user * to char *.  We need a cast to let
sparse know this is deliberate, though presumably we need __force as
well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
