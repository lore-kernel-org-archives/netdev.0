From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibmveth: use consistent types
Date: Wed, 31 Dec 2008 20:06:25 +1100
Message-ID: <1230714385.15389.66.camel@pasglop>
References: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	ppc-dev <linuxppc-dev@ozlabs.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53827 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbYLaJGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 04:06:47 -0500
In-Reply-To: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-12-31 at 14:02 +1100, Stephen Rothwell wrote:
> These variables are only used with an interface involving "unsigned
> long" and the macros are only used with these variables.  This change
> will prevent some warnings when we change u64 to "unsigned long long".
> 
> This code is only built for 64bit powerpc, so the transformation is
> really a noop.

Actually, if you look at the code without the patch, the #define's are
using "ULL", which means that having the type as u64 is fine with the
change, as u64 is becoming an unsigned long long.

I don't know for sure thus what warning you are trying to fix, could you
paste it ? I suspect it's when passing those flags to a pHyp function
that takes a long, in which case, the proper fix would probably be to be
consistent the other way around, ie, make the pHyp interface take a
u64 :-)

Cheers,
Ben.

> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ibmveth.c |    4 ++--
>  drivers/net/ibmveth.h |   10 +++++-----
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
> index 9bc0f17..ca3bb9f 100644
> --- a/drivers/net/ibmveth.c
> +++ b/drivers/net/ibmveth.c
> @@ -754,7 +754,7 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
>  				    void (*done) (struct net_device *, u32))
>  {
>  	struct ibmveth_adapter *adapter = netdev_priv(dev);
> -	u64 set_attr, clr_attr, ret_attr;
> +	unsigned long set_attr, clr_attr, ret_attr;
>  	long ret;
>  	int rc1 = 0, rc2 = 0;
>  	int restart = 0;
> @@ -1209,7 +1209,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
>  	long ret;
>  	struct net_device *netdev;
>  	struct ibmveth_adapter *adapter;
> -	u64 set_attr, ret_attr;
> +	unsigned long set_attr, ret_attr;
>  
>  	unsigned char *mac_addr_p;
>  	unsigned int *mcastFilterSize_p;
> diff --git a/drivers/net/ibmveth.h b/drivers/net/ibmveth.h
> index d281869..ec76ace 100644
> --- a/drivers/net/ibmveth.h
> +++ b/drivers/net/ibmveth.h
> @@ -39,11 +39,11 @@
>  #define IbmVethMcastRemoveFilter     0x2UL
>  #define IbmVethMcastClearFilterTable 0x3UL
>  
> -#define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000ULL
> -#define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00ULL
> -#define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004ULL
> -#define IBMVETH_ILLAN_IPV4_TCP_CSUM		0x0000000000000002ULL
> -#define IBMVETH_ILLAN_ACTIVE_TRUNK		0x0000000000000001ULL
> +#define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000UL
> +#define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00UL
> +#define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004UL
> +#define IBMVETH_ILLAN_IPV4_TCP_CSUM		0x0000000000000002UL
> +#define IBMVETH_ILLAN_ACTIVE_TRUNK		0x0000000000000001UL
>  
>  /* hcall macros */
>  #define h_register_logical_lan(ua, buflst, rxq, fltlst, mac) \
> -- 
> 1.6.0.5
> 

