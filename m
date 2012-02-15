From: Bill Fink <billfink@mindspring.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 02:52:00 -0500
Message-ID: <20120215025200.6e6f02a2.billfink@mindspring.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<5133914.uYLb0gnNTc@localhost.localdomain>
	<1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<5781419.24ZaHfTAxC@localhost.localdomain>
	<1329280993.2555.21.camel@edumazet-laptop>
	<CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
	<1329286016.2555.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>, alekcejk@googlemail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:59134
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757910Ab2BOHwD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 02:52:03 -0500
In-Reply-To: <1329286016.2555.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Feb 2012, Eric Dumazet wrote:

> Le mercredi 15 f=E9vrier 2012 =E0 01:03 -0500, Neal Cardwell a =E9cri=
t :
> > There are some potentially interesting differences in sysctl values=
:
> >=20
> > > diff -u /tmp/sysctl-a-3.1.txt /tmp/sysctl-a-3.2.txt  | grep mem_d=
ef
> > -net.core.wmem_default =3D 114688
> > -net.core.rmem_default =3D 114688
> > +net.core.wmem_default =3D 163840
> > +net.core.rmem_default =3D 163840
> >=20
> > Can you please try running this as root on the 3.2 kernel and then =
see
> > what sort of performance you get:
> >=20
> > sysctl net.core.rmem_default=3D114688
> >=20
> > This should make the 3.2 config closer to the 3.1 config. Should be
> > interesting to see if the behavior is more similar when that happen=
s.
> >=20
> > neal
>=20
> These changes are normal, since skb truesize  now include shared_info=
=2E
>=20
> By the way, these params are not used for tcp streams.
>=20
> This is why I asked netstat -s values, to check if we had drops becau=
se
> of truesize limits.
>=20
> Its not the case here since skb are not too fat (as some NICS can do,
> using a full PAGE to hold a single 1500 bytes frams)

Would it be useful to check if there was any difference in
TCP parameters between the 3.1 and 3.2 kernels by performing
the following on each:

	grep . /sys/module/tcp_*/parameters/*

					-Bill
