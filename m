From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Mon, 04 Jul 2011 21:36:13 -0700 (PDT)
Message-ID: <20110704.213613.685614847140856200.davem@davemloft.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	<1309840429.2720.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab1GEEg3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:36:29 -0400
In-Reply-To: <1309840429.2720.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2011 06:33:49 +0200

> Le lundi 04 juillet 2011 =E0 21:20 -0700, David Miller a =E9crit :
>> +#define PACKET_FANOUT_MAX	2048
 ...
>> +	struct sock		*arr[PACKET_FANOUT_MAX];
>=20
> Thats about 16Kbytes, yet you use kzalloc()
>=20
>> +	spinlock_t		lock;
>> +	atomic_t		sk_ref;
>> +	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
>> +};
>> +
>=20
> Maybe use a dynamic array ? I suspect most uses wont even reach 16
> sockets anyway...

True.  Another option, for now, is to just make PACKET_FANOUT_MAX more
reasonable.  I'll make it something like 256.

Thanks!

