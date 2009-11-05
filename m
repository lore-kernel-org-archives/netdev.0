From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 5 Nov 2009 19:03:02 +0200
Message-ID: <200911051903.02859.opurdila@ixiacom.com>
References: <4AF1EC18.9090106@ixiacom.com> <200911051825.45749.opurdila@ixiacom.com> <4AF2FF22.2000805@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:30203 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755904AbZKERF7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:05:59 -0500
In-Reply-To: <4AF2FF22.2000805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 November 2009 18:36:50 you wrote:
> Octavian Purdila a =E9crit :
> > IIRC, we first saw this issue in VoIP tests with up to 16000 socket=
s
> > bound on a certain port and IP addresses (each IP address is assign=
ed to
> > a particular interface). We need this setup in order to emulate lot=
s of
> > VoIP users each with a different IP address and possible a differen=
t L2
> > encapsulation.
>=20
> Interesting case indeed, is it SIP 5060 port or RTP ports ?
> (I want to know how many messages per second you want to receive)
>=20
> An rbtree with 16000 elements has 15 levels, its a lot, but OK
> for small trafic.
>=20

Yep the signaling port not the RTP port, and yes I think there is a fai=
rly =20
small amount of traffic and rbtree might work.

BTW, there is another side of this problem, the time to bind() those 16=
K=20
sockets before starting the test - at least on 2.6.7 we didn't yet get =
to look=20
at this issue on a recent kernel.

Thanks,
tavi
