From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v4)
Date: Mon, 12 Oct 2009 06:38:23 +0200
Message-ID: <4AD2B2BF.8040706@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091010123522.GA24193@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55273 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbZJLEjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 00:39:09 -0400
In-Reply-To: <20091010123522.GA24193@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Version 4
>=20
> Change Notes:
>=20
> 1) Remove the superfolous put_cmsg that I missed in the last version
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Create a new socket level option to report number of queue overflows
>=20
> Recently I augmented the AF_PACKET protocol to report the number of f=
rames lost
> on the socket receive queue between any two enqueued frames.  This va=
lue was
> exported via a SOL_PACKET level cmsg.  AFter I completed that work it=
 was
> requested that this feature be generalized so that any datagram orien=
ted socket
> could make use of this option.  As such I've created this patch, It c=
reates a
> new SOL_SOCKET level option called SO_RXQ_OVFL, which when enabled ex=
ports a
> SOL_SOCKET level cmsg that reports the nubmer of times the sk_receive=
_queue
> overflowed between any two given frames.  It also augments the AF_PAC=
KET
> protocol to take advantage of this new feature (as it previously did =
not touch
> sk->sk_drops, which this patch uses to record the overflow count).  T=
ested
> successfully by me.
>=20
> Notes:
>=20
> 1) Unlike my previous patch, this patch simply records the sk_drops v=
alue, which
> is not a number of drops between packets, but rather a total number o=
f drops.
> Deltas must be computed in user space.
>=20
> 2) While this patch currently works with datagram oriented protocols,=
 it will
> also be accepted by non-datagram oriented protocols. I'm not sure if =
thats
> agreeable to everyone, but my argument in favor of doing so is that, =
for those
> protocols which aren't applicable to this option, sk_drops will alway=
s be zero,
> and reporting no drops on a receive queue that isn't used for those
> non-participating protocols seems reasonable to me.  This also saves =
us having
> to code in a per-protocol opt in mechanism.
>=20
> 3) This applies cleanly to net-next assuming that commit
> 977750076d98c7ff6cbda51858bb5a5894a9d9ab (my af packet cmsg patch) is=
 reverted
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Thanks Neil

I found no obvious error in this v4, except two long lines.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
