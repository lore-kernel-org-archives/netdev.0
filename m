From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 5/5] net: pppoe,pppol2tp - register channels with explicit
 net
Date: Tue, 20 Jan 2009 21:56:32 +0000
Message-ID: <49764890.5010403@katalix.com>
References: <20090120140510.228815074@gmail.com>> <4975dc14.0637560a.7f8e.729c@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org,
	Michal Ostrowski <mostrows@earthlink.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:59338 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460AbZATV4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 16:56:44 -0500
In-Reply-To: <4975dc14.0637560a.7f8e.729c@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> In PPPo[E|L2TP] we could explicitly point which net namespace
> we're going to use for channels - make it so.
> 
> CC: James Chapman <jchapman@katalix.com>
> CC: Michal Ostrowski <mostrows@earthlink.net>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

This one's ok by me too for pppol2tp.

Signed-off-by: James Chapman <jchapman@katalix.com>

> ---
>  drivers/net/pppoe.c    |    2 +-
>  drivers/net/pppol2tp.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.git/drivers/net/pppoe.c
> ===================================================================
> --- linux-2.6.git.orig/drivers/net/pppoe.c
> +++ linux-2.6.git/drivers/net/pppoe.c
> @@ -695,7 +695,7 @@ static int pppoe_connect(struct socket *
>  		po->chan.private = sk;
>  		po->chan.ops = &pppoe_chan_ops;
>  
> -		error = ppp_register_channel(&po->chan);
> +		error = ppp_register_net_channel(dev_net(dev), &po->chan);
>  		if (error)
>  			goto err_put;
>  
> Index: linux-2.6.git/drivers/net/pppol2tp.c
> ===================================================================
> --- linux-2.6.git.orig/drivers/net/pppol2tp.c
> +++ linux-2.6.git/drivers/net/pppol2tp.c
> @@ -1749,7 +1749,7 @@ static int pppol2tp_connect(struct socke
>  	po->chan.ops	 = &pppol2tp_chan_ops;
>  	po->chan.mtu	 = session->mtu;
>  
> -	error = ppp_register_channel(&po->chan);
> +	error = ppp_register_net_channel(sock_net(sk), &po->chan);
>  	if (error)
>  		goto end_put_tun;
>  
> 


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

