From: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Tue, 21 Jan 2014 23:53:13 +0900
Message-ID: <CAAVeFuKFfAvSPYLmvWV5jjT-peZFJ8sJ2bbh4F=JAYoWLhjZpA@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <CAAVeFuLP4MkfXGG1FMauvUw_J63zRXdhGwxqYy5W98L1wCQNbw@mail.gmail.com>
 <CACRpkdYiy+sya6NqRfAmsrFOXvaa3qX=qjRuTDW1vZVSaG1+Gg@mail.gmail.com> <201401211335.16885.arnd@arndb.de>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-sunxi+bncBDE4FPUCVULRB3MT7KLAKGQEJ5SSW4I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <201401211335.16885.arnd-r2nGTMty4D4@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, Jan 21, 2014 at 9:35 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Tuesday 21 January 2014, Linus Walleij wrote:
>> On Tue, Jan 21, 2014 at 4:11 AM, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On Sat, Jan 18, 2014 at 8:11 AM, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>> >
>> > I agree that's how it should be be done with the current API if your
>> > driver can obtain GPIOs from both ACPI and DT. This is a potential
>> > issue, as drivers are not supposed to make assumptions about who is
>> > going to be their GPIO provider. Let's say you started a driver with
>> > only DT in mind, and used gpio_get(dev, con_id) to get your GPIOs. DT
>> > bindings are thus of the form "con_id-gpio = <phandle>", and set in
>> > stone. Then later, someone wants to use your driver with ACPI. How do
>> > you handle that gracefully?
>>
>> Short answer is you can't. You have to pour backward-compatibility
>> code into the driver first checking for that property and then falling
>> back to the new binding if it doesn't exist.
>
> With the ACPI named properties extension, it should be possible to have
> something akin to a "gpio-names" list that can be attached to an indexed
> array of gpio descriptors. I assume that Intel is going to need this
> for named irqs, clocks, regulators, dmas as well, so I think it will
> eventually get there. It's not something that can be done today though,
> or that is standardized in APCI-5.0.

Good to know. I'm not sure this would help with the named GPIO
resolution issue however. I assume that contrary to DT we will have no
control over the naming of ACPI-defined GPIOs, and thus there is
little chance that a GPIO serving a function will end up having the
same name as the one we chose for the DT binding...

>
> My guess is that named GPIOs are going to make more sense on x86 embedded
> than on arm64 server.
>
>> > I'm starting to wonder, now that ACPI is a first-class GPIO provider,
>> > whether we should not start to encourage the deprecation of the
>> > "con_id-gpio = <phandle>" binding form in DT and only use a single
>> > indexed GPIO property per device.
>>
>> You have a valid point.
>
> Independent of ACPI, I prefer indexed "gpios" properties over "con_id-gpio"
> properties anyway, because it's more consistent with some of the other
> subsystems. I don't have an opinion though on whether we should also
> allow a "gpios"/"gpio-names" pair, or whether we should keep the indexed
> "gpios" list for the anonymous case.
>
>> > The con_id parameter would then only
>> > be used as a label, which would also have the nice side-effect that
>> > all GPIOs used for a given function will be reported under the same
>> > name no matter what the GPIO provider is.
>>
>> As discussed earlier in this thread I'm not sure the con_id is
>> suitable for labelling GPIOs. It'd be better to have a proper name
>> specified in DT/ACPI instead.
>
> +1

I wonder why you guys prefer to have the name defined in the GPIO
mapping. Having the driver decide the label makes it easier to look up
which GPIO does what in debugfs, whereas nothing prevents people to
name GPIOs whatever inadequate name they want in the device DT node.
What am I overlooking here?

>
>> > From an aesthetic point of view, I definitely prefer using con_id to
>> > identify GPIOs instead of indexes, but I don't see how we can make it
>> > play nice with ACPI. Thoughts?
>>
>> Let's ask the DT maintainers...
>>
>> I'm a bit sceptic to the whole ACPI-DT-API-should-be-unified
>> just-one-function-call business, as this was just a very simple example
>> of what can happen to something as simple as
>> devm_gpiod_get[_index]().
>
> I think a unified kernel API makes more sense for some subsystems than
> others, and it depends a bit on the rate of adoption of APCI for drivers
> that already have a DT binding (or vice versa, if that happens).
>
> GPIO might actually be in the first category since it's commonly used
> for off-chip components that will get shared across ARM and x86 (as
> well as everything else), while a common kernel API would be less
> important for things that are internal to an SoC where Intel is the
> only company needing ACPI support.

I am afraid I don't have a good enough view of the ACPI landscape to
understand how often drivers might be reused on both ACPI and DT. But
I suppose nothing speaks against that, technically speaking. Maybe
Mika would have comments to make here?

The good (or bad, rather) thing about DT is that we can do whatever we
please with the new bindings: decide which name or which index
(doesn't matter here) a GPIO should have. However we don't have this
control over ACPI, where nothing guarantees that the same index will
be used for the same GPIO function. And there goes our unified GPIO
mapping. Workarounds would imply additional layers of mapping, or
using different probe functions depending on whether we rely on DT or
ACPI (I don't want to imagine there will be systems that use *both*).
Considering that we already have drivers using that trick (e.g. to
choose between SPI or I2C), the latter might be acceptable.

Alex.
