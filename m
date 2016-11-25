From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v1] ethtool: implement helper to get flow_type value
Date: Fri, 25 Nov 2016 16:06:34 -0500 (EST)
Message-ID: <20161125.160634.944615331208897862.davem@davemloft.net>
References: <20161122234453.31611-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbcKYVI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:08:27 -0500
In-Reply-To: <20161122234453.31611-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Tue, 22 Nov 2016 15:44:53 -0800

> @@ -880,6 +880,14 @@ struct ethtool_rx_flow_spec {
>  	__u32		location;
>  };
>  
> +/* Flag to enable additional fields in struct ethtool_rx_flow_spec */
> +#define	FLOW_EXT	0x80000000
> +#define	FLOW_MAC_EXT	0x40000000
> +static inline __u32 ethtool_get_flow_spec_type(__u32 flow_type)
> +{
> +	return flow_type & (FLOW_EXT | FLOW_MAC_EXT);
> +}
> +
>  /* How rings are layed out when accessing virtual functions or
>   * offloaded queues is device specific. To allow users to do flow
>   * steering and specify these queues the ring cookie is partitioned
> @@ -1579,9 +1587,6 @@ static inline int ethtool_validate_duplex(__u8 duplex)
>  #define	IPV4_FLOW	0x10	/* hash only */
>  #define	IPV6_FLOW	0x11	/* hash only */
>  #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
> -/* Flag to enable additional fields in struct ethtool_rx_flow_spec */
> -#define	FLOW_EXT	0x80000000
> -#define	FLOW_MAC_EXT	0x40000000
>  
>  /* L3-L4 network traffic flow hash options */
>  #define	RXH_L2DA	(1 << 1)

Please put the helper after the FLOW_* definitions rather than moving
them earlier in the file.
