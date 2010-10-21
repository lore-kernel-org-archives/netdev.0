From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 09/14] bnx2: Update bnx2 to use new vlan accleration.
Date: Thu, 21 Oct 2010 16:31:46 +0100
Message-ID: <1287675106.2235.10.camel@achroite.uk.solarflarecom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	 <1287618974-4714-10-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8598 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192Ab0JUPbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:31:50 -0400
In-Reply-To: <1287618974-4714-10-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
> Make the bnx2 driver use the new vlan accleration model.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |   97 +++++++++++++++-------------------------------------
>  drivers/net/bnx2.h |    4 --
>  2 files changed, 28 insertions(+), 73 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 363ca8b..bf3c830 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
[...]
> @@ -7578,7 +7523,28 @@ bnx2_set_tx_csum(struct net_device *dev, u32 data)
>  static int
>  bnx2_set_flags(struct net_device *dev, u32 data)
>  {
> -	return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
> +	struct bnx2 *bp = netdev_priv(dev);
> +	int rc;
> +
> +	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN) &&
> +	    !(data & ETH_FLAG_RXVLAN))
> +		return -EOPNOTSUPP;
[...]

Should be -EINVAL.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

