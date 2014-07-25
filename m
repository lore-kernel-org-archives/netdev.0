From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH] gpio: extend gpiod_get*() with flags parameter
Date: Fri, 25 Jul 2014 10:36:43 +0900
Message-ID: <CAAVeFu+R+UWtxftWBM3qghNnf9O6SOf5AeNC-qemG7W05hiuAQ@mail.gmail.com>
References: <1406214298-20062-1-git-send-email-acourbot@nvidia.com>
 <1496956.3bpx902hFg@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
 Ulf Hansson <ulf.hansson@linaro.org>, Wolfram Sang <wsa@the-dreams.de>,
 linux-mmc <linux-mmc@vger.kernel.org>, Chris Ball <chris@printf.net>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Liam Girdwood <lgirdwood@gmail.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>,
 "linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
 Pavel Machek <pavel@ucw.cz>, Jiri Slaby <jslaby@suse.cz>,
 Florian Fainelli <f.fainelli@gmail.com>, Samuel Ortiz <sameo@linux.intel.com>,
 Alexander Shiyan <shc_work@mail.ru>,
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
 Lee Jones <lee.jones@linaro.org>, Paul Handrigan <Paul.Handrigan@cirrus.com>,
 linux-iio@vger.kernel.org, linux-omap@vger.kernel.org,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Hans Verkuil <hans.verkuil@cisco.com>,
 linux-serial@vger.kernel.org, linux-input@vger.kernel.o
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1496956.3bpx902hFg@avalon>
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

On Fri, Jul 25, 2014 at 1:23 AM, Laurent Pinchart
<laurent.pinchart@ideasonboard.com> wrote:
>> diff --git a/Documentation/gpio/consumer.txt
>> b/Documentation/gpio/consumer.txt index 7ff30d2..a3fb1d7 100644
>> --- a/Documentation/gpio/consumer.txt
>> +++ b/Documentation/gpio/consumer.txt
>> @@ -29,13 +29,24 @@ gpiod_get() functions. Like many other kernel
>> subsystems, gpiod_get() takes the device that will use the GPIO and the
>> function the requested GPIO is supposed to fulfill:
>>
>> -     struct gpio_desc *gpiod_get(struct device *dev, const char *con_id)
>> +     struct gpio_desc *gpiod_get(struct device *dev, const char *con_id,
>> +                                 enum gpio_flags flags)
>
> I assume you mean enum gpiod_flags here and in the rest of the documentation.

Indeed, thanks for pointing it out.

>
>>  If a function is implemented by using several GPIOs together (e.g. a simple
>> LED device that displays digits), an additional index argument can be
>> specified:
>>
>>       struct gpio_desc *gpiod_get_index(struct device *dev,
>> -                                       const char *con_id, unsigned int idx)
>> +                                       const char *con_id, unsigned int idx,
>> +                                       enum gpio_flags flags)
>> +
>> +The flags parameter is used to optionally specify a direction and initial
>> value +for the GPIO. Values can be:
>> +
>> +* AS_IS or 0 to not initialize the GPIO at all. The direction must be set
>> later
>> +  with one of the dedicated functions.
>> +* INPUT to initialize the GPIO as input.
>> +* OUTPUT_LOW to initialize the GPIO as output with a value of 0.
>> +* OUTPUT_HIGH to initialize the GPIO as output with a value of 1.
>
> Pretty please, could you at least prefix that with GPIOD_ ? Those names are
> too generic.
>
> How about renaming them to GPIOD_AS_IS, GPIOD_IN, GPIOD_OUT_INIT_LOW and
> GPIOD_OUT_INIT_HIGH in order to match the GPIOF_ flags ?

Yeah, you're right, the possibility of name collision is quite high here.

Thanks,
Alex.
