From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Add support for destination
 MAC in steering rules
Date: Tue, 11 Dec 2012 10:38:42 -0500
Message-ID: <50C75382.3040504@hp.com>
References: <1355227436-18383-1-git-send-email-amirv@mellanox.com> <1355227436-18383-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:39473 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab2LKPis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 10:38:48 -0500
In-Reply-To: <1355227436-18383-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2012 07:03 AM, Amir Vadai wrote:
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -619,7 +619,13 @@ static int mlx4_en_validate_flow(struct net_device *dev,
>  	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
>  		return -EINVAL;
>  
> -	switch (cmd->fs.flow_type & ~FLOW_EXT) {
> +	if (cmd->fs.flow_type & FLOW_MAC_EXT) {
> +		/* dest mac mask must be ff:ff:ff:ff:ff:ff */
> +		if (memcmp(cmd->fs.m_ext.h_dest, &full_mac, ETH_ALEN))
> +			return -EINVAL;
> +	}

etherdevice.h has is_broadcast_ether_addr() and is_zero_ether_addr() if you want
to get rid of full_mac and zero_mac in this function.

-Brian
