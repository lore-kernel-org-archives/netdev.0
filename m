From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Tue, 25 Feb 2014 10:35:22 -0700
Message-ID: <530CD45A.8050803@wwwdotorg.org>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>	<1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>	<53062F97.3050407@wwwdotorg.org>	<CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>	<5306E599.7020605@wwwdotorg.org> <CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
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
	Mark Gross <mark.gross@intel.com>
To: Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/25/2014 02:13 AM, Linus Walleij wrote:
> On Fri, Feb 21, 2014 at 6:35 AM, Stephen Warren <swarren@wwwdotorg.org> wrote:
>> On 02/20/2014 06:55 PM, Chen-Yu Tsai wrote:
> 
>>> That's correct. However using con_id to pass this results in different
>>> behavior across DT and ACPI. A better way is to export the labeling
>>> function so consumers can set meaningful labels themselves.
...
> As in tegra30-beaver.dts...
> 
>     sdhci@78000000 {
>             status = "okay";
>             cd-gpios = <&gpio TEGRA_GPIO(I, 5) GPIO_ACTIVE_LOW>;
>             wp-gpios = <&gpio TEGRA_GPIO(T, 3) GPIO_ACTIVE_HIGH>;
>             power-gpios = <&gpio TEGRA_GPIO(D, 7) GPIO_ACTIVE_HIGH>;
>             bus-width = <4>;
>     };
> 
> Instead of passing the GPIOs as index 0,1,2 they are named
> and I do admit this has a nice "things are under control" aspect
> to it.
> 
> In the ACPI case the con_id is not used for anything.
> 
> So it is basically there to satisfy the habit in some device
> tree bindings to name gpio arrays instead of just passing gpios = <...>;
> (The latter should be encouraged going forward.)

Do you really want to switch from named GPIO lookups to index-based GPIO
lookups? Index-based lookups make it much harder to extend the DT
binding in a backwards-compatible fashion, especially in the face of
optional GPIOs (of which all of CD, WP, power are).

If we switch to a single gpios property, I'd assert we should still do
named-based lookups using a parallel gpio-names property, just like most
(all?) other resource types now support. If we do that, we'll still need
the name parameter.
