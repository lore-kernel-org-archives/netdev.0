From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCHv2 3/5] net: rfkill: gpio: remove gpio names
Date: Tue, 25 Feb 2014 16:04:46 -0700
Message-ID: <530D218E.9010007@wwwdotorg.org>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com> <1393330950-7283-4-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393330950-7283-4-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/25/2014 05:22 AM, Heikki Krogerus wrote:
> There is no use for them in this driver. This will fix a
> static checker warning..
> 
> net/rfkill/rfkill-gpio.c:144 rfkill_gpio_probe()
> 	warn: variable dereferenced before check 'rfkill->name'
> 
> This will also make sure that when DT support is added,
> "gpios" property can be used as no con_id labels are
> provided.

> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c

> -	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
> +	gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);

I think the correct fix here is to look up the GPIO by name rather than
by index, but simply hard-code the name rather than generating it with
sprintf(). Index lookups are hard to expand compatibly, but named-based
lookups scale much better.

In other words, I rather specifically disagree with using a plain
"gpios" property in any future DT binding, but would strongly prefer
e.g. reset-gpios/shutdown-gpios or gpios/gpio-names.

Still, I guess I don't object too much.
