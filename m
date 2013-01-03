From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH net-next 3/3] vxlan: remove NETIF_F_NETNS_LOCAL from
 vxlan device features.
Date: Thu, 3 Jan 2013 07:45:03 -0800
Message-ID: <20130103074503.3bafe61a@nehalam.linuxnetplumber.net>
References: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
	<1357205121-4700-4-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ebiederm@xmission.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44166 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab3ACPq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 10:46:28 -0500
In-Reply-To: <1357205121-4700-4-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Jan 2013 11:25:21 +0200
Rami Rosen <ramirose@gmail.com> wrote:

> There is no need for NETIF_F_NETNS_LOCAL for vxlan device; this patch removes it.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>  drivers/net/vxlan.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 40f2cc1..385f743 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1185,7 +1185,6 @@ static void vxlan_setup(struct net_device *dev)
>  
>  	dev->tx_queue_len = 0;
>  	dev->features	|= NETIF_F_LLTX;
> -	dev->features	|= NETIF_F_NETNS_LOCAL;
>  	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
>  	dev->features   |= NETIF_F_RXCSUM;
>  

Vxlan works over UDP socket, and the UDP socket is part of the namespace
it is created in. Moving the vxlan device does not move that state.
