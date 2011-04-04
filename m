From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 02/12] skge: implement set_phys_id
Date: Mon, 04 Apr 2011 23:57:32 +0100
Message-ID: <1301957852.2935.54.camel@localhost>
References: <20110404184340.604594357@linuxplumber.net>
	 <20110404184501.450494215@linuxplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37773 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab1DDW5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 18:57:35 -0400
In-Reply-To: <20110404184501.450494215@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 11:43 -0700, Stephen Hemminger wrote:
> Implement set_phys_id led control on SysKonnect board.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/skge.c	2011-04-04 10:48:15.713539204 -0700
> +++ b/drivers/net/skge.c	2011-04-04 10:50:07.387094723 -0700
> @@ -786,29 +786,28 @@ static void skge_led(struct skge_port *s
>  }
>  
>  /* blink LED's for finding board */
> -static int skge_phys_id(struct net_device *dev, u32 data)
> +static int skge_set_phys_id(struct net_device *dev,
> +			    enum ethtool_phys_id_state state)
>  {
>  	struct skge_port *skge = netdev_priv(dev);
> -	unsigned long ms;
> -	enum led_mode mode = LED_MODE_TST;
>  
> -	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
> -		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT / HZ) * 1000;
> -	else
> -		ms = data * 1000;
> -
> -	while (ms > 0) {
> -		skge_led(skge, mode);
> -		mode ^= LED_MODE_TST;
> -
> -		if (msleep_interruptible(BLINK_MS))
> -			break;
> -		ms -= BLINK_MS;
> +	switch (state) {
> +	case ETHTOOL_ID_ACTIVE:
> +		return -1;
[...]

Must be -EINVAL.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

