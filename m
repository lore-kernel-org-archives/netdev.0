From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCHv4 3/5] of: provide a binding for fixed link PHYs
Date: Fri, 16 May 2014 11:29:57 -0700
Message-ID: <CAGVrzcYWpHcnkCfRewx0jOoimkQi3RZaZM7sPjO13yg414Ztiw@mail.gmail.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1400249647-4643-4-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tawfik Bayouk <tawfik-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400249647-4643-4-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-05-16 7:14 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>:
> Some Ethernet MACs have a "fixed link", and are not connected to a
> normal MDIO-managed PHY device. For those situations, a Device Tree
> binding allows to describe a "fixed link" using a special PHY node.
>
> This patch adds:
>
>  * A documentation for the fixed PHY Device Tree binding.
>
>  * An of_phy_is_fixed_link() function that an Ethernet driver can call
>    on its PHY phandle to find out whether it's a fixed link PHY or
>    not. It should typically be used to know if
>    of_phy_register_fixed_link() should be called.
>
>  * An of_phy_register_fixed_link() function that instantiates the
>    fixed PHY into the PHY subsystem, so that when the driver calls
>    of_phy_connect(), the PHY device associated to the OF node will be
>    found.
>
> These two additional functions also support the old fixed-link Device
> Tree binding used on PowerPC platforms, so that ultimately, the
> network device drivers for those platforms could be converted to use
> of_phy_is_fixed_link() and of_phy_register_fixed_link() instead of
> of_phy_connect_fixed_link(), while keeping compatibility with their
> respective Device Tree bindings.
>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Tested-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  .../devicetree/bindings/net/fixed-link.txt         | 31 ++++++++++
>  drivers/of/of_mdio.c                               | 67 ++++++++++++++++++++++
>  include/linux/of_mdio.h                            | 15 +++++
>  3 files changed, 113 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt
>
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> new file mode 100644
> index 0000000..377f775
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -0,0 +1,31 @@
> +Fixed link Device Tree binding
> +------------------------------
> +
> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".
> +
> +Such a fixed link situation is described by creating a 'fixed-link'
> +sub-node of the Ethernet MAC device node, with the following
> +properties:
> +
> +* 'speed' (integer, mandatory), to indicate the link speed. Accepted
> +  values are 10, 100 and 1000
> +* 'full-duplex' (boolean, optional), to indicate that full duplex is
> +  used. When absent, half duplex is assumed.
> +* 'pause' (boolean, optional), to indicate that pause should be
> +  enabled.
> +* 'asym-pause' (boolean, optional), to indicate that asym_pause should
> +  be enabled.
> +
> +Example:
> +
> +ethernet@0 {
> +       ...
> +       fixed-link {
> +             speed = <1000>;
> +             full-duplex;
> +       };
> +       ...
> +};
> +
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 9a95831..1def0bb 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -14,6 +14,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/err.h>
>  #include <linux/phy.h>
> +#include <linux/phy_fixed.h>
>  #include <linux/of.h>
>  #include <linux/of_irq.h>
>  #include <linux/of_mdio.h>
> @@ -301,3 +302,69 @@ struct phy_device *of_phy_attach(struct net_device *dev,
>         return phy_attach_direct(dev, phy, flags, iface) ? NULL : phy;
>  }
>  EXPORT_SYMBOL(of_phy_attach);
> +
> +#if defined(CONFIG_FIXED_PHY)
> +/*
> + * of_phy_is_fixed_link() and of_phy_register_fixed_link() must
> + * support two DT bindings:
> + * - the old DT binding, where 'fixed-link' was a property with 5
> + *   cells encoding various informations about the fixed PHY
> + * - the new DT binding, where 'fixed-link' is a sub-node of the
> + *   Ethernet device.
> + */
> +bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +       struct device_node *dn;
> +       int len;
> +
> +       /* New binding */
> +       dn = of_get_child_by_name(np, "fixed-link");
> +       if (dn) {
> +               of_node_put(dn);
> +               return true;
> +       }
> +
> +       /* Old binding */
> +       if (of_get_property(np, "fixed-link", &len) &&
> +           len == (5 * sizeof(__be32)))
> +               return true;
> +
> +       return false;
> +}
> +EXPORT_SYMBOL(of_phy_is_fixed_link);
> +
> +int of_phy_register_fixed_link(struct device_node *np)
> +{
> +       struct fixed_phy_status status = {};
> +       struct device_node *fixed_link_node;
> +       const __be32 *fixed_link_prop;
> +       int len;
> +
> +       /* New binding */
> +       fixed_link_node = of_get_child_by_name(np, "fixed-link");
> +       if (fixed_link_node) {
> +               status.link = 1;
> +               status.duplex = of_property_read_bool(np, "full-duplex");
> +               if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
> +                       return -EINVAL;
> +               status.pause = of_property_read_bool(np, "pause");
> +               status.asym_pause = of_property_read_bool(np, "asym-pause");
> +               of_node_put(fixed_link_node);
> +               return fixed_phy_register(PHY_POLL, &status, np);
> +       }
> +
> +       /* Old binding */
> +       fixed_link_prop = of_get_property(np, "fixed-link", &len);
> +       if (fixed_link_prop && len == (5 * sizeof(__be32))) {
> +               status.link = 1;
> +               status.duplex = be32_to_cpu(fixed_link_prop[1]);
> +               status.speed = be32_to_cpu(fixed_link_prop[2]);
> +               status.pause = be32_to_cpu(fixed_link_prop[3]);
> +               status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
> +               return fixed_phy_register(PHY_POLL, &status, np);
> +       }
> +
> +       return -ENODEV;
> +}
> +EXPORT_SYMBOL(of_phy_register_fixed_link);
> +#endif
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 6fe8464..77a6e32 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -67,4 +67,19 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
>  }
>  #endif /* CONFIG_OF */
>
> +#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
> +extern int of_phy_register_fixed_link(struct device_node *np);
> +extern bool of_phy_is_fixed_link(struct device_node *np);
> +#else
> +static inline int of_phy_register_fixed_link(struct device_node *np)
> +{
> +       return -ENOSYS;
> +}
> +static inline bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +       return false;
> +}
> +#endif
> +
> +
>  #endif /* __LINUX_OF_MDIO_H */
> --
> 1.9.3



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
