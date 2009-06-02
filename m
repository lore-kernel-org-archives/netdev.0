From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 07:31:12 +0200
Message-ID: <4A24B920.2010605@cosmosbay.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601.190430.80366622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@dev.6wind.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:55009 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778AbZFBFbZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 01:31:25 -0400
In-Reply-To: <20090601.190430.80366622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Mon, 01 Jun 2009 17:13:43 +0200
>=20
>> RFC indicates that a router must drop the packet if this field is 0.
>=20
> It only must do this when executing the forwarding function.  It's an
> egress check, not an ingress one.
>=20
> I'm not applying this patch, it can even break some applications
> out there that use a TTL of zero intentionally to keep traffic
> only on a local subnet.

I wonder if we then should allow setting ttl to zero. I had to patch
my kernel to allow ping to do this...

I'll check RFC when time permits.

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e2d1f87..efe2797 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -558,7 +558,7 @@ static int do_ip_setsockopt(struct sock *sk, int le=
vel,
 	case IP_TTL:
 		if (optlen<1)
 			goto e_inval;
-		if (val !=3D -1 && (val < 1 || val>255))
+		if (val !=3D -1 && (val < 0 || val>255))
 			goto e_inval;
 		inet->uc_ttl =3D val;
 		break;


