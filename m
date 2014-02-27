From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Thu, 27 Feb 2014 10:47:58 -0700
Message-ID: <530F7A4E.700@wwwdotorg.org>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>	<1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>	<53062F97.3050407@wwwdotorg.org>	<CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>	<5306E599.7020605@wwwdotorg.org> <CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com> <BD75D217E5BAC84080F8EFB2582976378B327178@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chen-Yu Tsai <wens@csie.org>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"mgross@linux.intel.com" <mgross@linux.intel.com>
To: "Gross, Mark" <mark.gross@intel.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BD75D217E5BAC84080F8EFB2582976378B327178@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2014 10:38 AM, Gross, Mark wrote:
> Please know that no one should not consider me an authority on ACPI at this time.  But, I have some comments / context / thoughts below.
> 
> Also I apologize in advance for any email formatting issues caused by replying to this via my work exchange account / outlook client.  Folks can use mgross@linux.intel.com to avoid outlook-isms from me in the future.
> 
>> -----Original Message-----
>> From: Linus Walleij [mailto:linus.walleij@linaro.org]
>> Sent: Tuesday, February 25, 2014 1:14 AM
>> To: Stephen Warren; Alexandre Courbot; Grant Likely;
>> devicetree@vger.kernel.org
>> Cc: Chen-Yu Tsai; Heikki Krogerus; Johannes Berg; David S. Miller; Rhyland
>> Klein; linux-wireless; netdev; linux-kernel; Arnd Bergmann; Gross, Mark
>> Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
>>
>> On Fri, Feb 21, 2014 at 6:35 AM, Stephen Warren
>> <swarren@wwwdotorg.org> wrote:
>>> On 02/20/2014 06:55 PM, Chen-Yu Tsai wrote:
>>
>>>> That's correct. However using con_id to pass this results in
>>>> different behavior across DT and ACPI. A better way is to export the
>>>> labeling function so consumers can set meaningful labels themselves.
>>>
>>> But this code is the consumer of those GPIOs. IF the parameter to
>>> devm_gpiod_get_index() isn't intended to be used, why does it exist?
>>
>> Kerneldoc says:
>>
>> /**
>>  * gpiod_get_index - obtain a GPIO from a multi-index GPIO function
>>  * @dev:        GPIO consumer, can be NULL for system-global GPIOs
>>  * @con_id:     function within the GPIO consumer
>>  * @idx:        index of the GPIO to obtain in the consumer
>>  *
>>
>> Basically it is just exposing the fact that of_find_gpio() and
>> acpi_find_gpio() both take a con_id as argument.
>>
>> If we drill into this, we find that it is used to conjure the arbitrary string
>> before the gpios in the DT case, like:
>>
>> foo-gpios = <...>;
>>
>> As in tegra30-beaver.dts...
>>
>>     sdhci@78000000 {
>>             status = "okay";
>>             cd-gpios = <&gpio TEGRA_GPIO(I, 5) GPIO_ACTIVE_LOW>;
>>             wp-gpios = <&gpio TEGRA_GPIO(T, 3) GPIO_ACTIVE_HIGH>;
>>             power-gpios = <&gpio TEGRA_GPIO(D, 7) GPIO_ACTIVE_HIGH>;
>>             bus-width = <4>;
>>     };
>>
>> Instead of passing the GPIOs as index 0,1,2 they are named and I do admit
>> this has a nice "things are under control" aspect to it.
>
> [Gross, Mark] FWIW I don't think this is as "under control" as you do.  Those
> names in the above sdhci example are derived from a specific SDHCI
tegra spec
> sheet or schematic.  Those names likely come from the data sheet for
> the controller.

The names of the properties are fixed and defined by the DT binding for
the Tegra SDHCI controller, or even the core SDHCI bindings. Hence, they
will be the same in every DT file that uses that Tegra SDHCI compatible
value (the compatible property isn't show above, because the above
fragment is a board.dts file, and the compatible value gets inherited
from the soc.dtsi file). There won't be any variation at all,
irrespective of what signal names exist in a particular board schematic.

If there were ever an (upstream?) ACPI "binding"(?) for the Tegra SDHCI
controller, I would hope it would use the exact same names for the GPIO
signals.
