From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: Make temperature warnings/alarms more explicit.
Date: Thu, 30 Apr 2009 02:25:54 +0100
Message-ID: <1241054754.22157.22.camel@deadeye>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite>
	 <1240929844.10689.35.camel@localhost.localdomain>
	 <1240930084.10689.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33960 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111AbZD3BZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 21:25:58 -0400
In-Reply-To: <1240930084.10689.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-28 at 16:48 +0200, Jesper Dangaard Brouer wrote:
> The sfc driver can detect different hardware failures via the
> LM87 system.  One of the failures I have experienced is the
> temperature alarm, but the error message didn't reveal that this
> error was temperature related.  I had to read the code to
> discover that.
> 
> I think that the temperature error should be more explicit, in
> order to warn people before the board is permanently damaged.

You are right, but...

> diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
> index 4a4c74c..b1822fe 100644
> --- a/drivers/net/sfc/boards.c
> +++ b/drivers/net/sfc/boards.c
> @@ -121,8 +121,10 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
>  	if (alarms1 || alarms2) {
>  		EFX_ERR(efx,
>  			"LM87 detected a hardware failure (status %02x:%02x)"
> -			"%s%s\n",
> +			"%s%s%s\n",
>  			alarms1, alarms2,
> +			(alarms1 & (LM87_ALARM_TEMP_INT|LM87_ALARM_TEMP_EXT1))
> +			 ? " high temperature" : "",
>  			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
>  			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
>  		return -ERANGE;

We could be more explicit still.  How about:

		EFX_ERR(efx,
			"%s out of range (LM87 status %02x:%02x)\n",
			(alarms1 & LM87_ALARM_TEMP_INT) ? "Board temperature" :
			(alarms1 & LM87_ALARM_TEMP_EXT1) ? "Controller temperature :
			"Voltage",
			alarms1, alarms2);

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
