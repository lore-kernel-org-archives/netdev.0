From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 13/13] net: dsa: lan9303: lan9303_port_mdb_del remove port
 0
Date: Mon, 24 Jul 2017 09:57:26 -0700
Message-ID: <42090826-7498-4d90-f265-a7cf65a9e236@gmail.com>
References: <3bf6b19359cc40939b2e075635ed55d2@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <egil.hjelmeland@zenitel.com>, corbet@lwn.net,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <3bf6b19359cc40939b2e075635ed55d2@nooslMX1.zenitelcss.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2017 06:57 AM, Egil Hjelmeland wrote:
> Workaround for dsa_switch_mdb_add adding CPU port to group,
> but forgetting to remove it:
> 
> Remove port 0 if only port 0 is only port left.
> 
> Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
> ---
>  drivers/net/dsa/lan9303-core.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
> index 54646eb38185..61c915eed649 100644
> --- a/drivers/net/dsa/lan9303-core.c
> +++ b/drivers/net/dsa/lan9303-core.c
> @@ -1424,6 +1424,17 @@ static int lan9303_port_mdb_del(
>  	if (mdb->vid)
>  		return -EOPNOTSUPP;
>  	lan9303_alr_del_port(chip, mdb->addr, port);
> +
> +	{

No need for curly braces here.

> +		/* Workaround for dsa_switch_mdb_add adding CPU port to
> +		 * group, but forgetting to remove it. Remove port 0
> +		 * if only port left

Should not we move this logic one layer above into DSA then such that
insertions and removals are strictly symmetrical in which and how many
ports are targeted?

> +		 **/
> +		struct lan9303_alr_cache_entry *entr =
> +			lan9303_alr_cache_find_mac(chip, mdb->addr);
> +		if (entr && (entr->port_map == BIT(0)))
> +			lan9303_alr_del_port(chip, mdb->addr, 0);
> +	}
>  	return 0;
>  }
>  
> 


-- 
Florian
