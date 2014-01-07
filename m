From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 07 Jan 2014 08:34:21 -0800
Message-ID: <1389112461.26646.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	 <1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:48255 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbaAGQeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:34:25 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so560769pdj.36
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 08:34:25 -0800 (PST)
In-Reply-To: <1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
> Add gro handlers for vxlan using the udp gro infrastructure
> 


>  static void vxlan_notify_add_rx_port(struct sock *sk)
>  {
> @@ -568,6 +661,8 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>  			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>  							    port);
>  	}
> +	if (sa_family == AF_INET)
> +		udp_add_offload(&vxlan_offload, port);
>  	rcu_read_unlock();
>  }
>  

This means two vxlan tunnels can not share same port.

Is that a valid assertion ?
