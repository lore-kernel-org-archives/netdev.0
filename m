From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83848: Add support for TI TLK10x Ethernet
 PHYs
Date: Sat, 6 Feb 2016 13:25:59 -0800
Message-ID: <56B664E7.4040202@gmail.com>
References: <1454713996-28851-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Andrew F. Davis" <afd@ti.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454713996-28851-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/02/2016 15:13, Andrew F. Davis a =C3=A9crit :
> The TI TLK10x Ethernet PHYs are similar in the interrupt relevant
> registers and so are compatible with the DP83848x devices already
> supported. Add these and re-order code to support additional PHYs.

This looks fine, but this could also be broken down into 3 commits:

- one which adds the macro to add new PHY entries
- one which renames DP83848_PHY_ID to DP83848C_PHY_ID
- one which factors out the interrupt enable mask

>=20
> Signed-off-by: Andrew F. Davis <afd@ti.com>
> ---
>  drivers/net/phy/dp83848.c | 89 ++++++++++++++++++++++++++++---------=
----------
>  1 file changed, 53 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
> index 5e14e62..bc88259 100644
> --- a/drivers/net/phy/dp83848.c
> +++ b/drivers/net/phy/dp83848.c
> @@ -1,7 +1,8 @@
>  /*
>   * Driver for the Texas Instruments DP83848 PHY
>   *
> - * Copyright (C) 2015 Texas Instruments Inc.
> + * Copyright (C) 2015-2016 Texas Instruments Incorporated - http://w=
ww.ti.com/
> + *	Andrew F. Davis <afd@ti.com>

We have the git changelog to know who added changes to the driver, you
can drop that specific change and just bump the copyright year.--
