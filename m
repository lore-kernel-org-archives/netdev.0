From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-next-2.6] net/ethtool: Add support for the ethtool
 feature to flash firmware image from a specified file.
Date: Thu, 03 Sep 2009 01:33:01 -0400
Message-ID: <4A9F550D.1090105@pobox.com>
References: <20090903030241.GA19390@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40126 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215AbZICFdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 01:33:05 -0400
In-Reply-To: <20090903030241.GA19390@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2009 11:02 PM, Ajit Khaparde wrote:
> This patch adds support to flash a firmware image to a device using ethtool.
> The driver gets the filename of the firmware image and flashes the image
> using the request firmware path.
>
> The region "on the chip" to be flashed can be specified by an option.
> It is upto the device driver to enumerate the region number passed by ethtool,
> to the region to be flashed.
>
> The default behavior is to flash all the regions on the chip.
>
> Signed-off-by: Ajit Khaparde<ajitk@serverengines.com>
> ---
>   include/linux/ethtool.h |   14 ++++++++++++++
>   net/core/ethtool.c      |   16 ++++++++++++++++
>   2 files changed, 30 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 90c4a36..15e4eb7 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -362,6 +362,18 @@ struct ethtool_rxnfc {
>   	__u32				rule_locs[0];
>   };
>
> +#define ETHTOOL_FLASH_MAX_FILENAME	128
> +enum ethtool_flash_op_type {
> +	ETHTOOL_FLASH_ALL_REGIONS	= 0,
> +};
> +
> +/* for passing firmware flashing related parameters */
> +struct ethtool_flash {
> +	__u32	cmd;
> +	__u32	region;
> +	char	data[ETHTOOL_FLASH_MAX_FILENAME];
> +};

It passes a _filepath_ directly into the kernel?  That seems quite wrong...

we fixed kernel drivers to _not_ think they could read directly from the 
userland filesystem many years ago.

Seems like passing in an mmap'd fd would be far preferable.

	Jeff



