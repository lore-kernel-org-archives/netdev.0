From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] veth: add netpoll support
Date: Fri, 20 Jun 2014 23:31:30 +0400
Message-ID: <53A48C12.8020104@cogentembedded.com>
References: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: s.priebe@profihost.ag, "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:60868 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaFTTbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 15:31:22 -0400
Received: by mail-lb0-f173.google.com with SMTP id s7so2670432lbd.32
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 12:31:20 -0700 (PDT)
In-Reply-To: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/20/2014 11:17 PM, Cong Wang wrote:

> It is trivial to add netpoll support to veth, since
> it is not stacked device, we don't need to setup and cleanup
> netpoll.

> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

> ---
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index b4a10bc..03e781b 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -248,6 +248,13 @@ static void veth_dev_free(struct net_device *dev)
>   	free_netdev(dev);
>   }
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void veth_poll_controller(struct net_device *dev)
> +{
> +	return;

    Not needed.

> +}
> +#endif	/* CONFIG_NET_POLL_CONTROLLER */
> +
>   static const struct net_device_ops veth_netdev_ops = {
>   	.ndo_init            = veth_dev_init,
>   	.ndo_open            = veth_open,

WBR, Sergei
