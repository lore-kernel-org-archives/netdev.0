From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Receive steering and hash and cache misses
Date: Fri, 2 Apr 2010 15:52:14 -0700
Message-ID: <20100402155214.0adfa9e2@nehalam>
References: <20100402102650.5bdb5b52@nehalam>
 <g2l65634d661004021059z94214a43v82409d15a0fb09b6@mail.gmail.com>
 <20100402115439.348575c9@nehalam>
 <1270236991.1978.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755425Ab0DCBxZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 21:53:25 -0400
In-Reply-To: <1270236991.1978.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Apr 2010 21:36:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 02 avril 2010 =C3=A0 11:54 -0700, Stephen Hemminger a =C3=
=A9crit :
> > On Fri, 2 Apr 2010 10:59:43 -0700
> > Tom Herbert <therbert@google.com> wrote:
> >=20
> > > On Fri, Apr 2, 2010 at 10:26 AM, Stephen Hemminger
> > > <shemminger@vyatta.com> wrote:
> > > >
> > > > Although Receive Packet Steering can use a hardware generated r=
eceive hash
> > > > the device driver still causes an unnecessary cache miss on the=
 interrupt
> > > > processing CPU.  The current Ethernet network device driver rec=
eive processing
> > > > has the device driver calling eth_type_trans() which causes a t=
he
> > > > interrupt CPU to read the received frame header.
> > > >
> > >=20
> > > It should be possible to deduce the values set by eth_type_trans =
from
> > > the RX descriptor along with the RX hash.  I'll post the patch ge=
tting
> > > rxhash from bnx2x which does this.
> > >=20
> >=20
> > On sky2, I get only RSS, Checksum, and length from descriptor info.
>=20
> Doesnt sky2 also provide vlan id (OP_RXVLAN/OP_RXCHKSVLAN) ?
>=20
> A future version of hardware could provide more info perhaps...

I have only some information from Marvell and no idea what they might
do with future hardware.=20

> Must eth_type_trans() be done *before* netif_receive_skb() ?

In current arch yes, because netif_receive_skb is used for multiple
hardware types and the backlog queue could theoretically contain
skb's of different hardware types.  Also GRO works against RPS
since it does lookup work on the initial CPU and dirties the skb.

This is mostly theoretical at this point the bigger performance bottlen=
ecks
are farther down the packet processing chain.



