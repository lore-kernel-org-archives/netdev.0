From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] [ath5k][leds] Ability to disable leds support. If leds
 support enabled do not force mac802.11 leds layer selection.
Date: Fri, 04 Jun 2010 12:22:15 -0400
Message-ID: <1275668535.17251.20.camel@mj>
References: <4c0902ef.0a41df0a.6c86.2df0@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel@lists.ath5k.org, Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmytro Milinevskyy <milinevskyy@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4c0902ef.0a41df0a.6c86.2df0@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-06-04 at 16:43 +0300, Dmytro Milinevskyy wrote:
> Hi!
> 
> Here is the patch to disable ath5k leds support on build stage.
> However if the leds support was enabled do not force selection of 802.11 leds layer.
> Depency on LEDS_CLASS is kept.
> 
> Suggestion given by Pavel Roskin and Bob Copeland applied.

It's great that you did it.  The patch is much clearer now.  That makes
smaller issues visible.  Please don't be discouraged by the criticism,
you are on the right track.

First of all, your patch doesn't apply cleanly to the current
wireless-testing because of formatting changes in Makefile.  Please
update.

> +config ATH5K_LEDS
> +       tristate "Atheros 5xxx wireless cards LEDs support"
> +       depends on ATH5K
> +       select NEW_LEDS
> +       select LEDS_CLASS
> +       ---help---
> +         Atheros 5xxx LED support.

"tristate" is wrong here.  "tristate" would allow users select "m",
which is wrong, since LED support is not a separate module.  I think you
want "bool" here.

> +#ifdef CONFIG_ATH5K_LEDS
>  /*
>   * State for LED triggers
>   */
> @@ -95,6 +96,7 @@ struct ath5k_led
>  	struct ath5k_softc *sc;			/* driver state */
>  	struct led_classdev led_dev;		/* led classdev */
>  };
> +#endif

This shouldn't be needed.  I'll rather see a structure that is not used
in some cases than an extra pair of preprocessor conditionals.

> diff --git a/drivers/net/wireless/ath/ath5k/gpio.c b/drivers/net/wireless/ath/ath5k/gpio.c
> index 64a27e7..9e757b3 100644
> --- a/drivers/net/wireless/ath/ath5k/gpio.c
> +++ b/drivers/net/wireless/ath/ath5k/gpio.c
> @@ -25,6 +25,7 @@
>  #include "debug.h"
>  #include "base.h"
>  
> +#ifdef CONFIG_ATH5K_LEDS
>  /*
>   * Set led state
>   */
> @@ -76,6 +77,7 @@ void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state)
>  	else
>  		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, led_5210);
>  }
> +#endif

I would just move that function to led.c (and don't forget to include
reg.h).  The Makefile should take care of the rest.

-- 
Regards,
Pavel Roskin
