From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Sat, 13 Dec 2014 00:47:45 +0100
Message-ID: <1500356.bBOpW4o4zG@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <548B5E6E.6010208@intra2net.com> <1418423509.13491.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49194 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752782AbaLLXrs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 18:47:48 -0500
In-Reply-To: <1418423509.13491.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 12. Dezember 2014, 14:31:49 schrieben Sie:
> On Fri, 2014-12-12 at 22:30 +0100, Thomas Jarosch wrote:
> > if it's any help: Disabling TX checksumming prevents the hang
> > even on an unpatched 3.14.x kernel. You could check with your debug
> > statements in place the path of the packets with and without TX
> > checksumming.

I can't disable it as the driver will not allow it:
# ethtool -K eth0 tx off
Cannot change tx-checksumming
Could not change any device features

> Disabling TX checksum automatically disables GSO.
>=20
> Disabling TSO/GSO is the real 'cure' for the time being, you can keep=
 TX
> checksums.

This does not help here. With GSO disabled (for network device serving =
the=20
ipsec traffic, here e.g. eth0) the hang still occurs. tcp_set_skb_tso_s=
egs()=20
gets called and the else-branch for skb->len <=3D mss_now is taken.

I tested this serveral times.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
