From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 11/14] vlan: clean up vlan_dev_hard_start_xmit()
Date: Fri, 10 Aug 2012 09:14:32 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208100913090.13591@stinky-local.trash.net>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
 <1344582637-18261-12-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36091 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802Ab2HJHOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 03:14:38 -0400
In-Reply-To: <1344582637-18261-12-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Aug 2012, Cong Wang wrote:

> Clean up vlan_dev_hard_start_xmit() function.
>
> Cc: Benjamin LaHaise <bcrl@kvack.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> net/8021q/vlan_dev.c |   27 ++++++++++++++++++++-------
> 1 files changed, 20 insertions(+), 7 deletions(-)
>
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index b65623f..dedc56c 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -137,9 +137,21 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
> 	return rc;
> }
>
> +static inline netdev_tx_t vlan_netpoll_send_skb(struct vlan_dev_priv *info, struct sk_buff *skb)
> +{
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	if (info->netpoll)
> +		netpoll_send_skb(info->netpoll, skb);
> +#else
> +	BUG();
> +#endif
> +	return NETDEV_TX_OK;
> +}
> +
> static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
> 					    struct net_device *dev)
> {
> +	struct vlan_dev_priv *info = vlan_dev_priv(dev);

We're consistently using "vlan" for the private data throughout
the code. Please keep it that way.
