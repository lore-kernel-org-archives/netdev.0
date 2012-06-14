From: Shuah Khan <shuahkhan@gmail.com>
Subject: Re: [PATCH] leds: Rename led_brightness_set() to
 led_set_brightness()
Date: Thu, 14 Jun 2012 08:52:20 -0600
Message-ID: <1339685540.2603.1.camel@lorien2>
References: <1339619670.13326.22.camel@lorien2>
Reply-To: shuahkhan@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shuahkhan@gmail.com, rpurdie@rpsys.net, johannes@sipsolutions.net,
	linville@tuxdriver.com, davem@davemloft.net,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-leds@vger.kernel.org
To: bryan.wu@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339619670.13326.22.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-13 at 14:34 -0600, Shuah Khan wrote:
> Rename leds external interface led_brightness_set() to led_set_brightness().
> This is the second phase of the change to reduce confusion between the
> leds internal and external interfaces that set brightness. With this change,
> now the external interface is led_set_brightness(). The first phase renamed
> the internal interface led_set_brightness() to __led_set_brightness().
> There are no changes to the interface implementations.
> 
> Signed-off-by: Shuah Khan <shuahkhan@gmail.com>

Bryan,

Just in case you didn't see this patch. cc'ing linux-leds

-- Shuah

> ---
>  drivers/leds/led-class.c       |    2 +-
>  drivers/leds/led-core.c        |    4 ++--
>  drivers/leds/led-triggers.c    |    2 +-
>  drivers/leds/ledtrig-oneshot.c |    2 +-
>  drivers/leds/ledtrig-timer.c   |    2 +-
>  include/linux/leds.h           |    4 ++--
>  net/mac80211/led.c             |    2 +-
>  7 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/leds/led-class.c b/drivers/leds/led-class.c
> index cb0a6eb..c599095 100644
> --- a/drivers/leds/led-class.c
> +++ b/drivers/leds/led-class.c
> @@ -222,7 +222,7 @@ void led_classdev_unregister(struct led_classdev *led_cdev)
>  #endif
>  
>  	/* Stop blinking */
> -	led_brightness_set(led_cdev, LED_OFF);
> +	led_set_brightness(led_cdev, LED_OFF);
>  
>  	device_unregister(led_cdev->dev);
>  
> diff --git a/drivers/leds/led-core.c b/drivers/leds/led-core.c
> index 176961b..8a09c5f 100644
> --- a/drivers/leds/led-core.c
> +++ b/drivers/leds/led-core.c
> @@ -103,7 +103,7 @@ void led_blink_set_oneshot(struct led_classdev *led_cdev,
>  }
>  EXPORT_SYMBOL(led_blink_set_oneshot);
>  
> -void led_brightness_set(struct led_classdev *led_cdev,
> +void led_set_brightness(struct led_classdev *led_cdev,
>  			enum led_brightness brightness)
>  {
>  	/* stop and clear soft-blink timer */
> @@ -113,4 +113,4 @@ void led_brightness_set(struct led_classdev *led_cdev,
>  
>  	__led_set_brightness(led_cdev, brightness);
>  }
> -EXPORT_SYMBOL(led_brightness_set);
> +EXPORT_SYMBOL(led_set_brightness);
> diff --git a/drivers/leds/led-triggers.c b/drivers/leds/led-triggers.c
> index f8b14dd..57721f2 100644
> --- a/drivers/leds/led-triggers.c
> +++ b/drivers/leds/led-triggers.c
> @@ -112,7 +112,7 @@ void led_trigger_set(struct led_classdev *led_cdev, struct led_trigger *trig)
>  		if (led_cdev->trigger->deactivate)
>  			led_cdev->trigger->deactivate(led_cdev);
>  		led_cdev->trigger = NULL;
> -		led_brightness_set(led_cdev, LED_OFF);
> +		led_set_brightness(led_cdev, LED_OFF);
>  	}
>  	if (trig) {
>  		write_lock_irqsave(&trig->leddev_list_lock, flags);
> diff --git a/drivers/leds/ledtrig-oneshot.c b/drivers/leds/ledtrig-oneshot.c
> index 5cbab41..2c029aa 100644
> --- a/drivers/leds/ledtrig-oneshot.c
> +++ b/drivers/leds/ledtrig-oneshot.c
> @@ -177,7 +177,7 @@ static void oneshot_trig_deactivate(struct led_classdev *led_cdev)
>  	}
>  
>  	/* Stop blinking */
> -	led_brightness_set(led_cdev, LED_OFF);
> +	led_set_brightness(led_cdev, LED_OFF);
>  }
>  
>  static struct led_trigger oneshot_led_trigger = {
> diff --git a/drivers/leds/ledtrig-timer.c b/drivers/leds/ledtrig-timer.c
> index 9010f7a..f774d05 100644
> --- a/drivers/leds/ledtrig-timer.c
> +++ b/drivers/leds/ledtrig-timer.c
> @@ -104,7 +104,7 @@ static void timer_trig_deactivate(struct led_classdev *led_cdev)
>  	}
>  
>  	/* Stop blinking */
> -	led_brightness_set(led_cdev, LED_OFF);
> +	led_set_brightness(led_cdev, LED_OFF);
>  }
>  
>  static struct led_trigger timer_led_trigger = {
> diff --git a/include/linux/leds.h b/include/linux/leds.h
> index dd93a22..3aade1d 100644
> --- a/include/linux/leds.h
> +++ b/include/linux/leds.h
> @@ -124,7 +124,7 @@ extern void led_blink_set_oneshot(struct led_classdev *led_cdev,
>  				  unsigned long *delay_off,
>  				  int invert);
>  /**
> - * led_brightness_set - set LED brightness
> + * led_set_brightness - set LED brightness
>   * @led_cdev: the LED to set
>   * @brightness: the brightness to set it to
>   *
> @@ -132,7 +132,7 @@ extern void led_blink_set_oneshot(struct led_classdev *led_cdev,
>   * software blink timer that implements blinking when the
>   * hardware doesn't.
>   */
> -extern void led_brightness_set(struct led_classdev *led_cdev,
> +extern void led_set_brightness(struct led_classdev *led_cdev,
>  			       enum led_brightness brightness);
>  
>  /*
> diff --git a/net/mac80211/led.c b/net/mac80211/led.c
> index 1bf7903..bcffa69 100644
> --- a/net/mac80211/led.c
> +++ b/net/mac80211/led.c
> @@ -276,7 +276,7 @@ static void ieee80211_stop_tpt_led_trig(struct ieee80211_local *local)
>  
>  	read_lock(&tpt_trig->trig.leddev_list_lock);
>  	list_for_each_entry(led_cdev, &tpt_trig->trig.led_cdevs, trig_list)
> -		led_brightness_set(led_cdev, LED_OFF);
> +		led_set_brightness(led_cdev, LED_OFF);
>  	read_unlock(&tpt_trig->trig.leddev_list_lock);
>  }
>  
