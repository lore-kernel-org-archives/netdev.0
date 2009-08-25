From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 17:58:08 +0200
Message-ID: <4A940A10.60607@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59973 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZHYP7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:59:10 -0400
In-Reply-To: <alpine.DEB.1.10.0908251135380.26329@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>> Christoph Lameter a ?crit :
>>> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>>>
>>>> Please hold on, I would like to fully understand what's happening,
>>>> and test the patch :)
>>> Ok. It would be good if the drops would also be somehow noted by th=
e UDP
>>> subsystem (one should see something with netstat -su) and may be ev=
en the
>>> socket. I see a drops column in /proc/net/udp. rx_drops, tx_drops?
>> This /proc/net/udp column is for rx_drops currently and was recently=
 added...
>=20
> So lets rename it to rx_drops and then add tx_drops?
>=20

It wont be very nice, because it'll add yet another 32bits counter in e=
ach socket
structure, for a unlikely use. While rx_drops can happen if application=
 is slow.

Also, tx_drops might be done later and not noticed.

Please read this old (and usefull) thread, with Alexey words...

http://oss.sgi.com/archives/netdev/2002-10/msg00612.html

http://oss.sgi.com/archives/netdev/2002-10/msg00617.html


So I bet your best choice is to set IP_RECVERR, as mentioned in 2002 by=
 Jamal and Alexey :)
