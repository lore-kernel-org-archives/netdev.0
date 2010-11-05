From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Fri, 05 Nov 2010 13:06:49 -0700
Message-ID: <1288987609.3091.16.camel@jtkirshe-MOBL1>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	 <1288984304.3091.11.camel@jtkirshe-MOBL1>
	 <AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-GkvJ83T/u4VoSz+fI9q0"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16657 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab0KEUGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 16:06:49 -0400
In-Reply-To: <AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GkvJ83T/u4VoSz+fI9q0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-11-05 at 12:56 -0700, Jesse Gross wrote:
> On Fri, Nov 5, 2010 at 12:11 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
> >> On transmit, the ixgb driver will only use vlan acceleration if a
> >> vlan group is configured.  This can lead to tags getting dropped
> >> when bridging because the networking core assumes that a driver
> >> that claims vlan acceleration support can do it at all times.  This
> >> change should have been part of commit eab6d18d "vlan: Don't check for
> >> vlan group before vlan_tx_tag_present." but was missed.
> >>
> >> Signed-off-by: Jesse Gross <jesse@nicira.com>
> >> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> >> ---
> >>  drivers/net/ixgb/ixgb_main.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main=
.c
> >> index caa8192..d18194e 100644
> >> --- a/drivers/net/ixgb/ixgb_main.c
> >> +++ b/drivers/net/ixgb/ixgb_main.c
> >> @@ -1498,7 +1498,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_=
device *netdev)
> >>                       DESC_NEEDED)))
> >>               return NETDEV_TX_BUSY;
> >>
> >> -     if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
> >> +     if (vlan_tx_tag_present(skb)) {
> >>               tx_flags |=3D IXGB_TX_FLAGS_VLAN;
> >>               vlan_id =3D vlan_tx_tag_get(skb);
> >>       }
> >
> > After further review, NAK because this will cause a bug.  With this
> > patch it would be possible to overrun the buffers, so the correct fix i=
s
> > to increase max_frame_size by VLAN_TAG_SIZE in ixgb/igb_change_mtu.
>=20
> Hmm, I didn't see any other place where it made changes to the
> handling of packets on transmit if a vlan group is configured.  Maybe
> the buffer is extended when a group is registered and stripping is
> enabled?
>=20
> In any case, you might want to check the other Intel drivers for
> similar problems.  I did a pass and made a mass conversion of this
> type a little while ago.  Those changes have already been merged, I
> just missed this one by accident.

I will get with Alex and review the other Intel drivers, thanks Jesse.

--=-GkvJ83T/u4VoSz+fI9q0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM1GPYAAoJECTsCADr/EWUoLMH/R74byPM4/kKtEhIV3+jkz0z
7Flw1bt6X6m/mTmYRq84EN6BTXUtYLzm9VK0c6+9mnhxCgZ6jsoMKqsqA6YkjaI4
A2vgJGoXVHQJzJJ/JvRHGKrbgJKNn2+0D3xwlGSpPTMmlmIMFO7lshugdAKKTCM5
d+WVZYI0hj8XM7QfanDYVkUSaqjMyGexqNI0/RWdOyaWMxh3yfKhakKH65SwPnju
u/hsoxOVbUvE573H5viVWsj0EYU1kxL+uLGPIi6mdOHLQhqDwmc/Wxn7kCFjIoYM
C62Mn9pztSfpor3mF95tyzh4JggsQr3gY8pkqN5vw/mY4EtsWBFmBGXto51Ciig=
=icW9
-----END PGP SIGNATURE-----

--=-GkvJ83T/u4VoSz+fI9q0--

