From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 00:35:58 +0100
Message-ID: <496D255E.2050804@cosmosbay.com>
References: <4966F2F4.9080901@cosmosbay.com>	<20090109070415.GA27758@1wt.eu>	<4966FC89.8040006@cosmosbay.com> <20090113.152759.29875009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: w@1wt.eu, ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54590 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760196AbZAMXhv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:37:51 -0500
In-Reply-To: <20090113.152759.29875009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 09 Jan 2009 08:28:09 +0100
>=20
>> If the application uses setsockopt(sock, SOL_SOCKET, SO_RCVLOWAT,
>> [32768], 4), it would be good if kernel was smart enough and could
>> reduce number of wakeups.
>=20
> Right, and as I pointed out in previous replies the problem is
> that splice() receive in TCP doesn't check the low water mark
> at all.
>=20
>=20

Yes I understand, but if splice() is running, wakeup occured, and
no need to check if the wakeup was good or not... just proceed and
consume some skb, since we already were awaken.

Then, an application might setup a high SO_RCVLOWAT, but want to splice=
()
only few bytes, so RCVLOWAT is only a hint for the thing that perform t=
he
wakeup, not for the consumer.


