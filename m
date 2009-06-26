From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: weird problem
Date: Fri, 26 Jun 2009 19:45:57 +0200
Message-ID: <4A450955.1010806@itcare.pl>
References: <4A43DB99.70602@gmail.com> <20090626083719.GA6445@ff.dom.local> <20090626090545.GB6445@ff.dom.local> <4A44A098.8080006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:39084 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbZFZRp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 13:45:58 -0400
In-Reply-To: <4A44A098.8080006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet pisze:
> Jarek Poplawski a =C3=A9crit :
>  =20
>> On Fri, Jun 26, 2009 at 08:37:19AM +0000, Jarek Poplawski wrote:
>>    =20
>>> On 25-06-2009 22:18, Eric Dumazet wrote:
>>>      =20
>>>> Pawe? Staszewski a ?crit :
>>>>        =20
>>>>> Ok
>>>>>
>>>>> After this day of observation im near 100% sure that this cpu loa=
d is
>>>>> made by route cahce flushes
>>>>> When route cache increase to its "net.ipv4.route.gc_thresh" size =
or is
>>>>> near that size
>>>>> system is starting to drop some routes from cache then cpu load i=
s
>>>>> increase from 2% to near 80%
>>>>> after cleaning / flush cache when cache is filling cpu load is ag=
ain
>>>>> normal 2%
>>>>>
>>>>> Someone know how to resolve this ?
>>>>> on kernels < 2.6.29 i don't see this, all start after upgrade fro=
m
>>>>> 2.6.28 to 2.6.29 - then i try 2.6.29.1 , 2.6.29.3 and 2.6.30 and =
on all
>>>>> this kernels >=3D 2.6.29 problem with cpu load is the same.
>>>>>
>>>>> I can minimize this cpu fluctuations by changing of route cache /=
proc
>>>>> parameters but the best result for my router was
>>>>>
>>>>> 15 sec of 2% cpu
>>>>> and after
>>>>> 15sec of 80% cpu
>>>>>
>>>>>
>>>>> Regards
>>>>> Pawel Staszewski
>>>>>          =20
>>>> I believe this is known 2.6.29 regressions
>>>>
>>>> Following two commits should correct the problem you have
>>>>
>>>> Your best bet would be to try 2.6.31-rc1, and tell us if this rece=
nt kernel
>>>> is ok on your machine ?
>>>>        =20
>>> Btw., the first of these commits is in 2.6.30, which according to
>>>      =20
>> And the second as well.
>>
>>    =20
>
> Thanks Jarek.
>
> Pawel made some reports errors in fib thread, so I am not sure he rea=
lly
>  tried 2.6.30 and had same oprofile results.
>
> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...
>
> Pawel, could you give us :
>
> grep . /proc/sys/net/ipv4/route/*
> cat /proc/interrupts
>
> on your various kernels (previous to 2.6.29, 2.6.29, 2.6.30, ...)
>
> I suspect a change in hash table size, and/or change in interrupt aff=
inities...
>
>
>  =20
first machine:
Linux TM_01_C1 2.6.29.5 #1 SMP Fri Jun 26 19:11:30 UTC 2009 x86_64=20
Intel(R) Xeon(R) CPU X5450 @ 3.00GHz GenuineIntel GNU/Linux

grep . /proc/sys/net/ipv4/route/*
/proc/sys/net/ipv4/route/error_burst:1250
/proc/sys/net/ipv4/route/error_cost:250
/proc/sys/net/ipv4/route/gc_elasticity:4
/proc/sys/net/ipv4/route/gc_interval:1
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:0
/proc/sys/net/ipv4/route/gc_thresh:190536
/proc/sys/net/ipv4/route/gc_timeout:15
/proc/sys/net/ipv4/route/max_size:524288
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:5
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:5120
/proc/sys/net/ipv4/route/secret_interval:3600

dmesg | grep route
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)


cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3       CPU4      =20
CPU5       CPU6       CPU7
  0:         43          0          0          1          1         =20
2          0          0   IO-APIC-edge      timer
  1:          0          0          0          1          0         =20
0          0          1   IO-APIC-edge      i8042
  9:          0          0          0          0          0         =20
0          0          0   IO-APIC-fasteoi   acpi
 14:          0          0          0          0          0         =20
0          0          0   IO-APIC-edge      ide0
 15:          0          0          0          0          0         =20
0          0          0   IO-APIC-edge      ide1
 29:    1139988   18351004      89662          3          0         =20
1          0          3   PCI-MSI-edge      eth0
 30:          0          2   20221692          1          0         =20
3          0          0   PCI-MSI-edge      eth1
 31:          0          1          1          0          0         =20
0          0          0   PCI-MSI-edge
 32:          0          0          0          0          0         =20
0          2          0   PCI-MSI-edge
 33:          1          1          0          0          0         =20
0          0          0   PCI-MSI-edge
 34:          0          0          0          1          0         =20
1          0          0   PCI-MSI-edge
 35:          0          0          0          1          0         =20
0          0          1   PCI-MSI-edge
 36:          0          0          0          0          1         =20
0          0          1   PCI-MSI-edge
 37:          1          0          0          0          0         =20
1          0          0   PCI-MSI-edge
 38:          0          0          1          0          1         =20
0          0          0   PCI-MSI-edge
 39:          0          0          2          0          0         =20
0          0          0   PCI-MSI-edge
 40:          0          0          0          0          0         =20
0          2          0   PCI-MSI-edge
 41:          0          2          0          0          0         =20
0          0          0   PCI-MSI-edge
 42:          0          0          0          0          0         =20
2          0          0   PCI-MSI-edge
 43:          0          0          0          2          0         =20
0          0          0   PCI-MSI-edge
 44:          0          0          0          0          0         =20
0          0          2   PCI-MSI-edge
 45:          2          0          0          0          0         =20
0          0          0   PCI-MSI-edge
 46:          0          0          0          0          2         =20
0          0          0   PCI-MSI-edge
 48:        233        200        185        257        256       =20
260        269        257   PCI-MSI-edge      ahci
 49:          0          1          1          0          0         =20
2          1          0   PCI-MSI-edge      ioat-msi
NMI:          0          0          0          0          0         =20
0          0          0   Non-maskable interrupts
LOC:    1191321   26059516   25803111      64841      32718     =20
26651      54058      24166   Local timer interrupts
RES:        921         59         58         20         14         =20
8         10         13   Rescheduling interrupts
CAL:         20         85         88         87         90        =20
90         91         86   Function call interrupts
TLB:        103        116        937        954         95       =20
115       1006       1020   TLB shootdowns
SPU:          0          0          0          0          0         =20
0          0          0   Spurious interrupts
ERR:          0
MIS:          0


second machine:
Linux TM_02_C1 2.6.30 #1 SMP Thu Jun 25 21:49:58 CEST 2009 i686 Intel(R=
)=20
Xeon(R) CPU 3075 @ 2.66GHz GenuineIntel GNU/Linux

cat /proc/interrupts
           CPU0       CPU1
  0:        182        129   IO-APIC-edge      timer
  1:       1886       1672   IO-APIC-edge      i8042
  6:          1          1   IO-APIC-edge      floppy
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          2          2   IO-APIC-edge      i8042
 14:          0          0   IO-APIC-edge      ide0
 15:          0          0   IO-APIC-edge      ide1
 27:      41793      26401   PCI-MSI-edge      ahci
 28:      13482      11260   PCI-MSI-edge      eth2
 29:          3 1326457765   PCI-MSI-edge      eth1
 30: 1240943198  137973134   PCI-MSI-edge      eth0
NMI:          0          0   Non-maskable interrupts
LOC: 1607938599 1514565603   Local timer interrupts
SPU:          0          0   Spurious interrupts
RES:       1098       1190   Rescheduling interrupts
CAL:         28        105   Function call interrupts
TLB:       2886       3055   TLB shootdowns
ERR:          0
MIS:          0

grep . /proc/sys/net/ipv4/route/*
/proc/sys/net/ipv4/route/error_burst:1250
/proc/sys/net/ipv4/route/error_cost:250
/proc/sys/net/ipv4/route/gc_elasticity:4
/proc/sys/net/ipv4/route/gc_interval:1
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:0
/proc/sys/net/ipv4/route/gc_thresh:190536
/proc/sys/net/ipv4/route/gc_timeout:15
/proc/sys/net/ipv4/route/max_size:1524288
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:5
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:5120
/proc/sys/net/ipv4/route/secret_interval:3600


dmesg | grep route
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)

rtstat -k entries -i 1 -c 10
rt_cache|
 entries|
  112754|
  112446|
  112277|
  111451|
  111042|
  110314|
  109153|
  108370|
  107730|
  107478|




> Change in hash table size comes from commit c9503e0fe052020e0294cd07d=
0ecd982eb7c9177
>
> But as Pawel mentioned "net.ipv4.route.gc_thresh =3D 190536", I belie=
ve
> his hash table is smaller than 512k entries!
>
> Author: Anton Blanchard <anton@samba.org>
> Date:   Mon Apr 27 05:42:24 2009 -0700
>
>     ipv4: Limit size of route cache hash table
>
>     Right now we have no upper limit on the size of the route cache h=
ash table.
>     On a 128GB POWER6 box it ends up as 32MB:
>
>         IP route cache hash table entries: 4194304 (order: 9, 3355443=
2 bytes)
>
>     It would be nice to cap this for memory consumption reasons, but =
a massive
>     hashtable also causes a significant spike when measuring OS jitte=
r.
>
>     With a 32MB hashtable and 4 million entries, rt_worker_func is ta=
king
>     5 ms to complete. On another system with more memory it's taking =
14 ms.
>     Even though rt_worker_func does call cond_sched() to limit its im=
pact,
>     in an HPC environment we want to keep all sources of OS jitter to=
 a minimum.
>
>     With the patch applied we limit the number of entries to 512k whi=
ch
>     can still be overriden by using the rt_entries boot option:
>
>         IP route cache hash table entries: 524288 (order: 6, 4194304 =
bytes)
>
>     With this patch rt_worker_func now takes 0.460 ms on the same sys=
tem.
>
>     Signed-off-by: Anton Blanchard <anton@samba.org>
>     Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20

