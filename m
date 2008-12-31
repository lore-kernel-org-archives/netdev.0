From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] net/rfkill/rfkill.c: fix unused rfkill_led_trigger() warning
Date: Wed, 31 Dec 2008 10:31:13 +0100
Message-ID: <a32f33a40812310131o3207f10p2499b129d2701f3a@mail.gmail.com>
References: <1230714558.24416.1.camel@odie.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"John Linville" <linville@tuxdriver.com>
To: "=?ISO-8859-1?Q?Simon_Holm_Th=F8gersen?=" <odie@cs.aau.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:2242 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957AbYLaJbP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 04:31:15 -0500
In-Reply-To: <1230714558.24416.1.camel@odie.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2008 at 10:09 AM, Simon Holm Th=F8gersen <odie@cs.aau.d=
k> wrote:
> commit 4dec9b807be757780ca3611a959ac22c28d292a7 ("rfkill: strip point=
less
> notifier chain") removed the only user of rfkill_led_trigger() that w=
as not
> guarded by #ifdef CONFIG_RFKILL_LEDS. Therefore, move rfkill_led_trig=
ger()
> completely inside #ifdef CONFIG_RFKILL_LEDS and avoid the compile tim=
e
> warning:
>
> net/rfkill/rfkill.c:59: warning: 'rfkill_led_trigger' defined but not=
 used
>
> Signed-off-by: Simon Holm Th=F8gersen <odie@cs.aau.dk>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
>  net/rfkill/rfkill.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
>
> diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
> index 3c94f76..3eaa394 100644
> --- a/net/rfkill/rfkill.c
> +++ b/net/rfkill/rfkill.c
> @@ -54,10 +54,10 @@ static unsigned long rfkill_states_lockdflt[BITS_=
TO_LONGS(RFKILL_TYPE_MAX)];
>  static bool rfkill_epo_lock_active;
>
>
> +#ifdef CONFIG_RFKILL_LEDS
>  static void rfkill_led_trigger(struct rfkill *rfkill,
>                               enum rfkill_state state)
>  {
> -#ifdef CONFIG_RFKILL_LEDS
>        struct led_trigger *led =3D &rfkill->led_trigger;
>
>        if (!led->name)
> @@ -66,10 +66,8 @@ static void rfkill_led_trigger(struct rfkill *rfki=
ll,
>                led_trigger_event(led, LED_OFF);
>        else
>                led_trigger_event(led, LED_FULL);
> -#endif /* CONFIG_RFKILL_LEDS */
>  }
>
> -#ifdef CONFIG_RFKILL_LEDS
>  static void rfkill_led_trigger_activate(struct led_classdev *led)
>  {
>        struct rfkill *rfkill =3D container_of(led->trigger,
> --
> 1.6.0.2.526.g5c283
>
>
