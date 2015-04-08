From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH v3 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Wed, 08 Apr 2015 15:28:12 -0700
Message-ID: <1428532092.2616.3.camel@jtkirshe-mobl.jf.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
	 <5525A876.2000407@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2oZRgmSAsCqjwq6Lhtxg"
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5525A876.2000407@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2oZRgmSAsCqjwq6Lhtxg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 15:15 -0700, Alexander Duyck wrote:
> On 04/07/2015 10:38 PM, Hiroshi Shimamoto wrote:
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >
> > Implements the new netdev op to allow VF multicast promiscuous mode.
> >
> > The multicast promiscuous mode is not allowed for all VFs by default.
> >
> > The administrator can allow to VF multicast promiscuous mode for only
> > trusted VM. After allowing multicast promiscuous mode from the host,
> > we can use over 30 IPv6 addresses on VM.
> >  # ip link set dev eth0 vf 1 mc_promisc on
> >
> > When disallowing multicast promiscuous mode, ixgbevf can only handle 30
> > IPv6 addresses at most.
> >  # ip link set dev eth0 vf 1 mc_promisc off
> >
> > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32 ++++++++++++++++++=
++++++--
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
> >  4 files changed, 40 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/eth=
ernet/intel/ixgbe/ixgbe.h
> > index 08e65b6..4a9f74d 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > @@ -153,6 +153,7 @@ struct vf_data_storage {
> >  	u16 vlan_count;
> >  	u8 spoofchk_enabled;
> >  	bool rss_query_enabled;
> > +	u8 mc_promisc_allowed;
> >  	unsigned int vf_api;
> >  };
> > =20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
> > index 2f41403..c0e07c5 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -3663,6 +3663,12 @@ static void ixgbe_configure_virtualization(struc=
t ixgbe_adapter *adapter)
> >  		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
> >  					      adapter->vfinfo[i].rss_query_enabled);
> >  	}
> > +
> > +	/* Reconfigure multicast promiscuous mode */
> > +	for (i =3D 0; i < adapter->num_vfs; i++) {
> > +		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
> > +					adapter->vfinfo[i].mc_promisc_allowed);
> > +	}
> >  }
> > =20
> >  static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
>=20
> This doesn't need to be a separate loop.  You can push it up into the
> block above since it is already looping through all VFs.
>=20
> Once that is fixed the rest of this patch and the other two looked fine
> to me.

Hiroshi I am dropping this series and will await v4.

Remember to send them to intel-wired-lan mailing list, please.


--=-2oZRgmSAsCqjwq6Lhtxg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJat8AAoJEOVv75VaS+3O3HwP/0DfNPK6rsBmFc6mK4Iq0Dj9
vUOuieOvqxRLoddKjDh3BHo8Gn2Wrl7vxEReAYQeXaobbnZi95WgYJ1qFmDxs45o
R5/lJW2qZwbC2oIN/f7JWx1bS2HHjdLIJ7/1juygpHyZpkqYhbqZDOb6vND0qO35
0wbfnbWMbtlmvXiyu3lpRUCjSeFJBttWg1pVQ7KRDGkjA0FleBX5xPc/eGFHqFJ3
OVZ6aaoqy69uQBnNy5YDiIO6QLo2TT/i+Yp5LsO5u8N60Cx2JDSg0swPdWYEwRY6
79svBuK7eCj/7OMFadtJPFAl1aE1apo7fxMsENs+EBHIKQAo8/mXxkOkf6izrCEM
eCJPnmL3ZiKOx4UrMy1VC5lhSIP93lsBYs8o8ZQdkGcaQpul6Soo9nM9PiMhMfIE
hpc8hy9NcTGOvB973uIpncDk7cuVrhR/M16qv5X4Q3YuUbZTYTUrvTmr0+XXcPM0
8oEaaXC9QIzugYKassi6+AaZQATtPCuxvKJ07wqHKYB2t6YLYXLj2q936+A9pda3
q+S00WKktPhZV/rnQ/BCAMfH2BLciOy8bLsuRdZwJ6YRVUPwqalqQmr7Nn3YfJ46
nco27xAXkM5gMsjf8GcxM/9VwdjjiuQKXLSrfOcB+oJ9o/Y8XIGPj7i8up1KQs77
MQEM+V9P6Ha4aGq73oTF
=4NQR
-----END PGP SIGNATURE-----

--=-2oZRgmSAsCqjwq6Lhtxg--
