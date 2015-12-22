From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1] phy: micrel: Fix finding PHY properties in MAC node
 for KSZ9031.
Date: Tue, 22 Dec 2015 12:06:34 +0100
Message-ID: <20151222110634.GC2373@lunn.ch>
References: <1450781920-26912-1-git-send-email-henri.roosen@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Henri Roosen <henri.roosen@ginzinger.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450781920-26912-1-git-send-email-henri.roosen@ginzinger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 22, 2015 at 11:58:40AM +0100, Henri Roosen wrote:
> Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
>  node.") only fixes finding PHY properties in MAC node for KSZ9021. This
> commit applies the same fix for KSZ9031.
> 
> Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>

Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")

Acked-by: Andrew Lunn <andrew@lunn.ch>

	  Andrew


> ---
>  drivers/net/phy/micrel.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index e13ad6c..fc6c058 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -470,9 +470,18 @@ static int ksz9031_config_init(struct phy_device *phydev)
>                 "txd2-skew-ps", "txd3-skew-ps"
>         };
>         static const char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
> +       const struct device *dev_walker;
> 
> -       if (!of_node && dev->parent->of_node)
> -               of_node = dev->parent->of_node;
> +       /* The Micrel driver has a deprecated option to place phy OF
> +        * properties in the MAC node. Walk up the tree of devices to
> +        * find a device with an OF node.
> +        */
> +       dev_walker = &phydev->dev;
> +       do {
> +               of_node = dev_walker->of_node;
> +               dev_walker = dev_walker->parent;
> +
> +       } while (!of_node && dev_walker);
> 
>         if (of_node) {
>                 ksz9031_of_load_skew_values(phydev, of_node,
> --
> 2.1.4
> 
> 
> ________________________________
> 
> Ginzinger electronic systems GmbH
> Gewerbegebiet Pirath 16
> 4952 Weng im Innkreis
> www.ginzinger.com
> 
> Firmenbuchnummer: FN 364958d
> Firmenbuchgericht: Ried im Innkreis
> UID-Nr.: ATU66521089
> 
> ________________________________
> *** WEIHNACHTSURLAUB VON DONNERSTAG, DEN 24. DEZEMBER 2015 BIS MITTWOCH, DEN 6. JAENNER 2016 ***
> *** CHRISTMAS VACATION FROM THURSDAY, THE 24 DECEMBER 2015 TO WEDNESDAY, 6 JANUARY 2016 ***
