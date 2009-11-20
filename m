From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Fri, 20 Nov 2009 09:08:10 -0800
Message-ID: <65634d660911200908l5acbf3d0v5fc9a2e1adb7c3a5@mail.gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	 <20091119095730.GA7661@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:12613 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbZKTRIJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:08:09 -0500
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id nAKH8EpI018427
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 17:08:14 GMT
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by spaceape13.eur.corp.google.com with ESMTP id nAKH6fHM019970
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 09:08:10 -0800
Received: by pwj6 with SMTP id 6so2306894pwj.35
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 09:08:10 -0800 (PST)
In-Reply-To: <20091119095730.GA7661@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The description reads: "This solution queues packets early on in the
> receive path on the backlog queues of other CPUs.", so I'm not sure
> it's intended.

That is precisely the intent.  Getting packets quickly distributed to
the target cpus maximizes parallelism and reduces latency.

Did you test it like this (and it was visibly worse)?:
>
> =A0 =A0 =A0 =A0if (cpu < 0 || cpu =3D=3D smp_processor_id())
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 return __netif_receive_skb(skb);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 return enqueue_to_backlog(skb, cpu);
>> +}
>> +
This increases overall latency due to head of line blocking which will
outweigh the benefits of optimizing for this one case.

Tom
