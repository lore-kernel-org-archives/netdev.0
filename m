From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH: 2.6.12-rc1] mii: Add test for GigE support
Date: Tue, 22 Mar 2005 18:27:47 -0500
Message-ID: <4240A9F3.5040704@pobox.com>
References: <20050322231746.GA27770@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, James Chapman <jchapman@katalix.com>
To: Dale Farnsworth <dale@farnsworth.org>
In-Reply-To: <20050322231746.GA27770@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> This patch adds the ability to test a PHY for GigE support
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> Index: linux-2.5-enet/drivers/net/mii.c
> ===================================================================
> --- linux-2.5-enet.orig/drivers/net/mii.c
> +++ linux-2.5-enet/drivers/net/mii.c
> @@ -207,6 +207,21 @@
>  	return 0;
>  }
>  
> +int mii_check_gmii_support(struct mii_if_info *mii)
> +{
> +	int reg;
> +
> +	reg = mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR);
> +	if (reg & BMSR_HAS_EXTSTAT1000) {
> +		reg = mii->mdio_read(mii->dev, mii->phy_id, MII_EXTSTAT1000);
> +		if (reg & (ESR_1000_BASE_X_FD | ESR_1000_BASE_T_FD |
> +			   ESR_1000_BASE_X_HD | ESR_1000_BASE_T_HD))
> +			return 1;
> +	}
> +
> +	return 0;

Two comments:

1) you need to add EXPORT_SYMBOL() when adding new API functions (see 
the bottom of the file).

2) Reading a non-existent register will return all 1's in most cases, so 
I am not sure if this is the best test.

	Jeff
