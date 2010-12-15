From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 18:21:32 +0100
Message-ID: <4D08F91C.4070000@trash.net>
References: <1292421783.3427.232.camel@edumazet-laptop>	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net> <1292432980.3427.369.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55491 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab0LORVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 12:21:34 -0500
In-Reply-To: <1292432980.3427.369.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12.2010 18:09, Eric Dumazet wrote:
> Le mercredi 15 d=E9cembre 2010 =E0 18:03 +0100, Patrick McHardy a =E9=
crit :
>=20
>> Right, that's odd. It shouldn't be necessary anymore though since
>> now we initialize allot in sfq_enqueue() for all new flows and
>> increase allotment for all active flows once per round in sfq_dequeu=
e().
>> The above code causes a second increase for the flow following a flo=
w
>> which went inactive.
>=20
> Well, we do this in three places. Each time we 'select' a flow as the
> next packet provider, we increase its allot by quantum.
>=20
> We could change this, adding quantum to the current slot when its all=
ot
> becomes negative (and we select the next slot for next round)

Right, I again missed that 'a' refers to the next flow in the second
condition in sfq_dequeue().

I have to run now, will have another look at this tommorrow.
