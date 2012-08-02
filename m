From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 05/12] net: Add ndo_set_vif_param operation to serve
 eIPoIB VIFs
Date: Thu, 2 Aug 2012 01:17:02 +0100
Message-ID: <1343866622.2602.62.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	 <1343840975-3252-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21211 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750983Ab2HBARH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 20:17:07 -0400
In-Reply-To: <1343840975-3252-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-01 at 20:09 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> The Ethernet IPoIB driver enslaves IPoIB devices and uses them as
> VIFs (Virtual Interface) which serve an Ethernet NIC e.g present in a 
> guest OS. For each such slave that acts as a VIF, eIPoIB needs to know 
> the mac and optionally the vlan uses by that NIC, the new ndo opertaion 
> is used to associate the mac/vlan for that slave.
> 
> Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  include/linux/netdevice.h |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index eb06e58..2709551 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1013,7 +1013,10 @@ struct net_device_ops {
>  						    netdev_features_t features);
>  	int			(*ndo_neigh_construct)(struct neighbour *n);
>  	void			(*ndo_neigh_destroy)(struct neighbour *n);
> -
> +	int			(*ndo_set_vif_param) (struct net_device *dev,
> +						      struct net_device *vif,
> +						      u16 vlan,
> +						      u8 *mac);

The semantics of this operation should be documented in the comment
above the structure definition.  One detail worth covering is whether
'vlan' is just a VID or can also include priority+CFI bits.

If this is specific to eIPoIB, why not put that in the name of the
operation?  If not, this *really* needs explaining because so far I have
no whether it is something I should consider implementing on a real
Ethernet device.

Ben.

>  	int			(*ndo_fdb_add)(struct ndmsg *ndm,
>  					       struct net_device *dev,
>  					       unsigned char *addr,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
