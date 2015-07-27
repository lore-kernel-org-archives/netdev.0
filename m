From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V12 2/3] Check for vlan ethernet types for
 8021.q or 802.1ad
Date: Mon, 27 Jul 2015 01:24:21 -0700 (PDT)
Message-ID: <20150727.012421.729387450726515671.davem@davemloft.net>
References: <1437922355-3809-1-git-send-email-thomasfherbert@gmail.com>
	<1437922355-3809-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, therbert@redhat.com,
	dev@openvswitch.org
To: thomasfherbert@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbG0IYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:24:21 -0400
In-Reply-To: <1437922355-3809-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas F Herbert <thomasfherbert@gmail.com>
Date: Sun, 26 Jul 2015 10:52:34 -0400

> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  include/linux/if_vlan.h | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 67ce5bd..88d1be4 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -627,6 +627,23 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>  
>  	return features;
>  }
> +/**
> + * eth_type_vlan - check for valid vlan ether type.
> + * @ethertype: ether type to check
> + *
> + * Returns true if the ether type is a vlan ether type.
> + */
> +static inline bool eth_type_vlan(__be16 ethertype)
> +{
> +	switch (ethertype) {
> +	case (htons(ETH_P_8021Q)):
> +		return true;
> +	case (htons(ETH_P_8021AD)):
> +		return true;

Please don't put unnecessary parenthesis around case statement values.

Thanks.
