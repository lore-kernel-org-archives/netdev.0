From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] IPV4: add raw drops counter
Date: Wed, 14 Nov 2007 07:00:52 +0100
Message-ID: <473A8F14.7050703@cosmosbay.com>
References: <47397514.2070002@cn.fujitsu.com> <47398655.4060400@cosmosbay.com> <473A4EF2.5090507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38526 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbXKNGBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:01:08 -0500
In-Reply-To: <473A4EF2.5090507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wang Chen a =C3=A9crit :
> Eric Dumazet said the following on 2007-11-13 19:11:
>> Wang Chen a =C3=A9crit :
>>> Add raw drops counter for IPv4 in /proc/net/raw .
>>>
>>> +    atomic_t        sk_drops;
>>>  =20
>> This doesnt need an atomic_t , just an 'unsigned int' is OK, since
>> sock_queue_rcv_skb() is called on a locked socket.
>>
>=20
> Yes, sock_queue_rcv_skb() is called on a locked socket. But sk_drops
> will not only used with sock_queue_rcv_skb(), but also with=20
> xfrm4_policy_check(), skb_checksum_complete(), skb_kill_datagram(),et=
c.
> So, atomic_t ensure sk_drops will be atomic increment.
>=20
>> Also, I suggest doing the sk_drops increment in sock_queue_rcv_skb()=
 so
>> that it can be used for other sockets as well ?
>>
>=20
> As I described before, sk_drops will be used on different conditions,
> on which the raw drop happens.
> So doing sk_drops increment in upper caller is better than in=20
> sock_queue_rcv_skb().
>=20
> Thank you for your suggestion, I will make a new patch to add sk_drop=
s
> increment in other places.
>=20

Thank you for clarifications, I was not aware upcoming patches were pla=
ned.


