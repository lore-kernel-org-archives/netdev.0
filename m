From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 11:27:12 -0700 (PDT)
Message-ID: <20110406.112712.71110955.davem@davemloft.net>
References: <1302113253.3209.126.camel@edumazet-laptop>
	<20110406.111712.226782643.davem@davemloft.net>
	<1302114188.3209.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756170Ab1DFS1t convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 14:27:49 -0400
In-Reply-To: <1302114188.3209.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Apr 2011 20:23:08 +0200

> Le mercredi 06 avril 2011 =E0 11:17 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 06 Apr 2011 20:07:33 +0200
>>=20
>> > This is why we used on ipv4 :
>> >=20
>> > if (inet_sk(sk)->inet_daddr)
>> > 	sock_rps_save_rxhash(sk, skb->rxhash);
>> >=20
>> >=20
>> > Only arm RFS on UDP if socket is bound to a given remote peer.
>>=20
>> Agreed, Neil please make this change to your ipv6 code.
>=20
> BTW, do you guys know if NFS is using RFS right now (if TCP transport=
 is
> used) ?

It ought to be.  Are you specifically concerned that it might be
missing the rxhash setting calls because of the APIs it uses to
do socket I/O?

The SunRPC layer is a major user of tcp_read_sock(), for example.

But the packet processing will be done via the normal means,
therefore we'll hit tcp_v4_do_rcv() and therefore save the
rxhash.
