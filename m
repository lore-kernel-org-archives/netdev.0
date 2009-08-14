From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] net/ethtool: Add support to the ethtool
	feature to flash firmware image from a specified file.
Date: Fri, 14 Aug 2009 21:58:57 +0100
Message-ID: <1250283537.2782.3.camel@achroite>
References: <20090814173314.GA26218@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:57752 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752242AbZHNU7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 16:59:06 -0400
In-Reply-To: <20090814173314.GA26218@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-14 at 23:03 +0530, Ajit Khaparde wrote:
> This patch adds support to flash a firmware image to a device using ethtool.
> The driver gets the filename of the firmware image and flashes this image
> using the request_firmware() path.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
>  include/linux/ethtool.h |    8 ++++++++
>  net/core/ethtool.c      |   17 +++++++++++++++++
>  2 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 90c4a36..243cdce 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -362,6 +362,12 @@ struct ethtool_rxnfc {
>  	__u32				rule_locs[0];
>  };
>  
> +/* for passing firmware flashing related parameters */
> +struct ethtool_flash {
> +	__u32	cmd;
> +	__u8	*data;

There also needs to be some sort of identifier to distinguish different
flash regions.

[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -898,6 +898,20 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
>  	return actor(dev, edata.data);
>  }
>  
> +static int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
> +{
> +	int err;
> +	struct ethtool_flash efl;
> +
> +	if (copy_from_user(&efl, useraddr, sizeof(efl)))
> +		return -EFAULT;
[...]

This leaves efl.data as a user-space pointer, not a kernel-space
pointer.  The string will then also need to be copied.  It's simpler to
embed the string in the structure, though that means putting a limit on
the string length.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

