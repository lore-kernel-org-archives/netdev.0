From: P@draigBrady.com
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 02 Jul 2003 15:23:30 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F02EAE2.8050609@draigBrady.com>
References: <Pine.LNX.4.44.0307020826530.23232-100000@netcore.fi> <200307021426.56138.nf@hipac.org> <3F02D964.7050301@draigBrady.com> <200307021548.19989.nf@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nf@hipac.org
In-Reply-To: <200307021548.19989.nf@hipac.org>
List-Id: netdev.vger.kernel.org

Michael Bellion and Thomas Heinz wrote:
> Hi P=E1draig
>=20
>=20
>>>Since real world network traffic always consists of a lot of differe=
nt
>>>sized packets taking maximum sized packets is very euphemistic. 1450=
 byte
>>>packets at 950 Mbit/s correspond to approx. 80,000 packets/sec.
>>>We are really interested in how our algorithm performs at higher pac=
ket
>>>rates. Our performance tests are based on 100 Mbit hardware so we co=
udn't
>>>test with more than approx. 80,000 packets/sec even with minimum siz=
ed
>>>packets.
>>
>>Interrupt latency is the problem here. You'll require napi et. al
>>to get over this hump.
>
> Yes we know, but with 128 byte frame size you can archieve a packet r=
ate of at=20
> most 97,656 packets/sec (in theory) on 100 Mbit hardware. We don't th=
ink this=20
> few more packets would have changed the results fundamentally, so it'=
s=20
> probably not worth it on 100 Mbit.

I was testing with 64 byte packets (so around 190Kpps). e100 cards at=20
least have a handy mode for continually sending a packet as fast as=20
possible. Also you can use more than one interface. So 100Mb
is very useful for testing. For the test below I was using
a rate of around 85Kpps.

> Certainly you are right, that napi is required on gigabit to saturate=
 the link=20
> with small sized packets.=20
>
>>Cool. The same sort of test with ordinary netfilter that
>>I did showed it could only handle around 125 rules at this
>>packet rate on a 1.4GHz PIII, e1000 @ 100Mb/s.
>>
>># ./readprofile -m /boot/System.map | sort -nr | head -30
>>   6779 total                                      0.0047
>>   4441 default_idle                              69.3906
>>    787 handle_IRQ_event                           7.0268
>>    589 ip_packet_match                            1.6733
>>    433 ipt_do_table                               0.6294
>>    106 eth_type_trans                             0.5521
>>    [...]
>=20
> What do you want to show with this profile? Most of the time is spend=
 in the=20
> idle loop and in irq handling and only a few percentage in ip_packet_=
match=20
> and ipt_do_table, so we don't quite get how this matches your stateme=
nt=20
> above. Could you explain this in a few words?

Confused me too. The system would lock up and start dropping
packets after 125 rules. I.E. it would linearly degrade
as more rules were added. I'm guessing there is a fixed
interrupt overhead that is accounted for
by default_idle? Note the e1000 drivers were
left in the default config so there could definitely
be some tuning done here.

Note I changed netfilter slightly to accept promiscuous traffic
which is done in ip_rcv() and then the packets are just dropped
after the (match any in the test case) rules are traversed.

P=E1draig.
