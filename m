From: David Decotigny <decot@googlers.com>
Subject: Re: [PATCH v2 1/3] net: core: ethtool: add ethtool_op_{get|set}_link_ksettings
Date: Mon, 9 May 2016 09:44:58 -0700
Message-ID: <CAG88wWaTrFp5-t5pLvndrLYhUkNF9smNMBPgvFtweqNP5jSD2Q@mail.gmail.com>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com> <1462743877-31738-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fugang.duan@nxp.com, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Liang, Kan" <kan.liang@intel.com>, aduyck@mirantis.com,
	jiri@mellanox.com, jacob.e.keller@intel.com, tom@herbertland.com,
	andrew@lunn.ch, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462743877-31738-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are you sure this belongs to ethtool.h? For one, I believe you need an
#include phy.h somewhere. I would suggest instead to keep this in
phy.h, presumably with a more explicit name suggesting that phydev is
involved.

On Sun, May 8, 2016 at 2:44 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
> Ethtool callbacks {get|set}_link_ksettings are often the same, so
> we add two generics functions ethtool_op_{get|set}_link_ksettings
> to avoid writing severals times the same function.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  include/linux/ethtool.h |    5 +++++
>  net/core/ethtool.c      |   24 ++++++++++++++++++++++++
>  2 files changed, 29 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 9ded8c6..9a55836 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -157,6 +157,11 @@ void ethtool_convert_legacy_u32_to_link_mode(unsigned long *dst,
>  bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
>                                      const unsigned long *src);
>
> +int ethtool_op_get_link_ksettings(struct net_device *ndev,
> +                                 struct ethtool_link_ksettings *cmd);
> +int ethtool_op_set_link_ksettings(struct net_device *ndev,
> +                                 const struct ethtool_link_ksettings *cmd);
> +
>  /**
>   * struct ethtool_ops - optional netdev operations
>   * @get_settings: DEPRECATED, use %get_link_ksettings/%set_link_ksettings
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index bdb4013..b605fb1 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -852,6 +852,30 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
>         return dev->ethtool_ops->set_settings(dev, &cmd);
>  }
>
> +int ethtool_op_get_link_ksettings(struct net_device *ndev,
> +                                 struct ethtool_link_ksettings *cmd)
> +{
> +       struct phy_device *phydev = ndev->phydev;
> +
> +       if (!phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_ksettings_get(phydev, cmd);
> +}
> +EXPORT_SYMBOL(ethtool_op_get_link_ksettings);
> +
> +int ethtool_op_set_link_ksettings(struct net_device *ndev,
> +                                 const struct ethtool_link_ksettings *cmd)
> +{
> +       struct phy_device *phydev = ndev->phydev;
> +
> +       if (!phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_ksettings_set(phydev, cmd);
> +}
> +EXPORT_SYMBOL(ethtool_op_set_link_ksettings);
> +
>  static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
>                                                   void __user *useraddr)
>  {
> --
> 1.7.4.4
>
