From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/6] net: dsa: mv88e6060: use the correct InitReady bit
Date: Tue, 10 Nov 2015 09:16:00 -0500
Message-ID: <20151110141600.GA29568@ketchup.mtl.sfl>
References: <5641F03C.3030809@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5641F03C.3030809@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov. Tuesday 10 (46) 02:25 PM, Neil Armstrong wrote:
> According to the mv88e6060 datasheet, the InitReady bit position
> is 11 and the polarity is inverted.
> Use the bit correctly to detect the end of initialization.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/dsa/mv88e6060.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 6885ef5..26f668c 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -102,7 +102,7 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
>  	timeout = jiffies + 1 * HZ;
>  	while (time_before(jiffies, timeout)) {
>  		ret = REG_READ(REG_GLOBAL, 0x00);
> -		if ((ret & 0x8000) == 0x0000)
> +		if ((ret & 0x800))
>  			break;

You can drop a pair of parenthesis here.

> 
>  		usleep_range(1000, 2000);

Thanks,
-v
