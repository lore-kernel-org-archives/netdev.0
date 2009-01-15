From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] fec: do not use memcpy on physical addresses
Date: Thu, 15 Jan 2009 13:55:44 +1000
Message-ID: <496EB3C0.2090002@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-5-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:46660 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752350AbZAODzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 22:55:46 -0500
In-Reply-To: <1231949353-29630-5-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sacha,

Sascha Hauer wrote:
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---

Also fine for ColdFire.

Acked-by: Greg Ungerer <gerg@uclinux.org>



>  drivers/net/fec.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 1a07d56..29df0df 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -339,7 +339,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (bdp->cbd_bufaddr & 0x3) {
>  		unsigned int index;
>  		index = bdp - fep->tx_bd_base;
> -		memcpy(fep->tx_bounce[index], (void *) bdp->cbd_bufaddr, bdp->cbd_datlen);
> +		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
>  		bdp->cbd_bufaddr = __pa(fep->tx_bounce[index]);
>  	}
>  

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
