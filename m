From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] tap: Mark devices of type "tun" as IFF_DONT_BRIDGE
Date: Wed, 4 Jun 2014 11:54:48 -0700
Message-ID: <20140604115448.644073d0@nehalam.linuxnetplumber.net>
References: <1401905168-21559-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:45934 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbaFDSyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 14:54:52 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so7381699pbb.21
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 11:54:52 -0700 (PDT)
In-Reply-To: <1401905168-21559-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Jun 2014 14:06:08 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Tun devices are layer 3 devices and do not work correctly
> when bridged.  Mark then as IFF_DONT_BRIDGE so that people
> trying to bridge will get an error.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/tun.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index ee328ba..0161aa3 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -931,6 +931,7 @@ static void tun_net_init(struct net_device *dev)
>  		/* Zero header length */
>  		dev->type = ARPHRD_NONE;
>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> +		dev->priv_flags |= IFF_DONT_BRIDGE;
>  		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
>  		break;
>  

This should not be necessary since bridge already checks for non-ethernet
devices.

	/* Don't allow bridging non-ethernet like devices */
	if ((dev->flags & IFF_LOOPBACK) ||
	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN ||
	    !is_valid_ether_addr(dev->dev_addr))
		return -EINVAL;
