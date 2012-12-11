From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add destination MAC address
 to flow steering API
Date: Tue, 11 Dec 2012 09:37:50 -0800
Message-ID: <50C76F6E.2010600@intel.com>
References: <1355227436-18383-1-git-send-email-amirv@mellanox.com> <1355227436-18383-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64300 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab2LKRhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 12:37:52 -0500
In-Reply-To: <1355227436-18383-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2012 04:03 AM, Amir Vadai wrote:
> From: Yan Burman <yanb@mellanox.com>
> 
> Add ability to specify destination MAC address for L3/L4 flow spec
> in order to be able to specify action for different VM's under vSwitch
> configuration. This change is transparent to older userspace.
> 
> Signed-off-by: Yan Burman <yanb@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  include/uapi/linux/ethtool.h | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index d3eaaaf..be8c41e 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -500,13 +500,15 @@ union ethtool_flow_union {
>  	struct ethtool_ah_espip4_spec		esp_ip4_spec;
>  	struct ethtool_usrip4_spec		usr_ip4_spec;
>  	struct ethhdr				ether_spec;
> -	__u8					hdata[60];
> +	__u8					hdata[52];
>  };
>  
>  struct ethtool_flow_ext {
> -	__be16	vlan_etype;
> -	__be16	vlan_tci;
> -	__be32	data[2];
> +	__u8		padding[2];
> +	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
> +	__be16		vlan_etype;
> +	__be16		vlan_tci;
> +	__be32		data[2];
>  };
>  

Is there any special reason why you need to change the size of this
structure?  It seems like you could probably just replace the data
section with a union containing either 8 bytes of user specified data or
your MAC address data.  Then we wouldn't need all of the changes to the
rest of the flow specifier.

Thanks,

Alex
