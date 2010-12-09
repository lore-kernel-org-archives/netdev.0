From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-2.6] net/ipv6/udp.c: fix typo in flush_stack()
Date: Thu, 9 Dec 2010 15:28:52 +0100
Message-ID: <20101209142851.GC2820@psychotron.brq.redhat.com>
References: <20101209134029.GB2820@psychotron.brq.redhat.com>
 <1291902488.4063.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056Ab0LIO24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 09:28:56 -0500
Content-Disposition: inline
In-Reply-To: <1291902488.4063.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 09, 2010 at 02:48:08PM CET, eric.dumazet@gmail.com wrote:
>Le jeudi 09 d=E9cembre 2010 =E0 14:40 +0100, Jiri Pirko a =E9crit :
>> skb1 should be passed as parameter to sk_rcvqueues_full() here.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 91def93..d2b268e 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -602,7 +602,7 @@ static void flush_stack(struct sock **stack, uns=
igned int count,
>> =20
>>  		sk =3D stack[i];
>>  		if (skb1) {
>> -			if (sk_rcvqueues_full(sk, skb)) {
>> +			if (sk_rcvqueues_full(sk, skb1)) {
>>  				kfree_skb(skb1);
>>  				goto drop;
>>  			}
>
>net-2.6 ? Its the same truesize anyway...

I know it is.

>
>So it's not a bug, but a cosmetic change.
>(I am ok with it, but for net-next-2.6)

Anything you like.

>
>/*
> * Take into account size of receive queue and backlog queue
> */
>static inline bool sk_rcvqueues_full(const struct sock *sk, const stru=
ct sk_buff *skb)
>{
>        unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->s=
k_rmem_alloc);
>
>        return qsize + skb->truesize > sk->sk_rcvbuf;
>}
>
>
