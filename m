From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 08:05:19 +0200
Message-ID: <4AD80D1F.3090601@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com> <4AD7FE01.1010805@gmail.com> <20091016052913.GB5574@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35759 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbZJPGGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 02:06:38 -0400
In-Reply-To: <20091016052913.GB5574@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Fri, Oct 16, 2009 at 07:00:49AM +0200, Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>>
>>> So, it appears defer_accept value is not an inherited attribute,
>>> but shared by all embryons. Therefore we should not touch it.
>>>
>>> Of course it should be done, or add a new connection field to count=
 number
>>> of pure ACKS received on each SYN_RECV embryon.
>>>
>> Could be something like this ? (on top of net-next-2.6 of course)
>>
>> 7 bits is more than enough, we could take 5 bits IMHO.
>=20
> Couldn't we just rely on the retrans vs rskq_defer_accept comparison =
?
>=20

In this case, we lose TCP_DEFER_ACCEPT advantage in case one SYN-ACK wa=
s dropped
by the network : We wakeup the listening server when first ACK comes fr=
om client,
instead of really wait the request.

I think being able to count pure-acks would be slighly better, and cost=
 nothing.


retrans is the number of SYN-RECV (re)sent, while req_acks would count =
number of
pure ACK received.

Those numbers, in an ideal world should be related, but could differ in=
 real world ?

