From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6.26 2/2] Do not allocate unneeded memory for dev->priv
   alignment.
Date: Mon, 07 Apr 2008 19:44:02 +0200
Message-ID: <47FA5D62.5040806@gmail.com>
References: <47FA4C50.3080405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:27664 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbYDGRj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 13:39:29 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1525406fgb.17
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2008 10:39:27 -0700 (PDT)
In-Reply-To: <47FA4C50.3080405@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote, On 04/07/2008 06:31 PM:
...

> ---
>  net/core/dev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7aa0112..80e103a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4000,7 +4000,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
>  		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
>  		     ~NETDEV_ALIGN_CONST;
> -	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
> +	if (sizeof_priv)
> +		alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
>  
>  	p = kzalloc(alloc_size, GFP_KERNEL);
>  	if (!p) {


IMHO this second "+ NETDEV_ALIGN_CONST" is needed here because of "~NETDEV_ALIGN_CONST".

Regards,
Jarek P.
