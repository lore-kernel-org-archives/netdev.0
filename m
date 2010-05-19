From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: fix problem in dequeuing from input_pkt_queue
Date: Wed, 19 May 2010 16:58:31 -0700
Message-ID: <AANLkTilxZdJifPtBANrDNdYWxiAMLY6AwA0KYm1yWjle@mail.gmail.com>
References: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
	 <AANLkTinvSgc3MTAJZEmhBqmRpYlHdOZ6HQ_j43_m8XX1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:24757 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab0ESX6f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 19:58:35 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o4JNwW08018842
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 16:58:33 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by kpbe17.cbf.corp.google.com with ESMTP id o4JNwV7N008662
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 16:58:31 -0700
Received: by pwi6 with SMTP id 6so340729pwi.29
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 16:58:31 -0700 (PDT)
In-Reply-To: <AANLkTinvSgc3MTAJZEmhBqmRpYlHdOZ6HQ_j43_m8XX1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> =C2=A0 =C2=A0 =C2=A0 =C2=A0napi->weight =3D weight_p;
>> - =C2=A0 =C2=A0 =C2=A0 local_irq_disable();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (work < quota) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buf=
f *skb;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int =
qlen;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0while ((skb =3D=
 __skb_dequeue(&sd->process_queue))) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 local_irq_enable();
>
> we need to keep local irq disabled. If not, flush_backlog may be
> called, and it will access sd->process_queue.
>

It should be okay?  process_backlog only runs in softirq so bottom
halves are already disabled, and I don't think flush_backlog runs out
of an interrupt.

>
> --
> Regards=EF=BC=8C
> Changli Gao(xiaosuo@gmail.com)
>
