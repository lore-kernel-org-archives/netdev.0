From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v2 net-next 1/2] ppp: remove NETIF_F_NETNS_LOCAL from ppp device features.
Date: Mon, 07 Jan 2013 01:16:45 -0800
Message-ID: <87hamt73pe.fsf@xmission.com>
References: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
	<1357543176-15352-2-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57203 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab3AGJRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 04:17:00 -0500
In-Reply-To: <1357543176-15352-2-git-send-email-ramirose@gmail.com> (Rami
	Rosen's message of "Mon, 7 Jan 2013 09:19:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen <ramirose@gmail.com> writes:

> There is no need for NETIF_F_NETNS_LOCAL for ppp device; this patch
> removes it.

At least pppoe_rcv_core assumes that the ppp socket and the network
devices are all in the same network namespace.  So it looks like
NETIF_F_NETNS_LOCAL is needed.

Eric

> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>  drivers/net/ppp/ppp_generic.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 0b2706a..89b6fc5 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -1073,7 +1073,6 @@ static void ppp_setup(struct net_device *dev)
>  	dev->tx_queue_len = 3;
>  	dev->type = ARPHRD_PPP;
>  	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> -	dev->features |= NETIF_F_NETNS_LOCAL;
>  	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
>  }
