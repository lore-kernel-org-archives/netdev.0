From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 10:54:27 +0200
Message-ID: <20070729085427.GA22784@1wt.eu>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu> <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4060 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760663AbXG2Iyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 04:54:36 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 29, 2007 at 11:26:00AM +0300, Ilpo J=E4rvinen wrote:
> On Sun, 29 Jul 2007, Willy Tarreau wrote:
>=20
> > On Sun, Jul 29, 2007 at 06:59:26AM +0100, Darryl L. Miles wrote:
> > > CLIENT =3D Linux 2.6.20.1-smp [Customer build]
> > > SERVER =3D Linux 2.6.9-55.ELsmp [Red Hat Enterprise Linux AS rele=
ase 4=20
> > > (Nahant Update 5)]
> > >=20
> > > The problems start around time index 09:21:39.860302 when the CLI=
ENT issues=20
> > > a TCP packet with SACK option set (seemingly for a data segment w=
hich has=20
> > > already been seen) from that point on the connection hangs.
>=20
> ...That's DSACK and it's being correctly sent. To me, it seems unlike=
ly to=20
> be the cause for this breakage...
>=20
> > Where was the capture taken ? on CLIENT or on SERVER (I suspect cli=
ent from
> > the timers) ?=20
>=20
> ...I would guess the same based on SYN timestamps (and from the DSACK=
=20
> timestamps)...
>=20
> > A possible, but very unlikely reason would be an MTU limitation
> > somewhere, because the segment which never gets correctly ACKed is =
also the
> > largest one in this trace.
>=20
> Limitation for 48 byte segments? You have to be kidding... :-) But ye=
s,
> it seems that one of the directions is dropping packets for some reas=
on=20
> though I would not assume MTU limitation... Or did you mean some othe=
r=20
> segment?

No, I was talking about the 1448 bytes segments. But in fact I don't
believe it much because the SACKs are always retransmitted just afterwa=
rds.

BTW, some information are missing. It would have been better if the tra=
ce
had been read with tcpdump -Svv. We would have got seq numbers and ttl.
Also, we do not know if there's a firewall between both sides. Sometime=
s,
some IDS identify attacks in crypted traffic and kill connections. It
might have been the case here, with the connection closed one way on an
intermediate firewall.

Regards,
Willy

