From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Tue, 21 Jan 2014 10:35:10 +0100
Message-ID: <CACRpkdYiy+sya6NqRfAmsrFOXvaa3qX=qjRuTDW1vZVSaG1+Gg@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
	<1389941251-32692-5-git-send-email-wens@csie.org>
	<201401171747.46332.arnd@arndb.de>
	<CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg@mail.gmail.com>
	<CACRpkdZOD4zeA8T5kbJ4c5NsnuzHCg1mw8rRMYNT9c4R-Qnc6A@mail.gmail.com>
	<CAAVeFuLP4MkfXGG1FMauvUw_J63zRXdhGwxqYy5W98L1wCQNbw@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-sunxi+bncBDE6RCFOWIARBT767CLAKGQEXDU27VI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAAVeFuLP4MkfXGG1FMauvUw_J63zRXdhGwxqYy5W98L1wCQNbw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, Jan 21, 2014 at 4:11 AM, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Sat, Jan 18, 2014 at 8:11 AM, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:

>> gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
>> gpio = devm_gpiod_get_index(&pdev->dev, NULL, 1);
>>
>> Heikki, are you OK with this change?
>>
>> I think this is actually necessary if the ACPI and DT unification
>> pipe dream shall limp forward, we cannot have arguments passed
>> that have a semantic effect on DT but not on ACPI... Drivers
>> that are supposed to use both ACPI and DT will always
>> have to pass NULL as con ID.
>
> I agree that's how it should be be done with the current API if your
> driver can obtain GPIOs from both ACPI and DT. This is a potential
> issue, as drivers are not supposed to make assumptions about who is
> going to be their GPIO provider. Let's say you started a driver with
> only DT in mind, and used gpio_get(dev, con_id) to get your GPIOs. DT
> bindings are thus of the form "con_id-gpio = <phandle>", and set in
> stone. Then later, someone wants to use your driver with ACPI. How do
> you handle that gracefully?

Short answer is you can't. You have to pour backward-compatibility
code into the driver first checking for that property and then falling
back to the new binding if it doesn't exist.

> I'm starting to wonder, now that ACPI is a first-class GPIO provider,
> whether we should not start to encourage the deprecation of the
> "con_id-gpio = <phandle>" binding form in DT and only use a single
> indexed GPIO property per device.

You have a valid point.

> The con_id parameter would then only
> be used as a label, which would also have the nice side-effect that
> all GPIOs used for a given function will be reported under the same
> name no matter what the GPIO provider is.

As discussed earlier in this thread I'm not sure the con_id is
suitable for labelling GPIOs. It'd be better to have a proper name
specified in DT/ACPI instead.

> From an aesthetic point of view, I definitely prefer using con_id to
> identify GPIOs instead of indexes, but I don't see how we can make it
> play nice with ACPI. Thoughts?

Let's ask the DT maintainers...

I'm a bit sceptic to the whole ACPI-DT-API-should-be-unified
just-one-function-call business, as this was just a very simple example
of what can happen to something as simple as
devm_gpiod_get[_index]().

Yours,
Linus Walleij
