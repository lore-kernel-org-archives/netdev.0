From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC level
Date: Fri, 04 Nov 2016 15:18:17 +0000
Message-ID: <yw1xlgwzjmti.fsf@unicorn.mansr.com>
References: <581CA300.1060609@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <581CA300.1060609@laposte.net> (Sebastian Frias's message of
        "Fri, 4 Nov 2016 16:02:24 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

> The delay can be applied at PHY or MAC level, but since
> PHY drivers will apply the delay at PHY level when using
> one of the "internal delay" declinations of RGMII mode
> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
> at MAC level causes issues.

The Broadcom GENET driver does the same thing.

> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index b59aa35..d2855c9 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1282,7 +1282,7 @@ static int nb8800_tangox_init(struct net_device *dev)
>  		break;
>
>  	case PHY_INTERFACE_MODE_RGMII_TXID:
> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
> +		pad_mode = PAD_MODE_RGMII;
>  		break;
>
>  	default:
> -- 
> 1.7.11.2

If this change is correct (and I'm not convinced it is), that case
should be merged with the one above it and PHY_INTERFACE_MODE_RGMII_RXID
added as well.

-- 
Måns Rullgård
