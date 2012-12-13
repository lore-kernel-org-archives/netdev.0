From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: ethool: Document struct ethtool_flow_ext
Date: Thu, 13 Dec 2012 16:27:27 +0000
Message-ID: <1355416047.2623.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1355412059-25663-1-git-send-email-yanb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, <netdev@vger.kernel.org>
To: Yan Burman <yanb@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48863 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262Ab2LMQ1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 11:27:33 -0500
In-Reply-To: <1355412059-25663-1-git-send-email-yanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 17:20 +0200, Yan Burman wrote:
> Add documentation for struct ethtool_flow_ext especially in regard
> to what flags are needed for which fields.
> 
> Signed-off-by: Yan Burman <yanb@mellanox.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

David, please apply this to 'net' so that FLOW_MAC_EXT is properly
documented in 3.8.

Ben.

> ---
>  include/uapi/linux/ethtool.h | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index be8c41e..0c9b448 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -503,9 +503,20 @@ union ethtool_flow_union {
>  	__u8					hdata[52];
>  };
>  
> +/**
> + * struct ethtool_flow_ext - additional RX flow fields
> + * @h_dest: destination MAC address
> + * @vlan_etype: VLAN EtherType
> + * @vlan_tci: VLAN tag control information
> + * @data: user defined data
> + *
> + * Note, @vlan_etype, @vlan_tci, and @data are only valid if %FLOW_EXT
> + * is set in &struct ethtool_rx_flow_spec @flow_type.
> + * @h_dest is valid if %FLOW_MAC_EXT is set.
> + */
>  struct ethtool_flow_ext {
>  	__u8		padding[2];
> -	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
> +	unsigned char	h_dest[ETH_ALEN];
>  	__be16		vlan_etype;
>  	__be16		vlan_tci;
>  	__be32		data[2];
> @@ -519,7 +530,8 @@ struct ethtool_flow_ext {
>   * @m_u: Masks for flow field bits to be matched
>   * @m_ext: Masks for additional field bits to be matched
>   *	Note, all additional fields must be ignored unless @flow_type
> - *	includes the %FLOW_EXT flag.
> + *	includes the %FLOW_EXT or %FLOW_MAC_EXT flag
> + *	(see &struct ethtool_flow_ext description).
>   * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
>   *	if packets should be discarded
>   * @location: Location of rule in the table.  Locations must be

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
