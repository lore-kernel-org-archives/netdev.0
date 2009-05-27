From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 2/4] ixgbe: fix driver loading with
 unsupported module on 82598
Date: Wed, 27 May 2009 02:28:57 +0100
Message-ID: <1243387737.16597.140.camel@deadeye>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
	 <20090527005423.28535.1960.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56015 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752771AbZE0B3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 21:29:05 -0400
In-Reply-To: <20090527005423.28535.1960.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-26 at 17:54 -0700, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Driver loads even when an unsupported module inserted.

Why not; they're hot-pluggable.

> This was
> caused by mdio45_probe not returning all the information we needed.
> The fix is to replace that call with the new
> ixgbe_validate_phy_addr().

You could improve mdio45_probe()...

> We will now need to store the phy address which we do in the hw->phy
> struct. Likewise we no longer need the mdio struct in hw->phy along
> with the mdio functions ixgbe_mdio_write(read) which have been
> removed.  ixgbe_ioctl was no longer used and referenced hw->phy.mdio
> so it was also removed.

The ioctl is for the benefit of user-space!

[...]
> diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
> index ba3ed0f..00c23be 100644
> --- a/drivers/net/ixgbe/ixgbe_type.h
> +++ b/drivers/net/ixgbe/ixgbe_type.h
> @@ -915,6 +915,7 @@
>  #define IXGBE_CORECTL_WRITE_CMD         0x00010000
>  
>  /* MDIO definitions */
> +#define IXGBE_MDIO_PMA_PMD_DEV_TYPE    0x1

This is called MDIO_MMD_PMAPMD.
 
>  #define IXGBE_MDIO_COMMAND_TIMEOUT     100 /* PHY Timeout for 1 GB mode */
>  
> @@ -925,6 +926,8 @@
>  #define IXGBE_MDIO_VENDOR_SPECIFIC_1_10G_SPEED    0x0018
>  #define IXGBE_MDIO_VENDOR_SPECIFIC_1_1G_SPEED     0x0010
>  
> +#define IXGBE_MDIO_PHY_ID_HIGH              0x2    /* PHY ID High Reg */
> +

This is called MDIO_DEVID1.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
