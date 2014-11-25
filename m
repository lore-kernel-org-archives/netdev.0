From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][v2] mdio-mux-gpio: Use GPIO descriptor interface and
 new gpiod_set_array function
Date: Tue, 25 Nov 2014 16:44:04 +0300
Message-ID: <547487A4.6050203@cogentembedded.com>
References: <2814617.OrXEO01vgP@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Rojhalat Ibrahim <imr@rtschenk.de>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <2814617.OrXEO01vgP@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/25/2014 12:31 PM, Rojhalat Ibrahim wrote:

> Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
> gpiod_set_array function to set all output signals simultaneously.

> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Acked-by: David S. Miller <davem@davemloft.net>
> --
> This patch depends on the gpiod_set_array function, which is available in
> the linux-gpio devel tree.

> v2: fix gpiod_get_index usage

>   drivers/net/phy/mdio-mux-gpio.c |   38 ++++++++++++++------------------------
>   1 file changed, 14 insertions(+), 24 deletions(-)

> diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> index 0966951..1167c5b 100644
> --- a/drivers/net/phy/mdio-mux-gpio.c
> +++ b/drivers/net/phy/mdio-mux-gpio.c
[...]
> @@ -98,15 +84,19 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
[...]
>   static int mdio_mux_gpio_remove(struct platform_device *pdev)
>   {
> +	unsigned int n;
>   	struct mdio_mux_gpio_state *s = dev_get_platdata(&pdev->dev);
>   	mdio_mux_uninit(s->mux_handle);
> +	for (n = 0; n < s->num_gpios; n++) {
> +		gpiod_put(s->gpio[n]);
> +	}

    {} not needed; scripts/checkpatch.pl should have complained...

WBR, Sergei

