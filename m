From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Thu, 05 Nov 2009 18:39:52 +0100
Message-ID: <4AF30DE8.8010102@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <200911051825.45749.opurdila@ixiacom.com> <4AF2FF22.2000805@gmail.com> <200911051903.02859.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32780 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbZKERjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:39:52 -0500
In-Reply-To: <200911051903.02859.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Thursday 05 November 2009 18:36:50 you wrote:
>> Octavian Purdila a =E9crit :
>>> IIRC, we first saw this issue in VoIP tests with up to 16000 socket=
s
>>> bound on a certain port and IP addresses (each IP address is assign=
ed to
>>> a particular interface). We need this setup in order to emulate lot=
s of
>>> VoIP users each with a different IP address and possible a differen=
t L2
>>> encapsulation.
>> Interesting case indeed, is it SIP 5060 port or RTP ports ?
>> (I want to know how many messages per second you want to receive)
>>
>> An rbtree with 16000 elements has 15 levels, its a lot, but OK
>> for small trafic.
>>
>=20
> Yep the signaling port not the RTP port, and yes I think there is a f=
airly =20
> small amount of traffic and rbtree might work.
>=20
> BTW, there is another side of this problem, the time to bind() those =
16K=20
> sockets before starting the test - at least on 2.6.7 we didn't yet ge=
t to look=20
> at this issue on a recent kernel.
>=20

Yes, this is O(N^2) algo :

0.3 seconds to bind 8000 UDP sockets on same port (different IPs)
1.5 secs / 12000 sockets
5.3 secs / 16000 sockets=20
18  secs / 24000 sockets
36  secs / 32000 sockets

