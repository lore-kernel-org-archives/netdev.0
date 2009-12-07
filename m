From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 3/3] ixgb: increase skb size to prevent dma over skb
	boundary
Date: Mon, 7 Dec 2009 15:57:02 -0500
Message-ID: <20091207205702.GI8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <20091207144922.GD8073@hmsreliant.think-freely.org> <9929d2390912071254v24eb6980s1b43cf2e6f86f1dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39876 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935594AbZLGU45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 15:56:57 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390912071254v24eb6980s1b43cf2e6f86f1dc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 12:54:40PM -0800, Jeff Kirsher wrote:
> On Mon, Dec 7, 2009 at 06:49, Neil Horman <nhorman@tuxdriver.com> wro=
te:
> > Update xgb driver to not allow dma beyond the end of the allocated =
skb
> >
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >
> > ixgb_main.c | =A0 13 +++++++++----
> > 1 file changed, 9 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_m=
ain.c
> > index bcd0f01..2d8e699 100644
> > --- a/drivers/net/ixgb/ixgb_main.c
> > +++ b/drivers/net/ixgb/ixgb_main.c
> > @@ -798,14 +798,19 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
> >
> > =A0 =A0 =A0 =A0rctl |=3D IXGB_RCTL_SECRC;
> >
> > - =A0 =A0 =A0 if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_2048)
> > + =A0 =A0 =A0 if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_2048) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rctl |=3D IXGB_RCTL_BSIZE_2048;
> > - =A0 =A0 =A0 else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_40=
96)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_buffer_len =3D IXGB_RXBUF=
=46ER_2048;
> > + =A0 =A0 =A0 } else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_=
4096) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rctl |=3D IXGB_RCTL_BSIZE_4096;
> > - =A0 =A0 =A0 else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_81=
92)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_buffer_len =3D IXGB_RXBUF=
=46ER_4096;
> > + =A0 =A0 =A0 } else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_=
8192) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rctl |=3D IXGB_RCTL_BSIZE_8192;
> > - =A0 =A0 =A0 else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_16=
384)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_buffer_len =3D IXGB_RXBUF=
=46ER_8192;
> > + =A0 =A0 =A0 } else if (adapter->rx_buffer_len <=3D IXGB_RXBUFFER_=
16384) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rctl |=3D IXGB_RCTL_BSIZE_16384;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_buffer_len =3D IXGB_RXBUF=
=46ER_16384;
> > + =A0 =A0 =A0 }
> >
> > =A0 =A0 =A0 =A0IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
> > =A0}
> > --
>=20
> I have added this patch to my queue of ixgb patches for
> reveiw/testing.  Upon successful review/testing I will submit to
> Dave/netdev.
>=20
> --=20
> Cheers,
> Jeff
>=20
Um, Well, its already submitted to dave and netdev, but an ACK would su=
re be=20
appreciated pending your review. :)
Neil

