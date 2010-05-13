From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
	support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Thu, 13 May 2010 10:36:56 +0300
Message-ID: <AANLkTinYfKlQ-MzkGV9o2qXUTeArYscfqoc8WS7SRjgz@mail.gmail.com>
References: <4bea1f81.09b6660a.746e.1c12@mx.google.com> <1273679336.10823.15.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ath5k-devel@lists.ath5k.org, Kalle Valo <kalle.valo@iki.fi>,
	linux-wireless@vger.kernel.org,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	netdev@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-kernel@vger.kernel.org, Luca Verdesca <magooz@salug.it>
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53644 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514Ab0EMHhS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 03:37:18 -0400
In-Reply-To: <1273679336.10823.15.camel@mj>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Pavel.

I will rework the patch considering your suggestions.

> I'm not sure this complexity is needed.  Are you going to support LED=
s
> if CONFIG_LEDS_CLASS is disabled?
If there's any other place in driver that might want use LEDs w/o
exporting the interface to the userspace.

-- Dima Milinevskyy


On Wed, May 12, 2010 at 6:48 PM, Pavel Roskin <proski@gnu.org> wrote:
> On Wed, 2010-04-07 at 21:58 +0300, Dmytro Milinevskyy wrote:
>
>> Here is the patch to disable ath5k leds support on build stage.
>> However if the leds support was enabled do not force selection of 80=
2.11 leds layer.
>
> The idea is good, but the implementation could be improved.
>
> There are too many preprocessor conditionals in your patch.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0/*
>> =A0 * These match net80211 definitions (not used in
>> =A0 * mac80211).
>> @@ -939,11 +940,7 @@ enum ath5k_power_mode {
>> =A0#define AR5K_LED_AUTH =A0 =A0 =A0 =A02 /*IEEE80211_S_AUTH*/
>> =A0#define AR5K_LED_ASSOC =A0 =A0 =A0 3 /*IEEE80211_S_ASSOC*/
>> =A0#define AR5K_LED_RUN 4 /*IEEE80211_S_RUN*/
>
> It should be OK to leave the constants defined even if they are not
> used.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0/* LED functions */
>> =A0extern int ath5k_init_leds(struct ath5k_softc *sc);
>> =A0extern void ath5k_led_enable(struct ath5k_softc *sc);
>> =A0extern void ath5k_led_off(struct ath5k_softc *sc);
>> =A0extern void ath5k_unregister_leds(struct ath5k_softc *sc);
>> +#endif
>
> You could add inline functions for the case when CONFIG_ATH5K_LEDS is
> not defined. =A0That would avoid may conditionals in the code.
>
>> =A0/* GPIO Functions */
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0extern void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned i=
nt state);
>> +#endif
>
> The same comment applies.
>
> Also, there is nothing wrong with having an external declaration that=
 is
> not used in some particular configuration.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0 =A0 =A0 /* turn on HW LEDs */
>> =A0 =A0 =A0 ath5k_hw_set_ledstate(ah, AR5K_LED_INIT);
>> +#endif
>
> This is avoidable by having an inline ath5k_hw_set_ledstate() that do=
es
> nothing.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0 =A0 =A0 struct ieee80211_hw *hw =3D pci_get_drvdata(to_pci_dev(d=
ev));
>> =A0 =A0 =A0 struct ath5k_softc *sc =3D hw->priv;
>>
>> =A0 =A0 =A0 ath5k_led_off(sc);
>> +#endif
>
> Even this is avoidable if ath5k_led_off() does nothing. =A0gcc should=
 be
> smart enough to optimize out unneeded function calls.
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0/*
>> =A0 * State for LED triggers
>> =A0 */
>> =A0struct ath5k_led
>> =A0{
>> +#ifdef CONFIG_LEDS_CLASS
>
> I'm not sure this complexity is needed. =A0Are you going to support L=
EDs
> if CONFIG_LEDS_CLASS is disabled?
>
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0led_pin, =A0 =A0 =A0=
 =A0/* GPIO pin for driving LED */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 led_on; =
=A0 =A0 =A0 =A0 /* pin setting for LED on */
>> +#endif
>>
>> =A0 =A0 =A0 struct tasklet_struct =A0 restq; =A0 =A0 =A0 =A0 =A0/* r=
eset tasklet */
>>
>> @@ -164,7 +172,9 @@ struct ath5k_softc {
>> =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0rxbuflock;
>> =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *rxlink; =A0=
 =A0 =A0 =A0/* link ptr in last RX desc */
>> =A0 =A0 =A0 struct tasklet_struct =A0 rxtq; =A0 =A0 =A0 =A0 =A0 /* r=
x intr tasklet */
>> +#ifdef CONFIG_ATH5K_LEDS
>> =A0 =A0 =A0 struct ath5k_led =A0 =A0 =A0 =A0rx_led; =A0 =A0 =A0 =A0 =
/* rx led */
>> +#endif
>
> You may want to group those fields together to make the code more
> readable.
>
>> --- a/drivers/net/wireless/ath/ath5k/led.c
>> +++ b/drivers/net/wireless/ath/ath5k/led.c
>
> I wonder if you could omit led.c completely in the Makefile. =A0If th=
ere
> are some parts of led.c that are needed without CONFIG_ATH5K_LEDS, ma=
ybe
> they belong elsewhere?
>
> --
> Regards,
> Pavel Roskin
>
