From: Javier Achirica <achirica@telefonica.net>
Subject: Re: [PATCH 2.6] airo.c set_bit bug
Date: Tue, 3 Aug 2004 02:12:09 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SOL.4.30.0408030211140.13100-100000@tudela.mad.ttd.net>
References: <20040723002114.GA11815@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <jt@hpl.hp.com>
In-Reply-To: <20040723002114.GA11815@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks. Applied. I haven't found any other occurrence.

Javier Achirica

On Thu, 22 Jul 2004, Jean Tourrilhes wrote:

> 	Hi Javier,
>
> 	Managed to find a bug in the usage of set_bit/clear_bit in the
> airo driver. I'm not sure if I caught all occurence of this pattern,
> and not sure about exact consequences of the bug, but we might as well
> fix it...
> 	Patch below...
>
> 	Have fun...
>
> 	Jean
>
> --------------------------------------------------------
>
> --- linux/drivers/net/wireless/airo.j1.c	Thu Jul 22 15:27:48 2004
> +++ linux/drivers/net/wireless/airo.c	Thu Jul 22 15:29:11 2004
> @@ -1808,7 +1808,8 @@ static int writeConfigRid(struct airo_in
>  	if (!test_bit (FLAG_COMMIT, &ai->flags))
>  		return SUCCESS;
>
> -	clear_bit (FLAG_COMMIT | FLAG_RESET, &ai->flags);
> +	clear_bit (FLAG_COMMIT, &ai->flags);
> +	clear_bit (FLAG_RESET, &ai->flags);
>  	checkThrottle(ai);
>  	cfgr = ai->config;
>
> @@ -6158,7 +6159,8 @@ static int airo_set_txpow(struct net_dev
>  	readCapabilityRid(local, &cap_rid);
>
>  	if (vwrq->disabled) {
> -		set_bit (FLAG_RADIO_OFF | FLAG_COMMIT, &local->flags);
> +		set_bit (FLAG_RADIO_OFF, &local->flags);
> +		set_bit (FLAG_COMMIT, &local->flags);
>  		return -EINPROGRESS;		/* Call commit handler */
>  	}
>  	if (vwrq->flags != IW_TXPOW_MWATT) {
>
