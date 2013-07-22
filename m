From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Mon, 22 Jul 2013 08:17:53 -0700
Message-ID: <1374506273.4990.13.camel@edumazet-glaptop>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58706 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677Ab3GVPR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:17:57 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so6958032pde.37
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:17:57 -0700 (PDT)
In-Reply-To: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-07-20 at 10:26 -0700, Stephen Hemminger wrote:
> Rather than relying on the assumption that zero means empty on
> hash list head, the code should use the initialization macro.
> Same effect, but follows API and avoids future breakage if hlist
> implementation changes.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> 
> --- a/net/ipv4/ip_tunnel.c	2013-07-19 09:12:37.213529343 -0700
> +++ b/net/ipv4/ip_tunnel.c	2013-07-19 09:37:00.960764421 -0700
> @@ -838,10 +838,15 @@ int ip_tunnel_init_net(struct net *net,
>  {
>  	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
>  	struct ip_tunnel_parm parms;
> +	unsigned i;
>  
> -	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
> +	itn->tunnels = kmalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head),
> +			       GFP_KERNEL);
>  	if (!itn->tunnels)
>  		return -ENOMEM;
> +
> +	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
> +		INIT_HLIST_HEAD(&itn->tunnels[i]);
>  

What about adding a variant of INIT_HLIST_HEAD() that does nothing for
already cleared memory ?
