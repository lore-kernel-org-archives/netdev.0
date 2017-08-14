From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH] liquidio: fix duplicated code for different branches
Date: Mon, 14 Aug 2017 00:14:34 -0700
Message-ID: <20170814071434.GA1046@felix-thinkpad.cavium.com>
References: <20170813013855.GA6686@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170813013855.GA6686@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2017 at 08:38:55PM -0500, Gustavo A. R. Silva wrote:
> Refactor code in order to avoid identical code for different branches.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
> This code was tested by compilation only.
> 
>  drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
> index b78e296..4f65c08 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
> @@ -578,23 +578,18 @@ static int lio_set_phys_id(struct net_device *netdev,
>  		break;
>  
>  	case ETHTOOL_ID_ON:
> -		if (oct->chip_id == OCTEON_CN66XX) {
> +		if (oct->chip_id == OCTEON_CN66XX)
>  			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
>  					   VITESSE_PHY_GPIO_HIGH);
> -
> -		} else if (oct->chip_id == OCTEON_CN68XX) {
> -			return -EINVAL;
> -		} else {
> +		else
>  			return -EINVAL;
> -		}
> +
>  		break;
>  
>  	case ETHTOOL_ID_OFF:
>  		if (oct->chip_id == OCTEON_CN66XX)
>  			octnet_gpio_access(netdev, VITESSE_PHY_GPIO_CFG,
>  					   VITESSE_PHY_GPIO_LOW);
> -		else if (oct->chip_id == OCTEON_CN68XX)
> -			return -EINVAL;
>  		else
>  			return -EINVAL;
>  
> -- 
> 2.5.0
> 

Acked-by: Felix Manlunas <felix.manlunas@cavium.com>
