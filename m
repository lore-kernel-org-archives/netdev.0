From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Thu, 20 Feb 2014 22:35:21 -0700
Message-ID: <5306E599.7020605@wwwdotorg.org>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com> <1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com> <53062F97.3050407@wwwdotorg.org> <CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/20/2014 06:55 PM, Chen-Yu Tsai wrote:
> Hi,
> 
> On Fri, Feb 21, 2014 at 12:38 AM, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org> wrote:
>> On 02/20/2014 05:51 AM, Heikki Krogerus wrote:
>>> There is no use for them in this driver. This will fix a
>>> static checker warning..
>>
>> Didn't you remove the use:
>>
>> -       gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
>> +       gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
>>
>> doesn't that parameter get put into the sysfs GPIO debug file, so people
>> can see which GPIOs are used for what?
> 
> That's correct. However using con_id to pass this results in different
> behavior across DT and ACPI. A better way is to export the labeling
> function so consumers can set meaningful labels themselves.

But this code is the consumer of those GPIOs. IF the parameter to
devm_gpiod_get_index() isn't intended to be used, why does it exist?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
