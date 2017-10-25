From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: qualcomm: rmnet: Add support for GRO
Date: Wed, 25 Oct 2017 07:00:57 -0700
Message-ID: <1508940057.30291.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
         <1508907329-1077-5-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:48654 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdJYOA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:00:59 -0400
Received: by mail-pg0-f65.google.com with SMTP id v78so53643pgb.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:00:59 -0700 (PDT)
In-Reply-To: <1508907329-1077-5-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-24 at 22:55 -0600, Subash Abhinov Kasiviswanathan wrote:
> Add gro_cells so that rmnet devices can call gro_cells_receive
> instead of netif_receive_skb.
> 

>  void rmnet_vnd_setup(struct net_device *rmnet_dev)
>  {
> +	struct rmnet_priv *priv = netdev_priv(rmnet_dev);
> +
>  	rmnet_dev->netdev_ops = &rmnet_vnd_ops;
>  	rmnet_dev->mtu = RMNET_DFLT_PACKET_SIZE;
>  	rmnet_dev->needed_headroom = RMNET_NEEDED_HEADROOM;
> @@ -162,6 +164,8 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
>  	rmnet_dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
>  
>  	rmnet_dev->needs_free_netdev = true;
> +
> +	gro_cells_init(&priv->gro_cells, rmnet_dev);
>  }


You need to check return code and abort if memory could not be
allocated.

There is a reason this helper has _init() prefix, it does not belong to
_setup() since a _setup() is not expected to fail.

Please take a look at other gro_cells_init() callers, and you will
notice that it is called from ndo_init()

You might have copied the only buggy caller (vxlan).

Tom, if you read me fix vxlan, thanks !
