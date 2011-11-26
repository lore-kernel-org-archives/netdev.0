From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: ensure sk->dst is still valid
Date: Sat, 26 Nov 2011 15:57:57 -0500 (EST)
Message-ID: <20111126.155757.501820041622724078.davem@davemloft.net>
References: <1322239636-1839-1-git-send-email-fw@strlen.de>
	<1322281801.10212.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fw@strlen.de, netdev@vger.kernel.org, jchapman@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1KZU6U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 15:58:20 -0500
In-Reply-To: <1322281801.10212.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Nov 2011 05:30:01 +0100

> Le vendredi 25 novembre 2011 =E0 17:47 +0100, Florian Westphal a =E9c=
rit :
>> When using l2tp over ipsec, the tunnel will hang when rekeying
>> occurs. Reason is that the transformer bundle attached to the dst en=
try
>> is now in STATE_DEAD and thus xfrm_output_one() drops all packets
>> (XfrmOutStateExpired increases).
>>=20
>> Fix this by calling __sk_dst_check (which drops the stale dst
>> if xfrm dst->check callback finds that the bundle is no longer valid=
).
>>=20
>> Cc: James Chapman <jchapman@katalix.com>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> ---
>>  net/l2tp/l2tp_core.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>=20
>> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
>> index cf0f308..89ff8c6 100644
>> --- a/net/l2tp/l2tp_core.c
>> +++ b/net/l2tp/l2tp_core.c
>> @@ -1072,7 +1072,7 @@ int l2tp_xmit_skb(struct l2tp_session *session=
, struct sk_buff *skb, int hdr_len
>> =20
>>  	/* Get routing info from the tunnel socket */
>>  	skb_dst_drop(skb);
>> -	skb_dst_set(skb, dst_clone(__sk_dst_get(sk)));
>> +	skb_dst_set(skb, dst_clone(__sk_dst_check(sk, 0)));
>> =20
>>  	inet =3D inet_sk(sk);
>>  	fl =3D &inet->cork.fl;
>=20
> Seems good to me, although we could use RCU and skb_dst_set_noref() t=
o
> avoid dirtying dst refcount. I'll send a patch for net-next later.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
