From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: add support for switchdev FDB objects
Date: Tue, 4 Aug 2015 05:18:51 -0700
Message-ID: <CAE4R7bAmOzFUOoC1gQQMEuuM1v7U5WeF42d0+YFY1VcTZvrsFA@mail.gmail.com>
References: <1438669859-29800-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1438669859-29800-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438669859-29800-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 3, 2015 at 11:30 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Remove the fdb_{add,del,getnext} function pointer in favor of new
> port_fdb_{add,del,getnext}.
>
> Implement the switchdev_port_obj_{add,del,dump} functions in DSA to
> support the SWITCHDEV_OBJ_PORT_FDB objects.
>
> These functions are called from switchdev_port_bridge_{get,set,del}link.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6171.c |   3 -
>  drivers/net/dsa/mv88e6352.c |   3 -
>  include/net/dsa.h           |  16 ++--
>  net/dsa/slave.c             | 221 ++++++++++++++++++++++++--------------------
>  4 files changed, 129 insertions(+), 114 deletions(-)
>

[cut]

>  static int dsa_slave_bridge_port_join(struct net_device *dev,
>                                       struct net_device *br)
>  {
> @@ -765,9 +776,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
>         .ndo_change_rx_flags    = dsa_slave_change_rx_flags,
>         .ndo_set_rx_mode        = dsa_slave_set_rx_mode,
>         .ndo_set_mac_address    = dsa_slave_set_mac_address,
> -       .ndo_fdb_add            = dsa_slave_fdb_add,
> -       .ndo_fdb_del            = dsa_slave_fdb_del,
> -       .ndo_fdb_dump           = dsa_slave_fdb_dump,
> +       .ndo_fdb_add            = switchdev_port_fdb_add,
> +       .ndo_fdb_del            = switchdev_port_fdb_del,
> +       .ndo_fdb_dump           = switchdev_port_fdb_dump,
>         .ndo_do_ioctl           = dsa_slave_ioctl,
>         .ndo_get_iflink         = dsa_slave_get_iflink,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -775,11 +786,17 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
>         .ndo_netpoll_cleanup    = dsa_slave_netpoll_cleanup,
>         .ndo_poll_controller    = dsa_slave_poll_controller,
>  #endif
> +       .ndo_bridge_getlink     = switchdev_port_bridge_getlink,
> +       .ndo_bridge_setlink     = switchdev_port_bridge_setlink,
> +       .ndo_bridge_dellink     = switchdev_port_bridge_dellink,
>  };

These ndo_bridge_xxx changes aren't relevant to the patch, are they?
You'll need those for VLANs but not for FDBs.
