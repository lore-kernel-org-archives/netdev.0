From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 16:26:02 +0200
Message-ID: <4EA02F7A.8000705@gmail.com>
References: <4E9D5E1B.3080704@gmail.com>    <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>    <1318946401.23980.6.camel@deadeye>   <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <4E9E9963.7090209@gmail.com> <1319019235.3103.10.camel@edumazet-laptop>  <4EA020B3.4030208@gmail.com> <1319118253.7735.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55474 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab1JTO0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:26:06 -0400
Received: by bkbzt19 with SMTP id zt19so3610240bkb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 07:26:05 -0700 (PDT)
In-Reply-To: <1319118253.7735.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2011 03:44 PM, Eric Dumazet wrote:
> Le jeudi 20 octobre 2011 =C3=A0 15:22 +0200, Daniel Turull a =C3=A9cr=
it :
>> Hi,
>>
>> I tested the patch and it works well.
>>
>=20
> Thanks !
>=20
>=20
>>
>> I think if we increase the constant to 1ms, we will reduce the jitte=
r if we have
>> a rate between 1kpps and 10 kpps, but I guess is not a big deal.
>>
>=20
>=20
>> I've plot this new graph with this patch:
>> http://tslab.ssvl.kth.se/pktgen/img/inter_eric1.eps
>=20
> Unfortunately, the sender cpu might be preempted by timer irq or othe=
r
> expensive irq, so the Min/Max values are not very different I guess.
>=20
> I dont understand your Min values.
>=20
> At 100 pps, how is it possible to have a Min value of ~5000 ns ?
>=20
>=20
My assumption is that for low rate, the min value is caused in the=20
beginning of the test. When we start the transmission in pktgen_run(),
we set the pkt_dev->next_tx to the current time but the are
more operation to do, so the first transmission is a bit delayed.=20
Even more if the cpu is preempted.
=46or the second packet, we are taking the pkt_dev->next_tx as a refere=
nce
and add the delay, in order to decide when to send.
So, my guess is that the first packet is delayed
and then we send the second packet only after a short time, in order
to keep the average rate in the transmission.

Daniel
