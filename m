From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] phy: increase size of bus_id and
 MII_BUS_ID_SIZE
Date: Thu, 19 Jan 2017 15:25:42 +0100
Message-ID: <20170119142542.GF26959@lunn.ch>
References: <1484826415-31631-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38140 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753287AbdASPk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 10:40:27 -0500
Content-Disposition: inline
In-Reply-To: <1484826415-31631-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 12:46:55PM +0100, Volodymyr Bendiuga wrote:
> Some bus names are pretty long and do not fit into
> 20 chars, therefore bus_id size is increased together
> with MII_BUS_ID_SIZE to host larger names.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
> ---
>  include/linux/phy.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index f7d95f6..f53f0cd 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -162,7 +162,7 @@ static inline const char *phy_modes(phy_interface_t interface)
>   * Need to be a little smaller than phydev->dev.bus_id to leave room
>   * for the ":%02x"

It would also be good to fixup this comment. dev.bus_id does not seem
to exist any more. I think it got replaced by dev->kobj.name, which is
now a char * rather than an array. I think the comment can be removed.

>   */
> -#define MII_BUS_ID_SIZE	(20 - 3)
> +#define MII_BUS_ID_SIZE	(64 - 3)
>  
>  /* Or MII_ADDR_C45 into regnum for read/write on mii_bus to enable the 21 bit
>     IEEE 802.3ae clause 45 addressing mode used by 10GIGE phy chips. */
> @@ -632,7 +632,7 @@ struct phy_driver {
>  /* A Structure for boards to register fixups with the PHY Lib */
>  struct phy_fixup {
>  	struct list_head list;
> -	char bus_id[20];
> +	char bus_id[64];

[MII_BUS_ID_SIZE + 3] would be better.

	 Andrew
