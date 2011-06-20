From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 04/17] ixgbevf: provide 64 bit statistics
Date: Mon, 20 Jun 2011 06:59:52 +0200
Message-ID: <1308545992.3539.114.camel@edumazet-laptop>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52731 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab1FTFAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 01:00:02 -0400
Received: by wyb38 with SMTP id 38so1388955wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 22:00:01 -0700 (PDT)
In-Reply-To: <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 17:58 -0700, Jeff Kirsher a =C3=A9crit =
:
> From: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Compute statistics per ring using 64 bits, and provide
> network device stats in 64 bits.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Greg Rose <Gregory.v.rose@intel.com>
> Tested-by: Evan Swanson <evan.swanson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

> =20
> +static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device=
 *netdev,
> +						   struct rtnl_link_stats64 *stats)
> +{
> +	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
> +	int i;
> +
> +	ixgbevf_update_stats(adapter);
> +
> +	stats->multicast =3D adapter->stats.vfmprc - adapter->stats.base_vf=
mprc;
> +
> +	for (i =3D 0; i < adapter->num_rx_queues; i++) {
> +		stats->rx_bytes +=3D adapter->rx_ring[i].total_bytes;
> +		stats->rx_packets +=3D adapter->rx_ring[i].total_packets;
> +	}
> +
> +	for (i =3D 0; i < adapter->num_tx_queues; i++) {
> +		stats->tx_bytes +=3D adapter->tx_ring[i].total_bytes;
> +		stats->tx_packets +=3D adapter->tx_ring[i].total_packets;
> +	}
> +
> +	return stats;
> +}
> +

Unfortunately this patch is racy on 32bit arches.

Jeff, maybe you missed all the discussion we had lately on these
conversions, needing appropriate synchronization ?

It seems a lot of bugs were added lately with Stephen patches, this is
rather unfortunate...

I guess I'll have to review them and send fixes.


