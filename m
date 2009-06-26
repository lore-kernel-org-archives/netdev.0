From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: weird problem
Date: Fri, 26 Jun 2009 19:57:39 +0200
Message-ID: <4A450C13.9050907@itcare.pl>
References: <4A43DB99.70602@gmail.com> <20090626083719.GA6445@ff.dom.local> <20090626090545.GB6445@ff.dom.local> <4A44A098.8080006@cosmosbay.com> <4A450955.1010806@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:58641 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbZFZR5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 13:57:40 -0400
In-Reply-To: <4A450955.1010806@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=C5=82 Staszewski pisze:
> Eric Dumazet pisze:
>> Jarek Poplawski a =C3=A9crit :
>> =20
>>> On Fri, Jun 26, 2009 at 08:37:19AM +0000, Jarek Poplawski wrote:
>>>   =20
>>>> On 25-06-2009 22:18, Eric Dumazet wrote:
>>>>     =20
>>>>> Pawe? Staszewski a ?crit :
>>>>>       =20
>>>>>> Ok
>>>>>>
>>>>>> After this day of observation im near 100% sure that this cpu=20
>>>>>> load is
>>>>>> made by route cahce flushes
>>>>>> When route cache increase to its "net.ipv4.route.gc_thresh" size=
=20
>>>>>> or is
>>>>>> near that size
>>>>>> system is starting to drop some routes from cache then cpu load =
is
>>>>>> increase from 2% to near 80%
>>>>>> after cleaning / flush cache when cache is filling cpu load is a=
gain
>>>>>> normal 2%
>>>>>>
>>>>>> Someone know how to resolve this ?
>>>>>> on kernels < 2.6.29 i don't see this, all start after upgrade fr=
om
>>>>>> 2.6.28 to 2.6.29 - then i try 2.6.29.1 , 2.6.29.3 and 2.6.30 and=
=20
>>>>>> on all
>>>>>> this kernels >=3D 2.6.29 problem with cpu load is the same.
>>>>>>
>>>>>> I can minimize this cpu fluctuations by changing of route cache=20
>>>>>> /proc
>>>>>> parameters but the best result for my router was
>>>>>>
>>>>>> 15 sec of 2% cpu
>>>>>> and after
>>>>>> 15sec of 80% cpu
>>>>>>
>>>>>>
>>>>>> Regards
>>>>>> Pawel Staszewski
>>>>>>          =20
>>>>> I believe this is known 2.6.29 regressions
>>>>>
>>>>> Following two commits should correct the problem you have
>>>>>
>>>>> Your best bet would be to try 2.6.31-rc1, and tell us if this=20
>>>>> recent kernel
>>>>> is ok on your machine ?
>>>>>        =20
>>>> Btw., the first of these commits is in 2.6.30, which according to
>>>>      =20
>>> And the second as well.
>>>
>>>    =20
>>
>> Thanks Jarek.
>>
>> Pawel made some reports errors in fib thread, so I am not sure he re=
ally
>>  tried 2.6.30 and had same oprofile results.
>>
>> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
>> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...
>>
oprofile from:
Linux TM_01_C1 2.6.29.5 #1 SMP Fri Jun 26 19:11:30 UTC 2009 x86_64=20
Intel(R) Xeon(R) CPU X5450 @ 3.00GHz GenuineIntel GNU/Linux

CPU: Core 2, speed 3000.21 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a=20
unit mask of 0x00 (Unhalted core cycles) count 100000
Samples on CPU 0
Samples on CPU 1
Samples on CPU 2
Samples on CPU 3
Samples on CPU 4
Samples on CPU 5
Samples on CPU 6
Samples on CPU 7
samples  %        samples  %        samples  %        samples  %       =
=20
samples  %        samples  %        samples  %        samples  %       =
=20
image name
           app name                 symbol name
9999     19.0926  0              0  0              0  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  rt_worker_func
9017     17.2175  219       0.0277  13        0.0017  29        0.0814 =
=20
26        0.3410  12        0.1420  13        0.1718  115       1.7649 =
=20
vmlinux
           vmlinux                  free_block
8867     16.9311  13588     1.7177  11888     1.5423  9000     25.2731 =
=20
801      10.5063  461       5.4550  788      10.4136  476       7.3051 =
=20
vmlinux
           vmlinux                  mwait_idle
5714     10.9106  197       0.0249  143       0.0186  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  dst_destroy
2917      5.5699  95        0.0120  76        0.0099  33        0.0927 =
=20
3         0.0393  0              0  2         0.0264  0              0 =
=20
vmlinux
           vmlinux                  __call_rcu
2293      4.3784  74        0.0094  49        0.0064  48        0.1348 =
=20
24        0.3148  12        0.1420  22        0.2907  12        0.1842 =
=20
vmlinux
           vmlinux                  __rcu_process_callbacks
1816      3.4676  24921     3.1504  22351     2.8997  1090      3.0609 =
=20
443       5.8106  297       3.5144  414       5.4711  382       5.8625 =
=20
vmlinux
           vmlinux                  _raw_spin_lock
1055      2.0145  24        0.0030  21        0.0027  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  dst_rcu_free
669       1.2774  752       0.0951  717       0.0930  3223      9.0506 =
=20
679       8.9061  1527     18.0689  232       3.0659  517       7.9343 =
=20
libc-2.8.so
           libc-2.8.so              (no symbols)
590       1.1266  1745      0.2206  1208      0.1567  83        0.2331 =
=20
4         0.0525  5         0.0592  6         0.0793  4         0.0614 =
=20
vmlinux
           vmlinux                  kmem_cache_free
568       1.0846  36        0.0046  29        0.0038  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  ipv4_dst_destroy
534       1.0196  583       0.0737  641       0.0832  691       1.9404 =
=20
1402     18.3893  542       6.4134  934      12.3431  736      11.2953 =
=20
vmlinux
           vmlinux                  tg_shares_up
457       0.8726  20        0.0025  19        0.0025  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  call_rcu_bh
422       0.8058  0              0  429       0.0557  0              0 =
=20
0              0  845       9.9988  0              0  0              0 =
 bgpd
           bgpd                     bgp_best_selection
397       0.7581  0              0  585       0.0759  0              0 =
=20
153       2.0068  917      10.8508  0              0  0              0 =
 bgpd
           bgpd                     bgp_route_next
339       0.6473  3085      0.3900  3301      0.4283  169       0.4746 =
=20
20        0.2623  19        0.2248  36        0.4757  31        0.4758 =
=20
vmlinux
           vmlinux                  _raw_spin_unlock
319       0.6091  3645      0.4608  3122      0.4050  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  local_bh_enable_ip
290       0.5537  0              0  40        0.0052  0              0 =
=20
0              0  0              0  0              0  0              0 =
=20
vmlinux
           vmlinux                  e1000e_update_stats
271       0.5175  152       0.0192  146       0.0189  371       1.0418 =
=20
626       8.2109  192       2.2719  334       4.4139  165       2.5322 =
=20
vmlinux
           vmlinux                  find_next_bit
228       0.4354  19        0.0024  7        9.1e-04  5         0.0140 =
=20
15        0.1967  12        0.1420  10        0.1322  20        0.3069 =
=20
vmlinux
           vmlinux                  rcu_process_callbacks
217       0.4144  0              0  352       0.0457  0              0 =
=20
84        1.1018  534       6.3188  0              0  0              0 =
 bgpd
           bgpd                     bgp_scan_timer
203       0.3876  694       0.0877  521       0.0676  6         0.0168 =
=20
2         0.0262  0              0  2         0.0264  0              0 =
=20
vmlinux
           vmlinux                  __phys_addr
191       0.3647  182       0.0230  66        0.0086  208       0.5841 =
=20
608       7.9748  259       3.0647  268       3.5417  134       2.0565 =
=20
vmlinux
           vmlinux                  find_busiest_group
186       0.3552  5221      0.6600  4432      0.5750  116       0.3257 =
=20
131       1.7183  90        1.0650  122       1.6123  106       1.6268 =
=20
vmlinux

>> Pawel, could you give us :
>>
>> grep . /proc/sys/net/ipv4/route/*
>> cat /proc/interrupts
>>
>> on your various kernels (previous to 2.6.29, 2.6.29, 2.6.30, ...)
>>
>> I suspect a change in hash table size, and/or change in interrupt=20
>> affinities...
>>
>>
>>  =20
> first machine:
> Linux TM_01_C1 2.6.29.5 #1 SMP Fri Jun 26 19:11:30 UTC 2009 x86_64=20
> Intel(R) Xeon(R) CPU X5450 @ 3.00GHz GenuineIntel GNU/Linux
>
> grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:1
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:0
> /proc/sys/net/ipv4/route/gc_thresh:190536
> /proc/sys/net/ipv4/route/gc_timeout:15
> /proc/sys/net/ipv4/route/max_size:524288
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:3600
>
> dmesg | grep route
> IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
>
>
> cat /proc/interrupts
>           CPU0       CPU1       CPU2       CPU3       CPU4      =20
> CPU5       CPU6       CPU7
>  0:         43          0          0          1          1         =20
> 2          0          0   IO-APIC-edge      timer
>  1:          0          0          0          1          0         =20
> 0          0          1   IO-APIC-edge      i8042
>  9:          0          0          0          0          0         =20
> 0          0          0   IO-APIC-fasteoi   acpi
> 14:          0          0          0          0          0         =20
> 0          0          0   IO-APIC-edge      ide0
> 15:          0          0          0          0          0         =20
> 0          0          0   IO-APIC-edge      ide1
> 29:    1139988   18351004      89662          3          0         =20
> 1          0          3   PCI-MSI-edge      eth0
> 30:          0          2   20221692          1          0         =20
> 3          0          0   PCI-MSI-edge      eth1
> 31:          0          1          1          0          0         =20
> 0          0          0   PCI-MSI-edge
> 32:          0          0          0          0          0         =20
> 0          2          0   PCI-MSI-edge
> 33:          1          1          0          0          0         =20
> 0          0          0   PCI-MSI-edge
> 34:          0          0          0          1          0         =20
> 1          0          0   PCI-MSI-edge
> 35:          0          0          0          1          0         =20
> 0          0          1   PCI-MSI-edge
> 36:          0          0          0          0          1         =20
> 0          0          1   PCI-MSI-edge
> 37:          1          0          0          0          0         =20
> 1          0          0   PCI-MSI-edge
> 38:          0          0          1          0          1         =20
> 0          0          0   PCI-MSI-edge
> 39:          0          0          2          0          0         =20
> 0          0          0   PCI-MSI-edge
> 40:          0          0          0          0          0         =20
> 0          2          0   PCI-MSI-edge
> 41:          0          2          0          0          0         =20
> 0          0          0   PCI-MSI-edge
> 42:          0          0          0          0          0         =20
> 2          0          0   PCI-MSI-edge
> 43:          0          0          0          2          0         =20
> 0          0          0   PCI-MSI-edge
> 44:          0          0          0          0          0         =20
> 0          0          2   PCI-MSI-edge
> 45:          2          0          0          0          0         =20
> 0          0          0   PCI-MSI-edge
> 46:          0          0          0          0          2         =20
> 0          0          0   PCI-MSI-edge
> 48:        233        200        185        257        256       =20
> 260        269        257   PCI-MSI-edge      ahci
> 49:          0          1          1          0          0         =20
> 2          1          0   PCI-MSI-edge      ioat-msi
> NMI:          0          0          0          0          0         =20
> 0          0          0   Non-maskable interrupts
> LOC:    1191321   26059516   25803111      64841      32718     =20
> 26651      54058      24166   Local timer interrupts
> RES:        921         59         58         20         14         =20
> 8         10         13   Rescheduling interrupts
> CAL:         20         85         88         87         90        =20
> 90         91         86   Function call interrupts
> TLB:        103        116        937        954         95       =20
> 115       1006       1020   TLB shootdowns
> SPU:          0          0          0          0          0         =20
> 0          0          0   Spurious interrupts
> ERR:          0
> MIS:          0
>
>
> second machine:
> Linux TM_02_C1 2.6.30 #1 SMP Thu Jun 25 21:49:58 CEST 2009 i686=20
> Intel(R) Xeon(R) CPU 3075 @ 2.66GHz GenuineIntel GNU/Linux
>
> cat /proc/interrupts
>           CPU0       CPU1
>  0:        182        129   IO-APIC-edge      timer
>  1:       1886       1672   IO-APIC-edge      i8042
>  6:          1          1   IO-APIC-edge      floppy
>  9:          0          0   IO-APIC-fasteoi   acpi
> 12:          2          2   IO-APIC-edge      i8042
> 14:          0          0   IO-APIC-edge      ide0
> 15:          0          0   IO-APIC-edge      ide1
> 27:      41793      26401   PCI-MSI-edge      ahci
> 28:      13482      11260   PCI-MSI-edge      eth2
> 29:          3 1326457765   PCI-MSI-edge      eth1
> 30: 1240943198  137973134   PCI-MSI-edge      eth0
> NMI:          0          0   Non-maskable interrupts
> LOC: 1607938599 1514565603   Local timer interrupts
> SPU:          0          0   Spurious interrupts
> RES:       1098       1190   Rescheduling interrupts
> CAL:         28        105   Function call interrupts
> TLB:       2886       3055   TLB shootdowns
> ERR:          0
> MIS:          0
>
> grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:1
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:0
> /proc/sys/net/ipv4/route/gc_thresh:190536
> /proc/sys/net/ipv4/route/gc_timeout:15
> /proc/sys/net/ipv4/route/max_size:1524288
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:3600
>
>
> dmesg | grep route
> IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
>
> rtstat -k entries -i 1 -c 10
> rt_cache|
> entries|
>  112754|
>  112446|
>  112277|
>  111451|
>  111042|
>  110314|
>  109153|
>  108370|
>  107730|
>  107478|
>
>
>
>
>> Change in hash table size comes from commit=20
>> c9503e0fe052020e0294cd07d0ecd982eb7c9177
>>
>> But as Pawel mentioned "net.ipv4.route.gc_thresh =3D 190536", I beli=
eve
>> his hash table is smaller than 512k entries!
>>
>> Author: Anton Blanchard <anton@samba.org>
>> Date:   Mon Apr 27 05:42:24 2009 -0700
>>
>>     ipv4: Limit size of route cache hash table
>>
>>     Right now we have no upper limit on the size of the route cache=20
>> hash table.
>>     On a 128GB POWER6 box it ends up as 32MB:
>>
>>         IP route cache hash table entries: 4194304 (order: 9,=20
>> 33554432 bytes)
>>
>>     It would be nice to cap this for memory consumption reasons, but=
=20
>> a massive
>>     hashtable also causes a significant spike when measuring OS jitt=
er.
>>
>>     With a 32MB hashtable and 4 million entries, rt_worker_func is=20
>> taking
>>     5 ms to complete. On another system with more memory it's taking=
=20
>> 14 ms.
>>     Even though rt_worker_func does call cond_sched() to limit its=20
>> impact,
>>     in an HPC environment we want to keep all sources of OS jitter t=
o=20
>> a minimum.
>>
>>     With the patch applied we limit the number of entries to 512k wh=
ich
>>     can still be overriden by using the rt_entries boot option:
>>
>>         IP route cache hash table entries: 524288 (order: 6, 4194304=
=20
>> bytes)
>>
>>     With this patch rt_worker_func now takes 0.460 ms on the same=20
>> system.
>>
>>     Signed-off-by: Anton Blanchard <anton@samba.org>
>>     Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>  =20
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

