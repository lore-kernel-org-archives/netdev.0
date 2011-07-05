From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] net: vlan: enable GSO by default
Date: Tue, 05 Jul 2011 17:35:31 +0800
Message-ID: <4E12DAE3.8050904@cn.fujitsu.com>
References: <4E0406C4.6060004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63735 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754501Ab1GEJe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 05:34:26 -0400
In-Reply-To: <4E0406C4.6060004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping....

Shan Wei wrote, at 06/24/2011 11:38 AM:
> Currently, GSO for vlan device is off, and can't be set to on.
> Although underlying device don't support TSO, we still
> should use software segments for vlan device.
> 
> In vlan_dev_fix_features(), final features is decided by
> features of real device and vlan_features of real device.
> 
> real_dev->vlan_features is initialized in register_netdevice()
> only with NETIF_F_GRO, not NETIF_F_GSO.
> 
> So, now GRO is ok, but GSO is broken by default.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/8021q/vlan_dev.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 1c9aa8c..d8f45ba 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -588,9 +588,14 @@ static void vlan_dev_uninit(struct net_device *dev)
>  static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
>  {
>  	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
> +	u32 old_features = features;
>  
>  	features &= real_dev->features;
>  	features &= real_dev->vlan_features;
> +
> +	if (old_features & NETIF_F_SOFT_FEATURES)
> +		features |= old_features & NETIF_F_SOFT_FEATURES;
> +
>  	if (dev_ethtool_get_rx_csum(real_dev))
>  		features |= NETIF_F_RXCSUM;
>  	features |= NETIF_F_LLTX;


-- 

Best Regards
-----
Shan Wei
