From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Mon, 09 Nov 2009 16:24:52 +0100
Message-ID: <4AF83444.9090208@simula.no>
References: <f7b4caf3a5b5c906cb8d508239455322.squirrel@webmail.uio.no> <4AEB0512.4010804@nets.rwth-aachen.de> <4AF2D47F.4030701@simula.no> <alpine.DEB.2.00.0911051536200.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:42778 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbZKIPYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 10:24:50 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N7W6x-0005vR-EU
	for netdev@vger.kernel.org; Mon, 09 Nov 2009 16:24:55 +0100
In-Reply-To: <alpine.DEB.2.00.0911051536200.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Thu, 5 Nov 2009, Andreas Petlund wrote:
>=20
>> Arnd Hannemann wrote:
>>> One example: Consider standard NewReno non-SACK enabled flow:
>>> For some reasons two data packets get reordered.
>>> The TCP sender will produce a dupACK and an ACK.
>>> The dupACK will trigger (because of your logic) a spurious retransm=
it.
>>> The spurious retransmit will trigger a dupACK.
>>> This dupACK will again trigger a spurious retransmit.
>>> And this game will continue, unless a packet is dropped by coincide=
nce.
>> Such an effect will be extremely rare. It will depend on the applica=
tion=20
>> producing an extremely even flow of packets with just the right=20
>> interarrival time, and also on reordering of data (which also will=20
>> happen very seldom when the number of packets in flight are so low).=
=20
>> Even though it can happen, the data flow will progress (with spuriou=
s=20
>> retransmissions). The effect will stop as soon as the application se=
nds=20
>> more than 4 segments in an RTT (which will disable the thin-stream=20
>> modifications) or less than 1 (which will cause all segments to be=20
>> successfully ACKed), or if, as you say, a packet is dropped.
>=20
> I'd simply workaround this problem by requiring SACK to be enabled fo=
r=20
> such a connection. This is reinforced by the fact that small windowed=
=20
> transfers want it certainly to be on anyway to get the best out of AC=
K=20
> flow even if there were some ACK losses.
>=20

Thanks. I will revise the patches based on all the feedback I have gott=
en
and get back to the list with a new version when I have done some more
testing.

Best regards,
Andreas



