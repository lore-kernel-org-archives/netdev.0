From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] myri10ge: disable NAPI on failure to setup the interface
Date: Tue, 21 Oct 2008 01:15:31 -0400
Message-ID: <48FD6573.1080400@garzik.org>
References: <48FC7164.8040002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbYJUFPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 01:15:39 -0400
In-Reply-To: <48FC7164.8040002@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Disable NAPI if a failure occurs when setting up the interface. Leaving
> it enabled could cause a BUG the next time an ifconfig up is issued.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> 
> --- linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-10-20 08:36:48.000000000 +0200
> +++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-10-20 13:47:21.000000000 +0200
> @@ -75,7 +75,7 @@
>  #include "myri10ge_mcp.h"
>  #include "myri10ge_mcp_gen_header.h"
>  
> -#define MYRI10GE_VERSION_STR "1.4.3-1.369"
> +#define MYRI10GE_VERSION_STR "1.4.3-1.371"
>  
>  MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
>  MODULE_AUTHOR("Maintainer: help@myri.com");
> @@ -2497,6 +2497,10 @@ static int myri10ge_open(struct net_devi
>  	return 0;
>  
>  abort_with_rings:
> +	while (slice) {
> +		slice--;
> +		napi_disable(&mgp->ss[slice].napi);
> +	}

applied


