From: David Decotigny <decot@googlers.com>
Subject: Re: [PATCH v3 1/3] net: phy: add phy_ethtool_{get|set}_link_ksettings
Date: Mon, 9 May 2016 16:01:55 -0700
Message-ID: <CAG88wWaxmXX+HKqxXLEDtyJGzbj3inaS289GwN74PFDqB0q8sg@mail.gmail.com>
References: <1462832383-25541-1-git-send-email-tremyfr@gmail.com> <1462832383-25541-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fugang.duan@nxp.com, Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462832383-25541-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 9, 2016 at 3:19 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
> Ethtool callbacks {get|set}_link_ksettings are often the same, so
> we add two generics functions phy_ethtool_{get|set}_link_ksettings
> to avoid writing severals times the same function.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/phy/phy.c |   24 ++++++++++++++++++++++++
>  include/linux/phy.h   |    4 ++++
>  2 files changed, 28 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 6f221c8..603e8db 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1347,3 +1347,27 @@ void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
>                 phydev->drv->get_wol(phydev, wol);
>  }
>  EXPORT_SYMBOL(phy_ethtool_get_wol);
> +
> +int phy_ethtool_get_link_ksettings(struct net_device *ndev,
> +                                  struct ethtool_link_ksettings *cmd)
> +{
> +       struct phy_device *phydev = ndev->phydev;
> +
> +       if (!phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_ksettings_get(phydev, cmd);
> +}
> +EXPORT_SYMBOL(phy_ethtool_get_link_ksettings);
> +
> +int phy_ethtool_set_link_ksettings(struct net_device *ndev,
> +                                  const struct ethtool_link_ksettings *cmd)
> +{
> +       struct phy_device *phydev = ndev->phydev;
> +
> +       if (!phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_ksettings_set(phydev, cmd);
> +}
> +EXPORT_SYMBOL(phy_ethtool_set_link_ksettings);
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index be3f83b..2d24b28 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -829,6 +829,10 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
>  int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
>  void phy_ethtool_get_wol(struct phy_device *phydev,
>                          struct ethtool_wolinfo *wol);
> +int phy_ethtool_get_link_ksettings(struct net_device *ndev,
> +                                  struct ethtool_link_ksettings *cmd);
> +int phy_ethtool_set_link_ksettings(struct net_device *ndev,
> +                                  const struct ethtool_link_ksettings *cmd);
>
>  int __init mdio_bus_init(void);
>  void mdio_bus_exit(void);
> --
> 1.7.4.4
>

Acked-By: David Decotigny <decot@googlers.com>
