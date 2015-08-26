From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: fix EDSA frame from hwaccel frame
Date: Tue, 25 Aug 2015 18:28:34 -0700
Message-ID: <55DD1642.2020301@gmail.com>
References: <1438670111-31051-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438670111-31051-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 08/03/15 23:35, Vivien Didelot a =C3=A9crit :
> If the underlying network device features NETIF_F_HW_VLAN_CTAG_TX,
> an EDSA frame is prepended with a 802.1q header once queued.
>=20
> To fix this, push the VLAN tag to the payload if present, before
> checking the frame protocol.

Makes sense, but you would want Andrew or Guenter to ack this patch.

Thanks!

>=20
> [note: we may prefer to access directly VLAN TCI from hwaccel frames,
> but this approach is simpler.]
>=20
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/tag_edsa.c | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
> index 2288c80..3ada4eb 100644
> --- a/net/dsa/tag_edsa.c
> +++ b/net/dsa/tag_edsa.c
> @@ -9,6 +9,7 @@
>   */
> =20
>  #include <linux/etherdevice.h>
> +#include <linux/if_vlan.h>
>  #include <linux/list.h>
>  #include <linux/slab.h>
>  #include "dsa_priv.h"
> @@ -21,6 +22,10 @@ static struct sk_buff *edsa_xmit(struct sk_buff *s=
kb, struct net_device *dev)
>  	struct dsa_slave_priv *p =3D netdev_priv(dev);
>  	u8 *edsa_header;
> =20
> +	skb =3D vlan_hwaccel_push_inside(skb);
> +	if (unlikely(!skb))
> +		return NULL;
> +
>  	/*
>  	 * Convert the outermost 802.1q tag to a DSA tag and prepend
>  	 * a DSA ethertype field is the packet is tagged, or insert
>=20


--=20
=46lorian
