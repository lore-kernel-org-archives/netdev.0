From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v1 4/9] forcedeth: stats for rx_packets based on
 hardware registers
Date: Thu, 10 Nov 2011 10:45:43 -0800
Message-ID: <CAG88wWbq4Gn-DTTkNNQkzG7p7db1xEUYmPYQNx0oKZP8FetJZA@mail.gmail.com>
References: <cover.1320875577.git.david.decotigny@google.com> <30a7c46d924c29d1faf879bc9522e4ec8565d378.1320875577.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30a7c46d924c29d1faf879bc9522e4ec8565d378.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After discussion with original author of patch  "forcedeth: statistics
optimization" (21828163b2b31e0675cb3e66a2a4a231dec06236), I will
revise this strategy, and step back to using software counters to make
the accounting of packets received at software level more accurate.
Will send an update to this series shortly.

Regards,

--
David Decotigny


On Wed, Nov 9, 2011 at 2:09 PM, David Decotigny
<david.decotigny@google.com> wrote:
> Use the hardware registers instead of a software implementation to
> account for the number of RX packets.
>
>
>
> Signed-off-by: David Decotigny <david.decotigny@google.com>
> ---
> =A0drivers/net/ethernet/nvidia/forcedeth.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/et=
hernet/nvidia/forcedeth.c
> index cd7f83d..0071d5c 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -1712,6 +1712,7 @@ static struct net_device_stats *nv_get_stats(st=
ruct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nv_get_hw_stats(dev);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* copy to net_device stats */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets =3D np->estats.rx=
_packets;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_packets =3D np->estats.t=
x_packets;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.rx_bytes =3D np->estats.rx_=
bytes;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_bytes =3D np->estats.tx_=
bytes;
> @@ -2690,7 +2691,6 @@ static int nv_rx_process(struct net_device *dev=
, int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_put(skb, len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, =
dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_gro_receive(&np->napi, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++;
> =A0next_pkt:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(np->get_rx.orig++ =3D=3D =
np->last_rx.orig))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->get_rx.orig =3D np=
->first_rx.orig;
> @@ -2773,7 +2773,6 @@ static int nv_rx_process_optimized(struct net_d=
evice *dev, int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__vlan=
_hwaccel_put_tag(skb, vid);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_gro_receive(&np->=
napi, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> --
> 1.7.3.1
>
>
