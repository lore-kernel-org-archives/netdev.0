From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] net/tg3: simplify conditional
Date: Fri, 8 Oct 2010 10:43:12 -0700
Message-ID: <20101008174312.GA3562@mcarlson.broadcom.com>
References: <20101008112927.0ca949cf@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Nicolas Kaiser" <nikai@nikai.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101008112927.0ca949cf@absol.kitzblitz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 08, 2010 at 02:29:27AM -0700, Nicolas Kaiser wrote:
> Simplify: ((a && !b) || (!a && b)) => (a != b)
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
> ---
>  drivers/net/tg3.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 16e1a95..714f0fb 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -9967,8 +9967,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
>  
>  		if (!(phydev->supported & SUPPORTED_Pause) ||
>  		    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
> -		     ((epause->rx_pause && !epause->tx_pause) ||
> -		      (!epause->rx_pause && epause->tx_pause))))
> +		     (epause->rx_pause != epause->tx_pause)))
>  			return -EINVAL;
>  
>  		tp->link_config.flowctrl = 0;

Looks good to me.
