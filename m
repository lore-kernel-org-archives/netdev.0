From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1] net: phy: micrel: add KSZ8795 ethernet switch
Date: Mon, 23 Jan 2017 16:12:19 +0100
Message-ID: <20170123151219.GE10895@lunn.ch>
References: <20170123075846.12888-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41681 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdAWPMU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 10:12:20 -0500
Content-Disposition: inline
In-Reply-To: <20170123075846.12888-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 08:58:46AM +0100, Sean Nyekjaer wrote:
> This is add support for the PHYs in the KSZ8795 5port managed switch.
> 
> It will allow to detect the link between the switch and the soc
> and uses the same read_status functions as the KSZ8873MLL switch.
> 
> This ethernet switch have unfortunately the same phy id as KSZ8051.
> 
> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
> ---
>  drivers/net/phy/micrel.c   | 14 ++++++++++++++
>  include/linux/micrel_phy.h |  2 ++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index ea92d524d5a8..fa158ae5115b 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
>  	.get_stats	= kszphy_get_stats,
>  	.suspend	= genphy_suspend,
>  	.resume		= genphy_resume,
> +}, {
> +	.phy_id		= PHY_ID_KSZ8795,
> +	.phy_id_mask	= MICREL_PHY_ID_MASK,
> +	.name		= "Micrel KSZ8795 Switch",

This name is confusing. You are adding support for the PHYs embedded
in the switch, not the switch itself. The phylib has no idea these
PHYs are inside a switch. It does not matter. It is just a PHY. Please
drop the word "Switch".

Thanks
	Andrew
