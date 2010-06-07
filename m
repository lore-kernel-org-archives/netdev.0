From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: Re: [PATCH] [ath5k][leds] Ability to disable leds support. If leds
	support enabled do not force mac802.11 leds layer selection.
Date: Mon, 7 Jun 2010 10:39:03 +0300
Message-ID: <AANLkTilPVWvsgXkriz68lLl6e8Qslm_wMkHpkhEdWC3_@mail.gmail.com>
References: <4c0902ef.0a41df0a.6c86.2df0@mx.google.com> <1275668535.17251.20.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: Pavel Roskin <proski@gnu.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275668535.17251.20.camel@mj>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel, thank you for the response here.

I agree with all your comments and will adjust the patch according to t=
hem.

I'm new to the submitting patches into the community and I appreciate
telling criticism so that in future I will not cause that much
troubles.

Regards,

-- Dima

On Fri, Jun 4, 2010 at 7:22 PM, Pavel Roskin <proski@gnu.org> wrote:
> On Fri, 2010-06-04 at 16:43 +0300, Dmytro Milinevskyy wrote:
>> Hi!
>>
>> Here is the patch to disable ath5k leds support on build stage.
>> However if the leds support was enabled do not force selection of 80=
2.11 leds layer.
>> Depency on LEDS_CLASS is kept.
>>
>> Suggestion given by Pavel Roskin and Bob Copeland applied.
>
> It's great that you did it. =A0The patch is much clearer now. =A0That=
 makes
> smaller issues visible. =A0Please don't be discouraged by the critici=
sm,
> you are on the right track.
>
> First of all, your patch doesn't apply cleanly to the current
> wireless-testing because of formatting changes in Makefile. =A0Please
> update.
>
>> +config ATH5K_LEDS
>> + =A0 =A0 =A0 tristate "Atheros 5xxx wireless cards LEDs support"
>> + =A0 =A0 =A0 depends on ATH5K
>> + =A0 =A0 =A0 select NEW_LEDS
>> + =A0 =A0 =A0 select LEDS_CLASS
>> + =A0 =A0 =A0 ---help---
>> + =A0 =A0 =A0 =A0 Atheros 5xxx LED support.
>
> "tristate" is wrong here. =A0"tristate" would allow users select "m",
> which is wrong, since LED support is not a separate module. =A0I thin=
k you
> want "bool" here.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0/*
>> =A0 * State for LED triggers
>> =A0 */
>> @@ -95,6 +96,7 @@ struct ath5k_led
>> =A0 =A0 =A0 struct ath5k_softc *sc; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
/* driver state */
>> =A0 =A0 =A0 struct led_classdev led_dev; =A0 =A0 =A0 =A0 =A0 =A0/* l=
ed classdev */
>> =A0};
>> +#endif
>
> This shouldn't be needed. =A0I'll rather see a structure that is not =
used
> in some cases than an extra pair of preprocessor conditionals.
>
>> diff --git a/drivers/net/wireless/ath/ath5k/gpio.c b/drivers/net/wir=
eless/ath/ath5k/gpio.c
>> index 64a27e7..9e757b3 100644
>> --- a/drivers/net/wireless/ath/ath5k/gpio.c
>> +++ b/drivers/net/wireless/ath/ath5k/gpio.c
>> @@ -25,6 +25,7 @@
>> =A0#include "debug.h"
>> =A0#include "base.h"
>>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0/*
>> =A0 * Set led state
>> =A0 */
>> @@ -76,6 +77,7 @@ void ath5k_hw_set_ledstate(struct ath5k_hw *ah, un=
signed int state)
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, le=
d_5210);
>> =A0}
>> +#endif
>
> I would just move that function to led.c (and don't forget to include
> reg.h). =A0The Makefile should take care of the rest.
>
> --
> Regards,
> Pavel Roskin
>
