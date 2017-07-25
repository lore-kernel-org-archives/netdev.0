From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Log only PHY state transitions
Date: Tue, 25 Jul 2017 12:33:03 -0700 (PDT)
Message-ID: <20170725.123303.483987159585881971.davem@davemloft.net>
References: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        slash.tmp@free.fr
To: marc_gonzalez@sigmadesigns.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbdGYTdE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:33:04 -0400
In-Reply-To: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Date: Tue, 25 Jul 2017 11:31:46 +0200

> In the current code, old and new PHY states are always logged.
> From now on, log only PHY state transitions.
> 
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> ---
>  drivers/net/phy/phy.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index d0626bf5c540..6bb764e716fc 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1226,7 +1226,8 @@ void phy_state_machine(struct work_struct *work)
>  	if (err < 0)
>  		phy_error(phydev);
>  
> -	phydev_dbg(phydev, "PHY state change %s -> %s\n",
> +	if (old_state != phydev->state)
> +		phydev_dbg(phydev, "PHY state change %s -> %s\n",
>  		   phy_state_to_str(old_state),
>  		   phy_state_to_str(phydev->state));

Something is not kosher with this indentation at all.
