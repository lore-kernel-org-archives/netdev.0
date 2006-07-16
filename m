From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCHv2  2.6.18-rc1-mm2   1/3]  net:  UDP-Lite generic support
Date: Sun, 16 Jul 2006 10:29:48 +0100
Message-ID: <200607161029.48628@strip-the-willow>
References: <E1G1kGi-000549-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-6
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, davem@davemloft.net, yoshfuji@linux-ipv6.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@coreworks.de,
	pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:24211 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1750831AbWGPJcQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 05:32:16 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G1kGi-000549-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Herbert Xu:
|  > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case SO_NO_CHECK:
|  > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_no_check =3D =
valbool;
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* UDP-Lite (RFC 382=
8) mandates checksumming,
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* hence user must=
 not enable this option. =A0 */
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_protocol =
=3D=3D IPPROTO_UDPLITE)
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =
=3D -EOPNOTSUPP;
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_no_ch=
eck =3D valbool;
| =20
|  Please don't add protocol-specific stuff to generic functions. =A0In=
 this
|  case why don't you just ignore sk_no_check for UDPLITE as we do for =
TCP?

Thank you for spotting this -- the UDP-Lite code indeed ignores sk_no_c=
heck
and will (if no socket options are set) emulate UDP with sk_no_check =3D=
 0. Setting
it to 1 will make no difference; so the above is more not strictly nece=
ssary. Will=20
remove in next patch.
Any other comments or ideas, please do not hesitate to write.=20

-- Gerrit
