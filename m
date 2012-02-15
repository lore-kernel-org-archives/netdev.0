From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Wed, 15 Feb 2012 15:32:10 -0500
Message-ID: <20120215203210.GA7502@elliptictech.com>
References: <20120215163748.GA3998@elliptictech.com>
 <1329333239.2469.3.camel@edumazet-laptop>
 <20120215195837.GA6754@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.scalarmail.ca ([98.158.95.75]:42012 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754846Ab2BOUcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 15:32:20 -0500
Content-Disposition: inline
In-Reply-To: <20120215195837.GA6754@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-02-15 14:58 -0500, Nick Bowler wrote:
> On 2012-02-15 20:13 +0100, Eric Dumazet wrote:
> > Le mercredi 15 f=E9vrier 2012 =E0 11:37 -0500, Nick Bowler a =E9cri=
t :
> > > We were testing IPsec with large mtu sizes (9000 bytes) and notic=
ed the
> > > occasional failure with large datagrams (requiring several fragme=
nts,
> > > >=3D25k bytes or so).  Investigating further, I was able to repro=
duce the
> > > issue without using IPsec at all.  Looking at the wireshark captu=
re I
> > > see that one of the fragments transmitted is totally bogus: porti=
ons of
> > > the payload data have made it onto the wire as the headers.  My t=
est
> > > case was this:
> > >=20
> > >   ping -c 1 -s 30000 -p 42 birch
> > >=20
> > > which is split into 4 frames, 3 of which (first, second and last)=
 look
> > > correct but the fourth consists entirely of 0x42 octets, includin=
g the
> > > ethernet and IP headers (so the source address is 42:42:42:42:42:=
42, the
> > > destination address is 42:42:42:42:42:42, ethertype is 0x4242, et=
c.)
> > > I've attached the wireshark capture (gzipped) since it's small en=
ough.
> > > Nevertheless, the total length is correct for the missing fragmen=
t.
> [...]
> > Interesting, but 2nd frame is also corrupted (not at the start but =
in
> > the middle)
>=20
> So it is, I missed that.  That looks like the missing headers stuck i=
n
> the middle of that frame, although the fragment offset appears to be
> wrong (and the more fragments flag is clear).  There's also two 0 byt=
es
> slightly before the headers.

Ah, I was misreading the fragment offset field.  That data in the
second packet looks like the headers for the final fragment (offset of
26928, MF clear), not the missing one.

Cheers,
--=20
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
