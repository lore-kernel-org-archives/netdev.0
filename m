From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: Bonding driver does not consider the
 gso_max_size/gso_max_segs setting of slave devices.
Date: Wed, 21 Nov 2012 06:55:06 -0800
Message-ID: <1353509706.2590.33.camel@edumazet-glaptop>
References: <649de771-427a-4876-af3c-9f84a164a7f1@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:41803 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893Ab2KUOzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 09:55:09 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so5083350iay.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 06:55:08 -0800 (PST)
In-Reply-To: <649de771-427a-4876-af3c-9f84a164a7f1@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 20:05 +0530, sarveshwar.bandi@emulex.com wrote:
> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Patch sets the lowest gso_max_size and gso_max_segs values of the slave devices during enslave and detach.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> ---
>  drivers/net/bonding/bond_main.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b2530b0..5f5b69f 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1379,6 +1379,8 @@ static void bond_compute_features(struct bonding *bond)
>  	struct net_device *bond_dev = bond->dev;
>  	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
>  	unsigned short max_hard_header_len = ETH_HLEN;
> +	unsigned int gso_max_size = GSO_MAX_SIZE;
> +	u16 gso_max_segs = GSO_MAX_SEGS;
>  	int i;
>  	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
>  
> @@ -1394,11 +1396,16 @@ static void bond_compute_features(struct bonding *bond)
>  		dst_release_flag &= slave->dev->priv_flags;
>  		if (slave->dev->hard_header_len > max_hard_header_len)
>  			max_hard_header_len = slave->dev->hard_header_len;
> +
> +		gso_max_size = min(gso_max_size, slave->dev->gso_max_size);
> +		gso_max_segs = min(gso_max_segs, slave->dev->gso_max_segs);
>  	}
>  
>  done:
>  	bond_dev->vlan_features = vlan_features;
>  	bond_dev->hard_header_len = max_hard_header_len;
> +	bond_dev->gso_max_segs = gso_max_segs;
> +	netif_set_gso_max_size(bond_dev, gso_max_size);
>  
>  	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
>  	bond_dev->priv_flags = flags | dst_release_flag;

Acked-by: Eric Dumazet <edumazet@google.com>
