From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 02/14] net: dsa: Report known silicon revisions for Marvell
 88E6060
Date: Thu, 23 Oct 2014 16:51:00 +0400
Message-ID: <5448F9B4.9010209@cogentembedded.com>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-3-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414037002-25528-3-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/23/2014 8:03 AM, Guenter Roeck wrote:

> Report known silicon revisions when probing Marvell 88E6060 switches.

> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>   drivers/net/dsa/mv88e6060.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 05b0ca3..c29aebe 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -69,8 +69,11 @@ static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
>
>   	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
>   	if (ret >= 0) {
> -		ret &= 0xfff0;
>   		if (ret == 0x0600)
> +			return "Marvell 88E6060 (A0)";
> +		if (ret == 0x0601 || ret == 0x0602)

    *else* *if*.

> +			return "Marvell 88E6060 (B0)";
> +		if ((ret & 0xfff0) == 0x0600)

    Likewise?

>   			return "Marvell 88E6060";
>   	}

WBR, Sergei
