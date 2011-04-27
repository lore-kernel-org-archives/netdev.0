From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 3/4] ethtool: Use the full 32 bit speed range in
 ethtool's set_settings
Date: Wed, 27 Apr 2011 15:23:10 -0700
Message-ID: <20110427152310.248307e2@nehalam>
References: <1303001651-4074-1-git-send-email-decot@google.com>
	<1303929290-21037-4-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303929290-21037-4-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Apr 2011 11:34:48 -0700
David Decotigny <decot@google.com> wrote:

> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index 176d784..b0fa999 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -322,7 +322,7 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
>  	} else {
>  		u32 setting;
>  
> -		switch (ecmd->speed) {
> +		switch (ethtool_cmd_speed(ecmd)) {
>  		case SPEED_1000:
>  			if (ecmd->duplex == DUPLEX_FULL)
>  				setting = SUPPORTED_1000baseT_Full;
> @@ -355,7 +355,7 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
>  		if ((setting & supported) == 0)
>  			return -EINVAL;
>  
> -		skge->speed = ecmd->speed;
> +		skge->speed = ethtool_cmd_speed(ecmd);
>  		skge->duplex = ecmd->duplex;
>  	}
>  
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index c8d0451..40afe07 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3453,7 +3453,7 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
>  	} else {
>  		u32 setting;
>  
> -		switch (ecmd->speed) {
> +		switch (ethtool_cmd_speed(ecmd)) {
>  		case SPEED_1000:
>  			if (ecmd->duplex == DUPLEX_FULL)
>  				setting = SUPPORTED_1000baseT_Full;
> @@ -3486,7 +3486,7 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
>  		if ((setting & supported) == 0)
>  			return -EINVAL;
>  
> -		sky2->speed = ecmd->speed;
> +		sky2->speed = ethtool_cmd_speed(ecmd);
>  		sky2->duplex = ecmd->duplex;
>  		sky2->flags &= ~SKY2_FLAG_AUTO_SPEED;
>  	}

These two are trivial, thanks for doing it.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>


-- 
