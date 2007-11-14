From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] IPV4: add raw drops counter
Date: Wed, 14 Nov 2007 09:27:14 +0800
Message-ID: <473A4EF2.5090507@cn.fujitsu.com>
References: <47397514.2070002@cn.fujitsu.com> <47398655.4060400@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:51697 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbXKNB3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 20:29:18 -0500
In-Reply-To: <47398655.4060400@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet said the following on 2007-11-13 19:11:
> Wang Chen a =C3=A9crit :
>> Add raw drops counter for IPv4 in /proc/net/raw .
>>
>> +    atomic_t        sk_drops;
>>  =20
> This doesnt need an atomic_t , just an 'unsigned int' is OK, since
> sock_queue_rcv_skb() is called on a locked socket.
>=20

Yes, sock_queue_rcv_skb() is called on a locked socket. But sk_drops
will not only used with sock_queue_rcv_skb(), but also with=20
xfrm4_policy_check(), skb_checksum_complete(), skb_kill_datagram(),etc.
So, atomic_t ensure sk_drops will be atomic increment.

> Also, I suggest doing the sk_drops increment in sock_queue_rcv_skb() =
so
> that it can be used for other sockets as well ?
>=20

As I described before, sk_drops will be used on different conditions,
on which the raw drop happens.
So doing sk_drops increment in upper caller is better than in=20
sock_queue_rcv_skb().

Thank you for your suggestion, I will make a new patch to add sk_drops
increment in other places.

> I like having this counter per socket, but only if an application can
> retrieve its value with a getsockopt() call, dont you think ?
>=20
> getsockopt(sock, SOL_SOCKET, SO_DROPSCNT, &val, &vallen);
>=20
>=20

Yes. I agree.
How do other people think about it?

