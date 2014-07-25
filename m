From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH] gpio: extend gpiod_get*() with flags parameter
Date: Fri, 25 Jul 2014 10:32:45 +0900
Message-ID: <CAAVeFuLK2qf1n6ipnW1tK_ur2_j7NOWLegMWYAQGwKw85fnwpA@mail.gmail.com>
References: <1406214298-20062-1-git-send-email-acourbot@nvidia.com>
 <6059032.T3tqvLkWTo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
 Ulf Hansson <ulf.hansson@linaro.org>, Wolfram Sang <wsa@the-dreams.de>,
 linux-mmc <linux-mmc@vger.kernel.org>, Chris Ball <chris@printf.net>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Liam Girdwood <lgirdwood@gmail.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Pavel Machek <pavel@ucw.cz>, Jiri Slaby <jslaby@suse.cz>,
 Florian Fainelli <f.fainelli@gmail.com>, Samuel Ortiz <sameo@linux.intel.com>,
 Alexander Shiyan <shc_work@mail.ru>,
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
 Lee Jones <lee.jones@linaro.org>, Paul Handrigan <Paul.Handrigan@cirrus.com>,
 linux-iio@vger.kernel.org, linux-omap@vger.kernel.org,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Hans Verkuil <hans.verkuil@cisco.com>,
 linux-serial@vger.kernel.org, linux-input@vger.kernel.org,
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <6059032.T3tqvLkWTo@wuerfel>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 1:10 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday 25 July 2014 00:04:58 Alexandre Courbot wrote:
>> I'm not sure how this could be applied harmlessly though - maybe through
>> a dedicated branch for -next? Problem is that a lot of new code is not
>> yet merged into mainline, and conflicts are very likely to occur. Linus,
>> do you have any suggestion as to how this can be done without blood being
>> spilled?
>
> There is a trick that we sometime use in this situation,
> though it has to be done carefully:
>
>> diff --git a/Documentation/gpio/consumer.txt b/Documentation/gpio/consumer.txt
>> index 7ff30d2..a3fb1d7 100644
>> --- a/Documentation/gpio/consumer.txt
>> +++ b/Documentation/gpio/consumer.txt
>> @@ -29,13 +29,24 @@ gpiod_get() functions. Like many other kernel subsystems, gpiod_get() takes the
>>  device that will use the GPIO and the function the requested GPIO is supposed to
>>  fulfill:
>>
>> -       struct gpio_desc *gpiod_get(struct device *dev, const char *con_id)
>> +       struct gpio_desc *gpiod_get(struct device *dev, const char *con_id,
>> +                                   enum gpio_flags flags)
>>
>>
>
>
> -       struct gpio_desc *gpiod_get(struct device *dev, const char *con_id)
> +       struct gpio_desc *__gpiod_get(struct device *dev, const char *con_id,
> +                                       enum gpio_flags flags);
> +
> +#define __gpiod_get(dev, con_id, flags, ...) __gpiod_get(dev, con_id, flags)
> +#define gpiod_get(varargs ...) __gpiod_get(varargs, 0)
>
> This will allow both variants to be called, and any users of the three-argument
> version will pass zero as the fourth argument (or whatever you choose there).
>
> Once the conversion is complete, the macros can be removed.

Wow, that works great, thanks! Indeed, this will allow me to send more
localized patches and to not spam half of the kernel developers. Sorry
about the noise.

Let's close this thread, I will submit the gpiolib update with this
trick first, then update each user before eventually removing the
macros.

Thanks,
Alex.
