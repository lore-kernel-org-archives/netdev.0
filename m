From: Robin Holt <holt@sgi.com>
Subject: Re: gianfar.c null pointer deref in gfar_start_xmit().
Date: Tue, 9 Aug 2011 08:06:15 -0500
Message-ID: <20110809130615.GT4926@sgi.com>
References: <20110803024438.GH4926@sgi.com>
 <20110809065407.GF3709@sgi.com>
 <1312873813.2531.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robin Holt <holt@sgi.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:59222 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751016Ab1HINGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:06:17 -0400
Content-Disposition: inline
In-Reply-To: <1312873813.2531.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2011 at 09:10:13AM +0200, Eric Dumazet wrote:
> Le mardi 09 ao=FBt 2011 =E0 01:54 -0500, Robin Holt a =E9crit :
> > On Tue, Aug 02, 2011 at 09:44:38PM -0500, Robin Holt wrote:
> > >=20
> > > While using the v3.0 kernel on a Freescale P1010RDB with 3 minor =
patches
> > > (None which affect gianfar.c), I get a NULL pointer deref at:
> > >=20
> > > static int gfar_start_xmit(struct sk_buff *skb, struct net_device=
 *dev)
> > > {
> > > ...
> > > 	regs =3D tx_queue->grp->regs;
> > >=20
> > > I put a BUG_ON(tx_queue->grp) just before this line and it did tr=
ip.
> > > I have not looked at this any more than that.
> > >=20
> > > Any suggestions would be welcome.   To reproduce, all I need to d=
o is
> > > a few sequences of pings.
> >=20
> > I was able to reproduce this with the net-next-2.6 kernel as well.
> >=20
>=20
> This driver incorrectly assumes a non dense txqueue array is possible
> for a netdev, but its not true.
>=20
> In the meantime, you could force it to use one tx_queue only.
>=20
> tx_queues =3D (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
> num_tx_qs =3D tx_queues ? *tx_queues : 1;

I fixed up the .dts file and now it works.  I have not tested the RGMII
interface yet so I do not know if that supports multiple queues.  I ass=
ume
I could find it in the documentation.  What might I be looking for?

Thanks,
Robin
