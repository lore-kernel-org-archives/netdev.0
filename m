From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] veth: set iflink to the peer veth
Date: Tue, 03 Feb 2015 08:12:09 -0800
Message-ID: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422978106-4744-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:50732 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932314AbbBCQML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:12:11 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so27587951iga.5
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 08:12:10 -0800 (PST)
In-Reply-To: <1422978106-4744-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 16:41 +0100, Nicolas Dichtel wrote:
> Now that the peer netns is advertised in rtnl messages, we can set this property
> so that IFLA_LINK will advertise the peer ifindex. It allows the userland to get
> the full veth configuration.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  drivers/net/veth.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 4cca36ebc4fb..02d1f798a371 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -427,9 +427,11 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
>  
>  	priv = netdev_priv(dev);
>  	rcu_assign_pointer(priv->peer, peer);
> +	dev->iflink = peer->ifindex;
>  
>  	priv = netdev_priv(peer);
>  	rcu_assign_pointer(priv->peer, dev);
> +	peer->iflink = dev->ifindex;
>  	return 0;
>  
>  err_register_dev:

Is is network namespace ready ?

If I move one veth to another namespace, is iflink still relevant ?
