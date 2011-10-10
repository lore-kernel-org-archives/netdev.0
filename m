From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 17:23:55 +0200
Message-ID: <1318260235.3227.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E90212D.8030009@msgid.tls.msk.ru>
	 <1318091046.5276.22.camel@edumazet-laptop> <4E9097C0.2030307@gmail.com>
	 <20111010101954.GB2840382@jupiter.n2.diac24.net>
	 <4E9307CB.4050704@msgid.tls.msk.ru>
	 <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111010151343.GB3260852@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59515 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1JJPXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:23:40 -0400
Received: by bkbzt4 with SMTP id zt4so8591321bkb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:23:39 -0700 (PDT)
In-Reply-To: <20111010151343.GB3260852@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 17:13 +0200, David Lamparter a =C3=A9cr=
it :
> On Mon, Oct 10, 2011 at 05:05:52PM +0200, Eric Dumazet wrote:
> > > When pinging this NIC from another machine over VLAN5, I see
> > > ARP packets coming to it, gets recognized and replies going
> > > back, all on vlan 5.  But on the other side, replies comes
> > > WITHOUT a VLAN tag!
> > >=20
> > > From this NIC's point of view, capturing on whole ethX:
> > >=20
> > > 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100),=
 length 60: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4),=
 Request who-has 10.48.11.2 tell 10.48.11.1, length 42
> > > 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100),=
 length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4),=
 Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 28
> > >=20
> > > From the partner point of view, also on whole ethX:
> > >=20
> > > 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100),=
 length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4),=
 Request who-has 10.48.11.2 tell 10.48.11.1, length 28
> > > 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype ARP (0x0806), le=
ngth 60: Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:2=
7:30:6d:1c, length 46
> > >=20
> > > So, the tag gets eaten somewhere along the way... ;)
>=20
> Hmm. Looks like broken VLAN TX offload, but the driver doesn't even
> implement VLAN offload. Maybe it's broken in its non-implementation..=
=2E
>=20
> Your "partner" is a known-good setup and can be assumed to be working
> correctly? This is over a crossover cable, no evil switches involved?
>=20
> > > And I can't really recreate the situation which I had - I know
> > > some packets were flowing, so at least ARP worked.  Now it
> > > does not work anymore.
> >=20
> > What the 'partner' setup looks like ?
> >=20
> > ip link
> > ip addr
> > ip ro
>=20
> 'local' setup too please :)

But here, the remote cleary sends an answer without VLAN tag ;)

Maybe its a tg3 (we had a buggy driver until very recent change), or
tcpdump is not up2date...
