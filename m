From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix overflow of name in struct net_device, replaced
 sprintf with snprintf.
Date: Tue, 15 Mar 2011 14:48:20 -0700
Message-ID: <20110315144820.72435a14@nehalam>
References: <1300219208-2708-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51039 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757595Ab1COVsW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 17:48:22 -0400
In-Reply-To: <1300219208-2708-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2011 01:30:08 +0530
Sasikanth V <sasikanth.v19@gmail.com> wrote:

> 
> Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6561021..a74efa9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -539,7 +539,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
>  	char name[IFNAMSIZ];
>  	int i;
>  
> -	sprintf(name, "%s%d", prefix, unit);
> +	snprintf(name, IFNAMSIZ, "%s%d", prefix, unit);
>  
>  	/*
>  	 * If device already registered then return base of 1

that code is only called with a really small values "eth" and "tr" so
it is really not necessary. The whole drivers/net/Space.c code is totally
legacy and should eventually be eliminated anyway.


-- 
