From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 16:50:18 +0100
Message-ID: <4AE9B9BA.7020207@gmail.com>
References: <69812160e5682c9fb4acba05bc082664.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: apetlund@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34798 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930AbZJ2Pu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 11:50:26 -0400
In-Reply-To: <69812160e5682c9fb4acba05bc082664.squirrel@webmail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

apetlund@simula.no a =E9crit :
>> Andreas Petlund a =E9crit :

>> There should be a limit to linear timeouts, to say ... no more than =
6
> retransmits
>> (eventually tunable), then switch to exponential backoff. Maybe your
> patch
>> already implement such heuristic ?
>>
>=20
> The limitation you suggest to the linear timeouts makes very good sen=
se.
> Our experiments performed on the Internet indicate that it is extreme=
ly
> rare that more than 6 retransmissions are needed to recover. It is no=
t
> included in the current patch, so I will include this in the next
> iteration.
>=20
>> True link collapses do happen, it would be good if not all streams
> wakeup
>> in the same
>> second and make recovery very slow.
>>
>=20
> Each stream will have its own schedule for wakeup, so such events wil=
l
> still be subject to coincidence. The timer granularity of the TCP wak=
eup
> timer will also influence how many streams will wake at the same time=
=2E The
> experiments we have performed on severely congested bottlenecks (link
> above) indicate that the modifications will not create a large negati=
ve
> effect. In fact, when goodput is drastically reduced due to severe
> overload, regular TCP and the LT and dupACK modifications seem to per=
form
> nearly identically. Other scenarios may exist where different effects=
 can
> be observed, and I am open to suggestions for further testing.
>=20
>> Thats too easy to accept possibly dangerous features with the excuse=
 of
> saying
>> "It wont be used very much", because you cannot predict the future.
>=20
> I agree that it is no argument to say that it won't be used much; ind=
eed,
> my hope is that it will be used much. However, our experiments indica=
te no
> negative effects while showing a large improvement on retransmission
> latency for the scenario in question. I therefore think that the opti=
on
> for such an improvement should be made available for time-dependent
> thin-stream applications.
>=20

Thanks ! I must say I am very interested by these experiments, I am loo=
king
forward your next iteration.

