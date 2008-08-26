From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ixgbe: fix vlan filtering
Date: Tue, 26 Aug 2008 16:50:04 -0700
Message-ID: <20080826165004.6467918d.akpm@linux-foundation.org>
References: <20080822010128.5002.2293.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47576 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751068AbYHZXvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 19:51:12 -0400
In-Reply-To: <20080822010128.5002.2293.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2008 18:01:28 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> there are not vlan filter settings in the fctrl register.

Guys, this is a crap changelog.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 34bca16..53f41b6 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1636,16 +1636,17 @@ static void ixgbe_set_multi(struct net_device *netdev)
>  	struct ixgbe_hw *hw = &adapter->hw;
>  	struct dev_mc_list *mc_ptr;
>  	u8 *mta_list;
> -	u32 fctrl;
> +	u32 fctrl, vlnctrl;
>  	int i;
>  
>  	/* Check for Promiscuous and All Multicast modes */
>  
>  	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
> +	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
>  
>  	if (netdev->flags & IFF_PROMISC) {
>  		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
> -		fctrl &= ~IXGBE_VLNCTRL_VFE;
> +		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
>  	} else {
>  		if (netdev->flags & IFF_ALLMULTI) {
>  			fctrl |= IXGBE_FCTRL_MPE;
> @@ -1653,10 +1654,11 @@ static void ixgbe_set_multi(struct net_device *netdev)
>  		} else {
>  			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
>  		}
> -		fctrl |= IXGBE_VLNCTRL_VFE;
> +		vlnctrl |= IXGBE_VLNCTRL_VFE;
>  	}
>  
>  	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
> +	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
>  
>  	if (netdev->mc_count) {
>  		mta_list = kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);
> 

There's no way for me (at least) to judge the importance of this patch.
Maybe Jeff happens to know enough about this driver and the proposed
change to be able to work this out, but why risk it?

How long does it take to write a halfway respectable changelog?  Sixty
seconds?

A patch which purportedly fixes a bug should at the very least explain
the user-visible consequences of the bug.  That helps people to understand
the priority of the fix, and helps them to decide which kernel versions
it should be merged into.

Also, the fix _appears_ to be applicable to 2.6.26.x, 2.6.25.x and
perhaps earlier.  But for some reason which I didn't look into it does
not apply there.  It is valuable if the patch originator can provide
advice about which stable kernels (if any) they think the patch should
be backported into.

Thanks.
