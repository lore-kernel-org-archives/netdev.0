From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev()
 helper function
Date: Thu, 14 Nov 2013 10:03:19 -0500
Message-ID: <5284E637.5060805@gmail.com>
References: <cover.1384436410.git.mkubecek@suse.cz> <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:40053 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531Ab3KNPDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 10:03:22 -0500
Received: by mail-yh0-f46.google.com with SMTP id c41so1040542yho.5
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 07:03:22 -0800 (PST)
In-Reply-To: <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 09:00 AM, Michal Kubecek wrote:
> Introduce helper function macvlan_dev_real_dev which returns the
> underlying device of a macvlan device, similar to vlan_dev_real_dev()
> for 802.1q VLAN devices.
>
> v2: IFF_MACVLAN flag and equivalent of is_macvlan_dev() were
> introduced in the meantime
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>   include/linux/if_macvlan.h | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)
>
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index c270285..ac9aab2 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -119,4 +119,20 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
>   extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
>   				      struct net_device *dev);
>
> +#if IS_ENABLED(CONFIG_MACVLAN)
> +static inline struct net_device *
> +macvlan_dev_real_dev(const struct net_device *dev)
> +{
> +	struct macvlan_dev *macvlan = netdev_priv(dev);
> +
> +	return macvlan->lowerdev;
> +}
> +#else
> +static inline struct net_device *
> +macvlan_dev_real_dev(const struct net_device *dev)
> +{
> +	return NULL;
> +}
> +#endif
> +

You may want to do the same here as was done for vlan_dev_real_dev(). 
This function is not intended to be called blindly and should always
be called after netif_is_macvlan().

-vlad


>   #endif /* _LINUX_IF_MACVLAN_H */
>
