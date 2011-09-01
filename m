From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] dev_ioctl should return -EINVAL for unknown ioctl
 instead of -ENOTTY
Date: Thu, 01 Sep 2011 16:41:10 +0100
Message-ID: <1314891670.2733.12.camel@bwh-desktop>
References: <4E5F9C14.1040108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wang Sheng-Hui <shhuiw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19543 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439Ab1IAPlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 11:41:14 -0400
In-Reply-To: <4E5F9C14.1040108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-01 at 22:52 +0800, Wang Sheng-Hui wrote:
> The patch is against 3.1-rc3.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 17d67b5..de6033c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5092,7 +5092,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  		/* Take care of Wireless Extensions */
>  		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
>  			return wext_handle_ioctl(net, &ifr, cmd, arg);
> -		return -ENOTTY;
> +		return -EINVAL;
>  	}
>  }
>  

Whereas, Linus Torvalds wrote in
<BANLkTin=PTbTwBR2s+owMLy+GmKigeoYvg@mail.gmail.com>:
[...]
> The correct error code for "I don't understand this ioctl" is ENOTTY.
> The naming may be odd, but you should think of that error value as a
> "unrecognized ioctl number, you're feeding me random numbers that I
> don't understand and I assume for historical reasons that you tried to
> do some tty operation on me".
[...]

(Not that we are consistent about using ENOTTY in networking now.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
