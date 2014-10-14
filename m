From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] dsa: mv88e6171: Fix tag_protocol check
Date: Tue, 14 Oct 2014 11:23:03 -0700
Message-ID: <543D6A07.9010300@gmail.com>
References: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/2014 11:21 AM, Guenter Roeck wrote:
> tag_protocol is now an enum, so drivers have to check against it.

Good catch, this driver got merged right in the middle of my changes
from __be16 to an enum and this slipped through.

> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Fixes: 42f272539487e49c9ea830ad97db41eb9937d5dc ("net: DSA: Marvell
mv88e6171 switch driver")
Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/dsa/mv88e6171.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index 6365e30..1020a7a 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -206,7 +206,7 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
>  	 */
>  	val = 0x0433;
>  	if (dsa_is_cpu_port(ds, p)) {
> -		if (ds->dst->tag_protocol == htons(ETH_P_EDSA))
> +		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
>  			val |= 0x3300;
>  		else
>  			val |= 0x0100;
> 
