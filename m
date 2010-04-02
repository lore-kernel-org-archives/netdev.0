From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Receive steering and hash and cache misses
Date: Fri, 02 Apr 2010 21:36:31 +0200
Message-ID: <1270236991.1978.17.camel@edumazet-laptop>
References: <20100402102650.5bdb5b52@nehalam>
	 <g2l65634d661004021059z94214a43v82409d15a0fb09b6@mail.gmail.com>
	 <20100402115439.348575c9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:57509 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab0DBTgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 15:36:36 -0400
Received: by bwz9 with SMTP id 9so1827310bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 12:36:34 -0700 (PDT)
In-Reply-To: <20100402115439.348575c9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 11:54 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Fri, 2 Apr 2010 10:59:43 -0700
> Tom Herbert <therbert@google.com> wrote:
>=20
> > On Fri, Apr 2, 2010 at 10:26 AM, Stephen Hemminger
> > <shemminger@vyatta.com> wrote:
> > >
> > > Although Receive Packet Steering can use a hardware generated rec=
eive hash
> > > the device driver still causes an unnecessary cache miss on the i=
nterrupt
> > > processing CPU.  The current Ethernet network device driver recei=
ve processing
> > > has the device driver calling eth_type_trans() which causes a the
> > > interrupt CPU to read the received frame header.
> > >
> >=20
> > It should be possible to deduce the values set by eth_type_trans fr=
om
> > the RX descriptor along with the RX hash.  I'll post the patch gett=
ing
> > rxhash from bnx2x which does this.
> >=20
>=20
> On sky2, I get only RSS, Checksum, and length from descriptor info.

Doesnt sky2 also provide vlan id (OP_RXVLAN/OP_RXCHKSVLAN) ?

A future version of hardware could provide more info perhaps...

Must eth_type_trans() be done *before* netif_receive_skb() ?

If a device provides a rxhash, maybe we can delay eth_type_trans() too.
If not, we need to access IP header anyway in the first cpu.


