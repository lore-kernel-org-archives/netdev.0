From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5 2.6.21-rc7] l2tp: pppox protocol module load
Date: Mon, 30 Apr 2007 00:21:37 -0700 (PDT)
Message-ID: <20070430.002137.99458495.davem@davemloft.net>
References: <200704231601.l3NG13mC030171@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423105AbXD3HVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:21:40 -0400
In-Reply-To: <200704231601.l3NG13mC030171@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 23 Apr 2007 17:01:03 +0100

> [L2TP]: Add the ability to autoload a pppox protocol module.
> 
> This patch allows a name "pppox-proto-nnn" to be used in modprobe.conf
> to autoload a PPPoX protocol nnn.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> Index: linux-2.6.21-rc7/drivers/net/pppox.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/drivers/net/pppox.c
> +++ linux-2.6.21-rc7/drivers/net/pppox.c
> @@ -114,6 +114,13 @@ static int pppox_create(struct socket *s
>  		goto out;
>  
>  	rc = -EPROTONOSUPPORT;
> +#ifdef CONFIG_KMOD
> +	if (!pppox_protos[protocol]) {
> +		char buffer[32];
> +		sprintf(buffer, "pppox-proto-%d", protocol);
> +		request_module(buffer);
> +	}
> +#endif
>  	if (!pppox_protos[protocol] ||
>  	    !try_module_get(pppox_protos[protocol]->owner))
>  		goto out;

If you're going to use an interface declared in linux/kmod.h
you'll have to make sure that header file is included by
pppox.c

I've made that fix and applied your patch, thanks.
