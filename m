From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/7] net: dsa: add support for switchdev VLAN
 objects
Date: Thu, 13 Aug 2015 22:16:08 +0200
Message-ID: <20150813201608.GI32627@lunn.ch>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1439484743-5126-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439484743-5126-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 12:52:17PM -0400, Vivien Didelot wrote:
> Add new functions in DSA drivers to access hardware VLAN entries through
> SWITCHDEV_OBJ_PORT_VLAN objects:
> 
>  - port_pvid_get() and vlan_getnext() to dump a VLAN
>  - port_vlan_del() to exclude a port from a VLAN
>  - port_pvid_set() and port_vlan_add() to join a port to a VLAN
> 
> The DSA infrastructure will ensure that each VLAN of the given range
> does not already belong to another bridge. If it does, it will fallback
> to software VLAN and won't program the hardware.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h |  11 ++++
>  net/dsa/slave.c   | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 169 insertions(+)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 6356f43..bd9b765 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -298,6 +298,17 @@ struct dsa_switch_driver {
>  				   u8 state);
>  
>  	/*
> +	 * VLAN support
> +	 */
> +	int	(*port_pvid_get)(struct dsa_switch *ds, int port, u16 *pvid);
> +	int	(*port_pvid_set)(struct dsa_switch *ds, int port, u16 pvid);
> +	int	(*port_vlan_add)(struct dsa_switch *ds, int port, u16 vid,
> +				 bool untagged);
> +	int	(*port_vlan_del)(struct dsa_switch *ds, int port, u16 vid);
> @@ -794,6 +949,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
>  	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
>  	.ndo_poll_controller	= dsa_slave_poll_controller,
>  #endif
> +	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
> +	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
> +	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
>  };

Do these changes belong here?

Thanks
	Andrew
