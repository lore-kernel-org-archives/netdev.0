From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH 2/8] bnx2x: adopt bnx2x_validate_addr() to
 .ndo_validate_addr changes
Date: Wed, 29 Feb 2012 18:22:15 +0200
Message-ID: <1330532535.25281.2.camel@lb-tlvb-dmitry>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
 <1330530176-24952-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Danny Kukawka" <dkukawka@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: "Danny Kukawka" <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330530176-24952-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-29 at 16:42 +0100, Danny Kukawka wrote:
> Adopted bnx2x_validate_addr() to changes in .ndo_validate_addr,
> handle second parameter to be validated.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   13 ++++++++++---
>  1 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index b4afef6..d25ef1e 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -10532,12 +10532,19 @@ static void poll_bnx2x(struct net_device *dev)
>  }
>  #endif
>  
> -static int bnx2x_validate_addr(struct net_device *dev)
> +static int bnx2x_validate_addr(struct net_device *dev, void *addr)
>  {
>  	struct bnx2x *bp = netdev_priv(dev);
> +	struct sockaddr *saddr; 
>  
> -	if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr))
> -		return -EADDRNOTAVAIL;
> +	if (addr) {
> +		saddr = addr;
> +		if (!bnx2x_is_valid_ether_addr(bp, saddr->sa_data))	
> +			return -EADDRNOTAVAIL;
> +	} else {
> +		if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr))
> +			return -EADDRNOTAVAIL;
> +	}
>  	return 0;
>  }
>  

Isn't it preferred to calculate the correct address for test and then
call bnx2x_is_valid_ether_addr() at the end?
