From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 04/17] ixgbevf: provide 64 bit statistics
Date: Mon, 20 Jun 2011 05:29:50 -0700
Message-ID: <1308572991.22851.50.camel@jtkirshe-mobl>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308545992.3539.114.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Gl6R4Gu3HQntvEb8xmjn"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab1FTM3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 08:29:52 -0400
In-Reply-To: <1308545992.3539.114.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Gl6R4Gu3HQntvEb8xmjn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-06-19 at 21:59 -0700, Eric Dumazet wrote:
> Le dimanche 19 juin 2011 =C3=A0 17:58 -0700, Jeff Kirsher a =C3=A9crit :
> > From: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > Compute statistics per ring using 64 bits, and provide
> > network device stats in 64 bits.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > Acked-by: Greg Rose <Gregory.v.rose@intel.com>
> > Tested-by: Evan Swanson <evan.swanson@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
>=20
> > =20
> > +static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *=
netdev,
> > +						   struct rtnl_link_stats64 *stats)
> > +{
> > +	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
> > +	int i;
> > +
> > +	ixgbevf_update_stats(adapter);
> > +
> > +	stats->multicast =3D adapter->stats.vfmprc - adapter->stats.base_vfmp=
rc;
> > +
> > +	for (i =3D 0; i < adapter->num_rx_queues; i++) {
> > +		stats->rx_bytes +=3D adapter->rx_ring[i].total_bytes;
> > +		stats->rx_packets +=3D adapter->rx_ring[i].total_packets;
> > +	}
> > +
> > +	for (i =3D 0; i < adapter->num_tx_queues; i++) {
> > +		stats->tx_bytes +=3D adapter->tx_ring[i].total_bytes;
> > +		stats->tx_packets +=3D adapter->tx_ring[i].total_packets;
> > +	}
> > +
> > +	return stats;
> > +}
> > +
>=20
> Unfortunately this patch is racy on 32bit arches.
>=20
> Jeff, maybe you missed all the discussion we had lately on these
> conversions, needing appropriate synchronization ?

I apologize I did not see the discussion regarding Stephen's patches.

>=20
> It seems a lot of bugs were added lately with Stephen patches, this is
> rather unfortunate...
>=20
> I guess I'll have to review them and send fixes.

I will drop Stephen's patch from this series and look forward to your
fixes.  Thanks Eric.



--=-Gl6R4Gu3HQntvEb8xmjn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/z0+AAoJECTsCADr/EWUa6sH/A2ABbdbsUlUpheuPpFhm08u
bmGIwtT0D+djRXfi7N69TuUaSNjl6wZsP4WQiQd3Ie+cLvg3/R9p+lRkSCBpzWV0
Cwmb3ojcKXzQ8YSN+erddpyj/FB14bOdbmyncSDWU7LqmqocZxk60KioqujC8MVB
WiTfO5PiZJoPPAq5KT20b6HJN3rXYizEfPzgm4YfRQUtYokBcnqR1PHMV23ga5K7
sn7m8c/DvAvaY8wKzOO6lgYOth37Fx9JJsRV8HH0WQLMOLqDeEt/qO3iNNgdU5hF
c2YIeFYDZCXBgynEWNLoLzfp/Q4nQkUqtRDjHRDJs025g00649Jf3aIa3GmUMwo=
=P34d
-----END PGP SIGNATURE-----

--=-Gl6R4Gu3HQntvEb8xmjn--

