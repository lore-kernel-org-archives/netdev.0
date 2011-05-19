From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH FINAL] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Thu, 19 May 2011 16:19:30 -0400 (EDT)
Message-ID: <20110519.161930.928335634196492540.davem@davemloft.net>
References: <4DD575A1.4080405@gmail.com>
	<1305835101.3156.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: difrost.kernel@gmail.com, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1ESUTj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:19:39 -0400
In-Reply-To: <1305835101.3156.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 May 2011 21:58:21 +0200

> Le jeudi 19 mai 2011 =E0 21:55 +0200, Jacek Luczak a =E9crit :
>> During the sctp_close() call, we do not use rcu primitives to
>> destroy the address list attached to the endpoint.  At the same
>> time, we do the removal of addresses from this list before
>> attempting to remove the socket from the port hash
>>=20
>> As a result, it is possible for another process to find the socket
>> in the port hash that is in the process of being closed.  It then
>> proceeds to traverse the address list to find the conflict, only
>> to have that address list suddenly disappear without rcu() critical
>> section.
>>=20
>> Fix issue by closing address list removal inside RCU critical
>> section.
>>=20
>> Race can result in a kernel crash with general protection fault or
>> kernel NULL pointer dereference:
>>=20
>=20
>> Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
>> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> ---
>>  net/sctp/bind_addr.c |   10 ++++------
>>  1 files changed, 4 insertions(+), 6 deletions(-)
>>=20
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20

Applied and queued up for -stable.
