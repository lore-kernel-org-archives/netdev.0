From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC 06/10] dpaa_eth: add ethtool functionality
Date: Wed, 01 Apr 2015 10:11:39 -0700
Message-ID: <1427908299.31790.51.camel@perches.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-2-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-3-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-4-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-5-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905196-27778-5-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> Add support for basic ethtool operations.

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
[]
> +static int __cold dpa_get_settings(struct net_device *net_dev,
> +				   struct ethtool_cmd *et_cmd)
> +{
> +	int			 _errno;

Using a variable name of _errno is misleading at best,
(btw: the only return value for phy_ethtool_gset is 0)

> +static void __cold dpa_get_drvinfo(struct net_device *net_dev,
> +				   struct ethtool_drvinfo *drvinfo)
> +{
> +	int		 _errno;
> +
> +	strncpy(drvinfo->driver, KBUILD_MODNAME,
> +		sizeof(drvinfo->driver) - 1)[sizeof(drvinfo->driver) - 1] = 0;

That's a really odd and unusual construct
more commonly written as strlcpy

> +	_errno = snprintf(drvinfo->version, sizeof(drvinfo->version),

Using errno here is especially misleading as that's
not the return value of an snprintf
