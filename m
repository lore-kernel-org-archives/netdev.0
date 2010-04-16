From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 22:58:12 +0800
Message-ID: <s2z412e6f7f1004160758l823ea0cah61a409972d4865fe@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	<n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	<1271395106.16881.3645.camel@edumazet-laptop> <1271424065.4606.31.camel@bigi>
	<k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
	<1271425753.4606.65.camel@bigi> <r2q412e6f7f1004160710j6d575f36t8e39a283328cf2d7@mail.gmail.com>
	<1271429025.4606.149.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:58785 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab0DPO6d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 10:58:33 -0400
Received: by pva18 with SMTP id 18so1720506pva.19
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 07:58:33 -0700 (PDT)
In-Reply-To: <1271429025.4606.149.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 10:43 PM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-04-16 at 22:10 +0800, Changli Gao wrote:
>> On Fri, Apr 16, 2010 at 9:49 PM, jamal <hadi@cyberus.ca> wrote:
>
>> > my observation is:
>> > s->total is the sum of all packets received by cpu (some directly =
from
>> > ethernet)
>>
>> It is meaningless currently. If rps is enabled, it may be twice of t=
he
>> number of the packets received, because one packet may be count twic=
e:
>> one in enqueue_to_backlog(), and the other in __netif_receive_skb().
>
> You are probably right - you made me look at my collected data ;->
> i will look closely later, but it seems they are accounting for
> different cpus, no?
> Example, attached are some of the stats i captured when i was running
> the tests redirecting from CPU0 to CPU1 1M packets at about 20Kpps (j=
ust
> cut to the first and last two columns):
>
> cpu =C2=A0 Total =C2=A0 =C2=A0 |rps_recv |rps_ipi
> -----+----------+---------+---------
> cpu0 | 002dc7f1 |00000000 |000f4246
> cpu1 | 002dc804 |000f4240 |00000000
> -------------------------------------
>
> So: cpu0 receive 0x2dc7f1 pkts accummulative over time and
> redirected to cpu1 (mostly, the extra 5 maybe to leftover since i cle=
ar
> the data) and for the test 0xf4246 times it generated an IPI. It can =
be
> seen that total running for CPU1 is 0x2dc804 but in this one run it
> received 1M packets (0xf4240).

I remeber you redirected all the traffic from cpu0 to cpu1, and the dat=
a shows:

about 0x2dc7f1 packets are processed, and about 0xf4240 IPI are generat=
ed.

> i.e i dont see the double accounting..
>

a single packet is counted twice by CPU0 and CPU1. If you change RPS se=
tting by:

echo 1 > ..../rps_cpus

you will find the total number are doubled.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
