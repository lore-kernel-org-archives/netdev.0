From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Fix SJA1000 command register writes on SMP systems
Date: Mon, 17 May 2010 22:34:15 -0700 (PDT)
Message-ID: <20100517.223415.184853371.davem@davemloft.net>
References: <4BF1A464.6070207@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45286
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754802Ab0ERFeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:34:06 -0400
In-Reply-To: <4BF1A464.6070207@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 17 May 2010 22:17:40 +0200

> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
> index 145b1a7..2760085 100644
> --- a/drivers/net/can/sja1000/sja1000.c
> +++ b/drivers/net/can/sja1000/sja1000.c
> @@ -84,6 +84,27 @@ static struct can_bittiming_const sja1000_bittiming_const = {
>  	.brp_inc = 1,
>  };
>  +static void sja1000_write_cmdreg(struct sja1000_priv *priv, u8 val)
> +{
> +	/* the command register needs some locking on SMP systems */
> +
> +#ifdef CONFIG_SMP

Something is adding spurious leading spaces to lines in your patch.

Also, please don't SMP conditionalize this code.  It makes it such that
lock debugging et al. can't be used to check this code on uniprocessor.
