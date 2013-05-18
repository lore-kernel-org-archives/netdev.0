From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/4] tg3: Implement set/get_eee handlers
Date: Sat, 18 May 2013 02:08:36 +0100
Message-ID: <1368839316.3469.69.camel@deadeye.wl.decadent.org.uk>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
	 <1368803990-10098-5-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7189 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3ERBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:08:40 -0400
In-Reply-To: <1368803990-10098-5-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 08:19 -0700, Nithin Nayak Sujir wrote:
> Reviewed-by: Ben Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 47 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 3aeb98f..7d4f664 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -13657,6 +13657,51 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
>  	return 0;
>  }
>  
> +static int tg3_set_eee(struct net_device *dev, struct ethtool_eee *edata)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +
> +	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP)) {
> +		netdev_warn(tp->dev,
> +			    "Board does not support EEE!\n");
> +		return -EOPNOTSUPP;
> +	}
> +
> +	if (edata->advertised != tp->eee.advertised) {
> +		netdev_warn(tp->dev,
> +			    "Direct manipulation of EEE advertisement is not supported\n");
> +		return -EINVAL;
> +	}
[...]

This should also check that edata->tx_lpi_timer is within the valid
range (16-bit, if I read your first patch right).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
