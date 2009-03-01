From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Sun, 01 Mar 2009 18:03:12 +0100
Message-ID: <49AABFD0.5090204@cosmosbay.com>
References: <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com> <4987663D.6080802@cosmosbay.com> <4988803E.2020009@athenacr.com> <20090204012144.GC3650@localhost.localdomain> <49A6CE39.5050200@athenacr.com> <49A8FAFF.7060104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Lameter <cl@linux-foundation.org>
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39404 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755988AbZCARDw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 12:03:52 -0500
In-Reply-To: <49A8FAFF.7060104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Kenny Chang a =E9crit :
>> It's been a while since I updated this thread.  We've been running
>> through the different suggestions and tabulating their effects, as w=
ell
>> as trying out an Intel card.  The short story is that setting affini=
ty
>> and MSI works to some extent, and the Intel card doesn't seem to cha=
nge
>> things significantly.  The results don't seem consistent enough for =
us
>> to be able to point to a smoking gun.
>>
>> It does look like the 2.6.29-rc4 kernel performs okay with the Intel
>> card, but this is not a real-time build and it's not likely to be in=
 a
>> supported Ubuntu distribution real soon.  We've reached the point wh=
ere
>> we'd like to look for an expert dedicated to work on this problem fo=
r a
>> period of time.  The final result being some sort of solution to pro=
duce
>> a realtime configuration with a reasonably "aged" kernel (.24~.28) t=
hat
>> has multicast performance greater than or equal to that of 2.6.15.
>>
>> If anybody is interested in devoting some compensated time to this
>> issue, we're offering up a bounty:
>> http://www.athenacr.com/bounties/multicast-performance/
>>
>> For completeness, here's the table of our experiment results:
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=
=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> Kernel                 flavor             IRQ       affinity   *4x
>> mcasttest*  *5x mcasttest* *6x mcasttest*  *Mtools2* [4]_
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=
=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> Intel
>> e1000e                                                              =
                                                  =20
>>
>> -----------------------------------------+---------+----------+-----=
----------+--------------+--------------+-----------------
>>
>> 2.6.24.19              rt                |          any       |
>> OK              Maybe          X                           =20
>> 2.6.24.19              rt                |          CPU0      |
>> OK              OK             X                           =20
>> 2.6.24.19              generic           |          any       |
>> X                                                          =20
>> 2.6.24.19              generic           |          CPU0      |
>> OK                                                         =20
>> 2.6.29-rc3             vanilla-server    |          any       |
>> X                                                          =20
>> 2.6.29-rc3             vanilla-server    |          CPU0      |
>> OK                                                         =20
>> 2.6.29-rc4             vanilla-generic   |          any       |
>> X                                             OK           =20
>> 2.6.29-rc4             vanilla-generic   |          CPU0      | OK =20
>>           OK             OK [5]_        OK           =20
>> -----------------------------------------+---------+----------+-----=
----------+--------------+--------------+-----------------
>>
>> Broadcom
>> BNX2                                                                =
                                               =20
>>
>> -----------------------------------------+---------+----------+-----=
----------+--------------+--------------+-----------------
>>
>> 2.6.24-19              rt                | MSI      any       |
>> OK              OK             X                           =20
>> 2.6.24-19              rt                | MSI      CPU0      |
>> OK              Maybe          X                           =20
>> 2.6.24-19              rt                | APIC     any       |
>> OK              OK             X                           =20
>> 2.6.24-19              rt                | APIC     CPU0      |
>> OK              Maybe          X                           =20
>> 2.6.24-19-bnx-latest   rt                | APIC     CPU0      |
>> OK              X                                          =20
>> 2.6.24-19              server            | MSI      any       |
>> X                                                          =20
>> 2.6.24-19              server            | MSI      CPU0      |
>> OK                                                         =20
>> 2.6.24-19              generic           | APIC     any       |
>> X                                                          =20
>> 2.6.24-19              generic           | APIC     CPU0      |
>> OK                                                         =20
>> 2.6.27-11              generic           | APIC     any       |
>> X                                                          =20
>> 2.6.27-11              generic           | APIC     CPU0      |
>> OK              10% drop                                    =20
>> 2.6.28-8               generic           | APIC     any       |
>> OK              X                                           =20
>> 2.6.28-8               generic           | APIC     CPU0      |
>> OK              OK             0.5% drop                    =20
>> 2.6.29-rc3             vanilla-server    | MSI      any       |
>> X                                                          =20
>> 2.6.29-rc3             vanilla-server    | MSI      CPU0      |
>> X                                                          =20
>> 2.6.29-rc3             vanilla-server    | APIC     any       |
>> OK              X                                          =20
>> 2.6.29-rc3             vanilla-server    | APIC     CPU0      |
>> OK              OK                                         =20
>> 2.6.29-rc4             vanilla-generic   | APIC     any       |
>> X                                                          =20
>> 2.6.29-rc4             vanilla-generic   | APIC     CPU0      |
>> OK              3% drop        10% drop       X            =20
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=
=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>
>> * [4] MTools2 is a test from 29West: http://www.29west.com/docs/Test=
Net/
>> * [5] In 5 trials, 1 of the trials dropped 2%, 4 of the trials dropp=
ed
>> nothing.
>>
>> Kenny
>>
>=20
> Hi Kenny
>=20
> I am investigating how to reduce contention (and schedule() calls) on=
 this workload.
>=20

I bound NIC (gigabit BNX2) irq to cpu 0, so that oprofile results on th=
is cpu can show us
where ksoftirqd is spending its time.

We can see scheduler at work :)

Also, one thing to note is __copy_skb_header() : 9.49 % of cpu0 time.
The problem comes from dst_clone() (6.05 % total, so 2/3 of __copy_skb_=
header()),
touching a highly contended cache line. (other cpus are doing the decre=
ment of
dst refcounter)

CPU: Core 2, speed 3000.05 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted)=20
with a unit mask of 0x00 (Unhalted core cycles) count 100000
Samples on CPU 0
(samples for other cpus 1..7 omitted)
samples  cum. samples  %        cum. %     symbol name
23750    23750          9.8159   9.8159    try_to_wake_up
22972    46722          9.4944  19.3103    __copy_skb_header
20217    66939          8.3557  27.6660    enqueue_task_fair
14565    81504          6.0197  33.6857    sock_def_readable
13454    94958          5.5606  39.2463    task_rq_lock
13381    108339         5.5304  44.7767    resched_task
13090    121429         5.4101  50.1868    udp_queue_rcv_skb
11441    132870         4.7286  54.9154    skb_queue_tail
10109    142979         4.1781  59.0935    sock_queue_rcv_skb
10024    153003         4.1429  63.2364    __wake_up_sync
9952     162955         4.1132  67.3496    update_curr
8761     171716         3.6209  70.9705    sched_clock_cpu
7414     179130         3.0642  74.0347    rb_insert_color
7381     186511         3.0506  77.0853    select_task_rq_fair
6749     193260         2.7894  79.8747    __slab_alloc
5881     199141         2.4306  82.3053    __wake_up_common
5432     204573         2.2451  84.5504    __skb_clone
4306     208879         1.7797  86.3300    kmem_cache_alloc
3524     212403         1.4565  87.7865    place_entity
2783     215186         1.1502  88.9367    skb_clone
2576     217762         1.0647  90.0014    __udp4_lib_rcv
2430     220192         1.0043  91.0057    bnx2_poll_work
2184     222376         0.9027  91.9084    ipt_do_table
2090     224466         0.8638  92.7722    ip_route_input
1877     226343         0.7758  93.5479    __alloc_skb
1495     227838         0.6179  94.1658    native_sched_clock
1166     229004         0.4819  94.6477    __update_sched_clock
1083     230087         0.4476  95.0953    netif_receive_skb
1062     231149         0.4389  95.5343    activate_task
644      231793         0.2662  95.8004    __kmalloc_track_caller
638      232431         0.2637  96.0641    nf_iterate
549      232980         0.2269  96.2910    skb_put

