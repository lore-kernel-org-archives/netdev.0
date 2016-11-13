From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 03/10] dpaa_eth: add option to use one
 buffer pool set
Date: Sun, 13 Nov 2016 12:46:17 -0500 (EST)
Message-ID: <20161113.124617.2176429700446266337.davem@davemloft.net>
References: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
        <1478852407-27420-4-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
        joakim.tjernlund@infinera.com
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478852407-27420-4-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Fri, 11 Nov 2016 10:20:00 +0200

> @@ -8,3 +8,12 @@ menuconfig FSL_DPAA_ETH
>  	  supporting the Freescale QorIQ chips.
>  	  Depends on Freescale Buffer Manager and Queue Manager
>  	  driver and Frame Manager Driver.
> +
> +if FSL_DPAA_ETH
> +config FSL_DPAA_ETH_COMMON_BPOOL
> +	bool "Use a common buffer pool set for all the interfaces"
> +	---help---
> +	  The DPAA Ethernet netdevices require buffer pools for storing the buffers
> +	  used by the FMan hardware for reception. One can use a single buffer pool
> +	  set for all interfaces or a dedicated buffer pool set for each interface.
> +endif # FSL_DPAA_ETH

This in no way belongs in Kconfig.  If you want to support this,
support it wit a run time configuration choice via ethtool flags
or similar.  Do not use debugfs, do not use sysfs, do not use
module options.

If you put it in Kconfig, distributions will have to pick one way or
another which means that users who want the other choice lose.  This
never works.
