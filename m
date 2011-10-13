From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] netdev/phy: Handle IEEE802.3 clause 45 Ethernet PHYs
Date: Wed, 12 Oct 2011 18:21:11 -0600
Message-ID: <20111013002111.GA14042@ponder.secretlab.ca>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
 <1318442783-29058-2-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, afleming@gmail.com
To: David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59239 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab1JMCZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 22:25:39 -0400
Content-Disposition: inline
In-Reply-To: <1318442783-29058-2-git-send-email-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 11:06:21AM -0700, David Daney wrote:
> The IEEE802.3 clause 45 MDIO bus protocol allows for directly
> addressing PHY registers using a 21 bit address, and is used by many
> 10G Ethernet PHYS.  Already existing is the ability of MDIO bus
> drivers to use clause 45, with the MII_ADDR_C45 flag.  Here we add
> some support in the PHY and device tree infrastructure to use these
> PHYs.
> 
> Normally the MII_ADDR_C45 flag is ORed with the register address to
> indicate a clause 45 transaction.  Here we also use this flag in the
> *device* address passed to get_phy_id() and get_phy_device() to
> indicate that probing should be done with clause 45 transactions.  If
> a PHY is successfully probed with MII_ADDR_C45, the new struct
> phy_device is_c45 flag is set for the PHY.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Minor comment below, but otherwise,

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index e4c3844..0a25e2c 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -246,6 +246,7 @@ struct sk_buff;
>   * phy_id: UID for this device found during discovery
>   * state: state of the PHY for management purposes
>   * dev_flags: Device-specific flags used by the PHY driver.
> + * is_c45:  Set to 1 if this phy uses clause 45 addressing.

"Set to true if ..."

>   * addr: Bus address of PHY
>   * link_timeout: The number of timer firings to wait before the
>   * giving up on the current attempt at acquiring a link
> @@ -283,6 +284,8 @@ struct phy_device {
>  
>  	u32 dev_flags;
>  
> +	unsigned int is_c45:1;
> +

bool

>  	phy_interface_t interface;
>  
>  	/* Bus address of the PHY (0-31) */
> -- 
> 1.7.2.3
> 
