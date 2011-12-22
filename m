From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 14:21:08 +0100
Message-ID: <1324560068.2153.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
	 <4EF30744.6000509@linux.vnet.ibm.com>
	 <1324550811.2153.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF32A21.3060503@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49237 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab1LVNVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 08:21:11 -0500
Received: by werm1 with SMTP id m1so3330309wer.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 05:21:10 -0800 (PST)
In-Reply-To: <4EF32A21.3060503@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 21:01 +0800, Michael Wang a =C3=A9=
crit :

> Hi, Eric
>=20
> So do you mean the way is:
>=20
> ip_local_deliver_finish --> raw_local_deliver --> raw_v4_input -->
> raw_rcv --> raw_rcv_skb --> sock_queue_rcv_skb
>=20
> And in sock_queue_rcv_skb:
>=20
>         if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
>             (unsigned)sk->sk_rcvbuf) {
>                 atomic_inc(&sk->sk_drops);
>                 trace_sock_rcvqueue_full(sk, skb);
>                 return -ENOMEM;				//drop?
>         }
>=20
> Is this the way the packet being dropped? Is this confirmed by some p=
rintk?
>=20
> Sorry if the question is naive, I just want to make sure I am checkin=
g
> at the right place.
>=20

Yep

Are you aware I already posted a patch to solve the problem ?

http://patchwork.ozlabs.org/patch/132698/
