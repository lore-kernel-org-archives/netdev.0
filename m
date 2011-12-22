From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 21:42:02 +0800
Message-ID: <4EF333AA.7040400@linux.vnet.ibm.com>
References: <4EF1B0D9.2010007@monstr.eu> <4EF30744.6000509@linux.vnet.ibm.com> <1324550811.2153.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EF32A21.3060503@linux.vnet.ibm.com> <1324560068.2153.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:60631 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab1LVNmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 08:42:17 -0500
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Thu, 22 Dec 2011 19:12:14 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBMDg9sc4403420
	for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 19:12:10 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBMDg9Oi007265
	for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 00:42:09 +1100
In-Reply-To: <1324560068.2153.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2011 09:21 PM, Eric Dumazet wrote:

> Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 21:01 +0800, Michael Wang a =C3=
=A9crit :
>=20
>> Hi, Eric
>>
>> So do you mean the way is:
>>
>> ip_local_deliver_finish --> raw_local_deliver --> raw_v4_input -->
>> raw_rcv --> raw_rcv_skb --> sock_queue_rcv_skb
>>
>> And in sock_queue_rcv_skb:
>>
>>         if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
>>             (unsigned)sk->sk_rcvbuf) {
>>                 atomic_inc(&sk->sk_drops);
>>                 trace_sock_rcvqueue_full(sk, skb);
>>                 return -ENOMEM;				//drop?
>>         }
>>
>> Is this the way the packet being dropped? Is this confirmed by some =
printk?
>>
>> Sorry if the question is naive, I just want to make sure I am checki=
ng
>> at the right place.
>>
>=20
> Yep
>=20
> Are you aware I already posted a patch to solve the problem ?
>=20
> http://patchwork.ozlabs.org/patch/132698/
>=20

Oh, sorry, I don't know about that, congratulation :)

Regards,
Michael Wang

>=20
>=20
