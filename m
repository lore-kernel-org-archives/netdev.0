From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 18:27:21 +0200
Message-ID: <4A9410E9.6090602@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33005 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936AbZHYQ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:27:27 -0400
In-Reply-To: <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>> It wont be very nice, because it'll add yet another 32bits counter i=
n each socket
>> structure, for a unlikely use. While rx_drops can happen if applicat=
ion is slow.
>=20
> tx_drops happen if the application sends too fast.
>=20
> TX drop tracking is important due to the braindamaged throttling logi=
c
> during send. If SO_SNDBUF is less than what happens to fit in the TX =
ring then the
> application will be throttled and no packet loss happens. If SO_SNDBU=
=46 is
> set high then the TX ring will overflow and packets are dropped.
>=20
> We need some way to diagnose TX drops per socket as long as we have
> that mind boggling issue. TX drops means that one should reduce the s=
ize
> of the sendbuffer in order to get better throttling which reduces pac=
ket
> loss.
>=20
>> Also, tx_drops might be done later and not noticed.
>>
>> Please read this old (and usefull) thread, with Alexey words...
>>
>> http://oss.sgi.com/archives/netdev/2002-10/msg00612.html
>>
>> http://oss.sgi.com/archives/netdev/2002-10/msg00617.html
>>
>>
>> So I bet your best choice is to set IP_RECVERR, as mentioned in 2002=
 by Jamal and Alexey :)
>=20
> I read this just yesterday. IP_RECVERR means that the application wan=
ts to
> see details on each loss. We just want some counters that give us acc=
urate
> statistics to gauge where packet loss is occurring. Applications are
> usually not interested in tracking the fate of each packet.

Yep,  but IP_RECVERR also has the side effect of letting kernel returns=
 -ENOBUFS error
in sending and congestion, which was your initial point :)

