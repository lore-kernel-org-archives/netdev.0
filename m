From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH] leds: Rename led_brightness_set() to led_set_brightness()
Date: Fri, 15 Jun 2012 20:20:45 +0800
Message-ID: <CAK5ve-K0zprrhpVv8=TuDq21vz2WUHxPC5MpY5ySaZ+yc5qONA@mail.gmail.com>
References: <1339619670.13326.22.camel@lorien2> <1339685540.2603.1.camel@lorien2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rpurdie@rpsys.net, johannes@sipsolutions.net,
	linville@tuxdriver.com, davem@davemloft.net,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-leds@vger.kernel.org
To: shuahkhan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339685540.2603.1.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2012 at 10:52 PM, Shuah Khan <shuahkhan@gmail.com> wrot=
e:
> On Wed, 2012-06-13 at 14:34 -0600, Shuah Khan wrote:
>> Rename leds external interface led_brightness_set() to led_set_brigh=
tness().
>> This is the second phase of the change to reduce confusion between t=
he
>> leds internal and external interfaces that set brightness. With this=
 change,
>> now the external interface is led_set_brightness(). The first phase =
renamed
>> the internal interface led_set_brightness() to __led_set_brightness(=
).
>> There are no changes to the interface implementations.
>>
>> Signed-off-by: Shuah Khan <shuahkhan@gmail.com>
>
> Bryan,
>
> Just in case you didn't see this patch. cc'ing linux-leds
>

I found I missed this patch and cause building failure in linux-next.
applied to my for-next.

Thanks,
-Bryan

>
>> ---
>> =A0drivers/leds/led-class.c =A0 =A0 =A0 | =A0 =A02 +-
>> =A0drivers/leds/led-core.c =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> =A0drivers/leds/led-triggers.c =A0 =A0| =A0 =A02 +-
>> =A0drivers/leds/ledtrig-oneshot.c | =A0 =A02 +-
>> =A0drivers/leds/ledtrig-timer.c =A0 | =A0 =A02 +-
>> =A0include/linux/leds.h =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
>> =A0net/mac80211/led.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
>> =A07 files changed, 9 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/leds/led-class.c b/drivers/leds/led-class.c
>> index cb0a6eb..c599095 100644
>> --- a/drivers/leds/led-class.c
>> +++ b/drivers/leds/led-class.c
>> @@ -222,7 +222,7 @@ void led_classdev_unregister(struct led_classdev=
 *led_cdev)
>> =A0#endif
>>
>> =A0 =A0 =A0 /* Stop blinking */
>> - =A0 =A0 led_brightness_set(led_cdev, LED_OFF);
>> + =A0 =A0 led_set_brightness(led_cdev, LED_OFF);
>>
>> =A0 =A0 =A0 device_unregister(led_cdev->dev);
>>
>> diff --git a/drivers/leds/led-core.c b/drivers/leds/led-core.c
>> index 176961b..8a09c5f 100644
>> --- a/drivers/leds/led-core.c
>> +++ b/drivers/leds/led-core.c
>> @@ -103,7 +103,7 @@ void led_blink_set_oneshot(struct led_classdev *=
led_cdev,
>> =A0}
>> =A0EXPORT_SYMBOL(led_blink_set_oneshot);
>>
>> -void led_brightness_set(struct led_classdev *led_cdev,
>> +void led_set_brightness(struct led_classdev *led_cdev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum led_brightness brig=
htness)
>> =A0{
>> =A0 =A0 =A0 /* stop and clear soft-blink timer */
>> @@ -113,4 +113,4 @@ void led_brightness_set(struct led_classdev *led=
_cdev,
>>
>> =A0 =A0 =A0 __led_set_brightness(led_cdev, brightness);
>> =A0}
>> -EXPORT_SYMBOL(led_brightness_set);
>> +EXPORT_SYMBOL(led_set_brightness);
>> diff --git a/drivers/leds/led-triggers.c b/drivers/leds/led-triggers=
=2Ec
>> index f8b14dd..57721f2 100644
>> --- a/drivers/leds/led-triggers.c
>> +++ b/drivers/leds/led-triggers.c
>> @@ -112,7 +112,7 @@ void led_trigger_set(struct led_classdev *led_cd=
ev, struct led_trigger *trig)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (led_cdev->trigger->deactivate)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 led_cdev->trigger->deact=
ivate(led_cdev);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 led_cdev->trigger =3D NULL;
>> - =A0 =A0 =A0 =A0 =A0 =A0 led_brightness_set(led_cdev, LED_OFF);
>> + =A0 =A0 =A0 =A0 =A0 =A0 led_set_brightness(led_cdev, LED_OFF);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 if (trig) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_lock_irqsave(&trig->leddev_list_lo=
ck, flags);
>> diff --git a/drivers/leds/ledtrig-oneshot.c b/drivers/leds/ledtrig-o=
neshot.c
>> index 5cbab41..2c029aa 100644
>> --- a/drivers/leds/ledtrig-oneshot.c
>> +++ b/drivers/leds/ledtrig-oneshot.c
>> @@ -177,7 +177,7 @@ static void oneshot_trig_deactivate(struct led_c=
lassdev *led_cdev)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /* Stop blinking */
>> - =A0 =A0 led_brightness_set(led_cdev, LED_OFF);
>> + =A0 =A0 led_set_brightness(led_cdev, LED_OFF);
>> =A0}
>>
>> =A0static struct led_trigger oneshot_led_trigger =3D {
>> diff --git a/drivers/leds/ledtrig-timer.c b/drivers/leds/ledtrig-tim=
er.c
>> index 9010f7a..f774d05 100644
>> --- a/drivers/leds/ledtrig-timer.c
>> +++ b/drivers/leds/ledtrig-timer.c
>> @@ -104,7 +104,7 @@ static void timer_trig_deactivate(struct led_cla=
ssdev *led_cdev)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /* Stop blinking */
>> - =A0 =A0 led_brightness_set(led_cdev, LED_OFF);
>> + =A0 =A0 led_set_brightness(led_cdev, LED_OFF);
>> =A0}
>>
>> =A0static struct led_trigger timer_led_trigger =3D {
>> diff --git a/include/linux/leds.h b/include/linux/leds.h
>> index dd93a22..3aade1d 100644
>> --- a/include/linux/leds.h
>> +++ b/include/linux/leds.h
>> @@ -124,7 +124,7 @@ extern void led_blink_set_oneshot(struct led_cla=
ssdev *led_cdev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsi=
gned long *delay_off,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int =
invert);
>> =A0/**
>> - * led_brightness_set - set LED brightness
>> + * led_set_brightness - set LED brightness
>> =A0 * @led_cdev: the LED to set
>> =A0 * @brightness: the brightness to set it to
>> =A0 *
>> @@ -132,7 +132,7 @@ extern void led_blink_set_oneshot(struct led_cla=
ssdev *led_cdev,
>> =A0 * software blink timer that implements blinking when the
>> =A0 * hardware doesn't.
>> =A0 */
>> -extern void led_brightness_set(struct led_classdev *led_cdev,
>> +extern void led_set_brightness(struct led_classdev *led_cdev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum led_=
brightness brightness);
>>
>> =A0/*
>> diff --git a/net/mac80211/led.c b/net/mac80211/led.c
>> index 1bf7903..bcffa69 100644
>> --- a/net/mac80211/led.c
>> +++ b/net/mac80211/led.c
>> @@ -276,7 +276,7 @@ static void ieee80211_stop_tpt_led_trig(struct i=
eee80211_local *local)
>>
>> =A0 =A0 =A0 read_lock(&tpt_trig->trig.leddev_list_lock);
>> =A0 =A0 =A0 list_for_each_entry(led_cdev, &tpt_trig->trig.led_cdevs,=
 trig_list)
>> - =A0 =A0 =A0 =A0 =A0 =A0 led_brightness_set(led_cdev, LED_OFF);
>> + =A0 =A0 =A0 =A0 =A0 =A0 led_set_brightness(led_cdev, LED_OFF);
>> =A0 =A0 =A0 read_unlock(&tpt_trig->trig.leddev_list_lock);
>> =A0}
>>
>
>



--=20
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer =A0 =A0+86.186-168-78255 Mobile
Canonical Ltd. =A0 =A0 =A0www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
