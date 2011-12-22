From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 21:01:21 +0800
Message-ID: <4EF32A21.3060503@linux.vnet.ibm.com>
References: <4EF1B0D9.2010007@monstr.eu> <4EF30744.6000509@linux.vnet.ibm.com> <1324550811.2153.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:48409 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197Ab1LVNBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 08:01:33 -0500
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Thu, 22 Dec 2011 12:58:59 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBMD1PA75075178
	for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 00:01:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBMD1OQI026814
	for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 00:01:25 +1100
In-Reply-To: <1324550811.2153.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2011 06:46 PM, Eric Dumazet wrote:

> Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 18:32 +0800, Michael Wang a =C3=
=A9crit :
>> On 12/21/2011 06:11 PM, Michal Simek wrote:
>>
>>> Hi Eric and David,
>>>
>>> I have found one problem with ll_temac driver and
>>> this commit: net: more accurate skb truesize
>>> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
>>>
>>> The problem is only with icmp packets from the target. It is sent a=
nd
>>> driver receive it
>>> but it is not proceed to the application.
>>>
>>
>> Hi, Michal
>>
>> What's the type of icmp you are using? such as "EchoReps", we can fi=
nd
>> the actually handler routine by this type.
>>
>> And you said the packet already received by driver, can you tell me =
the
>> way you used to confirm this?
>>
>> And have you checked when was the icmp packet being dropped, is it i=
n
>> icmp_rcv or before or later?
>=20
> Packet was dropped right before being queued in RAW socket
> receive_queue, because of low sk_rcvbuf setting (against skb->truesiz=
e)
>=20

Hi, Eric

So do you mean the way is:

ip_local_deliver_finish --> raw_local_deliver --> raw_v4_input -->
raw_rcv --> raw_rcv_skb --> sock_queue_rcv_skb

And in sock_queue_rcv_skb:

        if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
            (unsigned)sk->sk_rcvbuf) {
                atomic_inc(&sk->sk_drops);
                trace_sock_rcvqueue_full(sk, skb);
                return -ENOMEM;				//drop?
        }

Is this the way the packet being dropped? Is this confirmed by some pri=
ntk?

Sorry if the question is naive, I just want to make sure I am checking
at the right place.

Regards,
Michael Wang

>=20
>=20
