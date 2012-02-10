From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Fri, 10 Feb 2012 18:52:16 +0400
Message-ID: <4F352F20.8080807@parallels.com>
References: <4F352182.6060601@parallels.com> <1328884902.2443.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31007 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757911Ab2BJOw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 09:52:29 -0500
In-Reply-To: <1328884902.2443.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2012 06:41 PM, Eric Dumazet wrote:
> Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 17:54 +0400, Pavel Emelyanov =
a =C3=A9crit :
>> We're working on the checkpoint-restore project. To checkpoint a uni=
x socket
>> we need to read its skb queue. Analogous task for TCP sockets Tejun =
proposed
>> to solve with parasite + recvmsg + MSG_PEEK. That's nice, but doesn'=
t work
>> for unix sockets, because for them MSG_PEEK always peeks a single sk=
b from the=20
>> head of the queue.
>>
>> I propose to extend the MSG_PEEK functionality with two more flags t=
hat peek
>> either next not picked skb in queue or pick the last picked one. The=
 latter
>> ability is required to make it possible to re-read a message if MSG_=
TRUNC
>> was reported on it.
>>
>> These two flags can be used for unix stream sockets, since making th=
e MSG_PEEK
>> just report all data that fits the buffer length is bad -- we may ha=
ve scms
>> in queue thus turning stream socket into dgram one.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>
>> ---
>=20
> Nice !
>=20
> So this CR stuff assumes an application wont use itself MSG_PEEK /
> MORE / AGAIN ?

:( Not exactly. MSG_PEEK will still work, but PEEK_MORE/PEEK_AGAIN will=
 not.

Hm... This means that the state of "what was peek-ed already" should be=
 on
the user side. Can we pass some "offset" (in bytes for stream and in pa=
ckets
for datagram) to the recvmsg?

> (skb->peeked can only be set, never unset)
