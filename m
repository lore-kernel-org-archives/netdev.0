From: Daniel Walker <danielwa@cisco.com>
Subject: Re: [PATCH v2 netdev] net: phy: marvell: Limit errata to 88m1101
Date: Tue, 23 May 2017 07:00:10 -0700
Message-ID: <c1e1255b-0a95-2af3-f7de-1eeee0ea54cc@cisco.com>
References: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harini Katakam <harini.katakam@xilinx.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-1.cisco.com ([173.37.86.72]:40095 "EHLO
        rcdn-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966262AbdEWOAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:00:14 -0400
In-Reply-To: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 04:28 PM, Andrew Lunn wrote:
> The 88m1101 has an errata when configuring autoneg. However, it was
> being applied to many other Marvell PHYs as well. Limit its scope to
> just the 88m1101.
>
> Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e1145")
> Reported-by: Daniel Walker <danielwa@cisco.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>
> v2:
> 	Forgot netdev
>
>   drivers/net/phy/marvell.c | 67 ++++++++++++++++++++++++++---------------------
>   1 file changed, 37 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 88cd97b44ba6..77221d3f254f 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -267,35 +267,6 @@ static int marvell_config_aneg(struct phy_device *phydev)
>   {
>   	int err;
>   
> -	/* The Marvell PHY has an errata which requires
> -	 * that certain registers get written in order
> -	 * to restart autonegotiation
> -	 */
> -	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
> -

It looks fine to me, but I'm not sure if this line BMCR_RESET was part 
of the errata or the comment. I guess it's OK to assume it tho.

Danie.
