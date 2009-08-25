From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 19:08:54 +0200
Message-ID: <4A941AA6.5070506@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org> <4A9410E9.6090602@gmail.com> <
 alpine.DEB.1.10.0908251230430.26329@gentwo.org> <4A9415F5.6020006@gmail.com> <alpine.DEB.1.10.0908251258000.26329@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54393 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbZHYRJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 13:09:00 -0400
In-Reply-To: <alpine.DEB.1.10.0908251258000.26329@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>>> The initial point was that the SNMP counters are not updated if IP_=
RECVERR
>>> is not set which is clearly a bug and your and my patch addresses t=
hat.
>> Technically speaking, the send() syscall is in error. Frame is not s=
ent, so
>> there is no drop at all. Like trying to send() from a bad user buffe=
r, or write()
>> to a too big file...
>=20
> Frame is submitted to the IP layer which discards it. That is the
> definition of an output discard.
>=20

Last patch accounts for this *error* AFAIK, or did I missed something ?


>> Question is : should we just allow send() to return an error (-ENOBU=
=46) regardless
>> of IP_RECVERR being set or not ? I dont think it would be so bad aft=
er all.
>> Most apps probably dont care, or already handle the error.
>=20
> Some applications will then start to fail because so far you can send=
 with
> impunity without getting errors. AFAICT IP_RECVERR was added to prese=
rve
> that behavior. Your patch is changing basic send() semantics.

Sorry ???, I guess your machines have plenty available LOWMEM then, and=
 kmalloc() never fail then...

man P send

      ENOBUFS
              Insufficient resources were available in the system to pe=
rform the operation.

basic send() semantics are respected.

