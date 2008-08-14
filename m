From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Devel] [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Thu, 14 Aug 2008 23:55:37 +0400
Message-ID: <20080814195537.GA8214@martell.zuzino.mipt.ru>
References: <48A4871D.1030708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	containers <containers@lists.osdl.org>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:27297 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760400AbYHNTzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 15:55:42 -0400
Received: by yx-out-2324.google.com with SMTP id 8so428950yxm.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 12:55:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48A4871D.1030708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 03:27:25PM -0400, Brian Haley wrote:
> Change dev_net() to handle a NULL argument - return &init_net instead.

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -781,10 +781,10 @@ static inline
>  struct net *dev_net(const struct net_device *dev)
>  {
>  #ifdef CONFIG_NET_NS
> -	return dev->nd_net;
> -#else
> -	return &init_net;
> +	if (dev)
> +		return dev->nd_net;
>  #endif
> +	return &init_net;
>  }

This is ugly and wrong.

The only assymetry between init_net and dynamically created netns is
that some data structures are created only when init_net is initialized
like some kmem caches and so on.

And some sysctls that some people may ban in netns.

Modulo that, init_net is no different from the rest.

