From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next 2/6] net: dsa: mv88e6060: use the correct
 InitReady bit
Date: Mon, 2 Nov 2015 16:02:50 +0300
Message-ID: <56375EFA.7050509@cogentembedded.com>
References: <56374188.1010603@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56374188.1010603@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/2/2015 1:57 PM, Neil Armstrong wrote:

> According to the mv88e6060 datasheet, the InitReady bit position
> is 11 and the polarity is inverted.
> Use the bit correctly to detect the end of initialization.
>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>   drivers/net/dsa/mv88e6060.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 6885ef5..c10880f 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -102,7 +102,7 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
>   	timeout = jiffies + 1 * HZ;
>   	while (time_before(jiffies, timeout)) {
>   		ret = REG_READ(REG_GLOBAL, 0x00);
> -		if ((ret & 0x8000) == 0x0000)
> +		if ((ret & 0x800) != 0x0000)

    You could as well drop != 0.

[...]

MBR, Sergei
