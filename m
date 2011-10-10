From: David Lamparter <equinox@diac24.net>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 17:28:45 +0200
Message-ID: <20111010152845.GC3260852@jupiter.n2.diac24.net>
References: <4E90212D.8030009@msgid.tls.msk.ru>
 <1318091046.5276.22.camel@edumazet-laptop>
 <4E9097C0.2030307@gmail.com>
 <20111010101954.GB2840382@jupiter.n2.diac24.net>
 <4E9307CB.4050704@msgid.tls.msk.ru>
 <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111010151343.GB3260852@jupiter.n2.diac24.net>
 <1318260235.3227.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Michael Tokarev <mjt@tls.msk.ru>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:36559 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab1JJP2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 11:28:53 -0400
Content-Disposition: inline
In-Reply-To: <1318260235.3227.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2011 at 05:23:55PM +0200, Eric Dumazet wrote:
> Le lundi 10 octobre 2011 =C3=A0 17:13 +0200, David Lamparter a =C3=A9=
crit :
> > On Mon, Oct 10, 2011 at 05:05:52PM +0200, Eric Dumazet wrote:
> > > > When pinging this NIC from another machine over VLAN5, I see
> > > > ARP packets coming to it, gets recognized and replies going
> > > > back, all on vlan 5.  But on the other side, replies comes
> > > > WITHOUT a VLAN tag!
> > > >=20
> > > > From this NIC's point of view, capturing on whole ethX:
> > > >=20
> > > > 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100=
), length 60: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4=
), Request who-has 10.48.11.2 tell 10.48.11.1, length 42
> > > > 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100=
), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4=
), Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 28
> > > >=20
> > > > From the partner point of view, also on whole ethX:
> > > >=20
> > > > 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100=
), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4=
), Request who-has 10.48.11.2 tell 10.48.11.1, length 28
> > > > 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype ARP (0x0806), =
length 60: Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90=
:27:30:6d:1c, length 46
> > > >=20
> > > > So, the tag gets eaten somewhere along the way... ;)
> >=20
> > Hmm. Looks like broken VLAN TX offload, but the driver doesn't even
> > implement VLAN offload. Maybe it's broken in its non-implementation=
=2E..
> >=20
> > Your "partner" is a known-good setup and can be assumed to be worki=
ng
> > correctly? This is over a crossover cable, no evil switches involve=
d?
> >=20
> > > > And I can't really recreate the situation which I had - I know
> > > > some packets were flowing, so at least ARP worked.  Now it
> > > > does not work anymore.
> > >=20
> > > What the 'partner' setup looks like ?
> > >=20
> > > ip link
> > > ip addr
> > > ip ro
> >=20
> > 'local' setup too please :)
>=20
> But here, the remote cleary sends an answer without VLAN tag ;)

Huh? The remote sends the ARP request to ff:f..f:ff, which has a VLAN
tag in both dumps - but the packet sent from the e100 only has a tag in
its own tcpdump... so it might pretty much wind up on the wire without =
a
tag due to some TX bug...

-David
