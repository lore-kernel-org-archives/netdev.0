From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: check master device before put
Date: Mon, 23 Oct 2017 11:49:08 -0700
Message-ID: <cda226ca-a1c5-107f-d44f-7b6e93459b51@gmail.com>
References: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/2017 11:01 AM, Vivien Didelot wrote:
> In the case of pdata, the dsa_cpu_parse function calls dev_put() before
> making sure it isn't NULL. Fix this.
> 
> Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Did not you want to target 'net' for that though?

> ---
>  net/dsa/dsa2.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 9e8b8aab049d..908c06e32520 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -489,14 +489,15 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
>  		if (!ethernet)
>  			return -EINVAL;
>  		ethernet_dev = of_find_net_device_by_node(ethernet);
> +		if (!ethernet_dev)
> +			return -EPROBE_DEFER;
>  	} else {
>  		ethernet_dev = dsa_dev_to_net_device(ds->cd->netdev[index]);
> +		if (!ethernet_dev)
> +			return -EPROBE_DEFER;
>  		dev_put(ethernet_dev);
>  	}
>  
> -	if (!ethernet_dev)
> -		return -EPROBE_DEFER;
> -
>  	if (!dst->cpu_dp) {
>  		dst->cpu_dp = port;
>  		dst->cpu_dp->master = ethernet_dev;
> 


-- 
Florian
