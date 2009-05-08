From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 08 May 2009 12:15:01 +0200
Message-ID: <4A040625.5020609@itcare.pl>
References: <1240495002.6554.155.camel@blade.ines.ro> <20090423181936.GA2756@ami.dom.local> <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk> <1240566136.6554.220.camel@blade.ines.ro> <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk> <1241000494.6554.307.camel@blade.ines.ro> <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk> <1241003006.6554.322.camel@blade.ines.ro> <20090429122312.GA2759@ami.dom.local> <1241010951.6554.355.camel@blade.ines.ro> <20090429133810.GB2759@ami.dom.local> <1241022071.6554.375.camel@blade.ines.ro> <395864833.20090430014946@gemenii.ro> <1241090376.6554.404.camel@blade.ines.ro> <747455005.20090430170426@gemenii.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:60869 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbZEHKVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 06:21:44 -0400
Received: from unknown (HELO [192.168.1.11]) (itcare_pstaszewski@[83.7.211.25])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 8 May 2009 10:15:02 -0000
In-Reply-To: <747455005.20090430170426@gemenii.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radu You have something wrong with your configuration i think.

I make Traffic management for many different nets with space of /18=20
prefix outside net + 10.0.0.0/18 inside and some nets like /21 , /22 ,=20
/23, /20 network prefixes.

Some stats from my router:

tc -s -d filter show dev eth0 | grep dst | wc -l
14087
tc -s -d filter show dev eth1 | grep dst | wc -l
14087

cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Xeon(R) CPU            3075  @ 2.66GHz
stepping        : 11
cpu MHz         : 2659.843
cache size      : 4096 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
apicid          : 0
initial apicid  : 0
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge=20
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx l=
m=20
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx smx es=
t=20
tm2 ssse3 cx16 xtpr pdcm lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 5319.68
clflush size    : 64
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Xeon(R) CPU            3075  @ 2.66GHz
stepping        : 11
cpu MHz         : 2659.843
cache size      : 4096 KB
physical id     : 0
siblings        : 2
core id         : 1
cpu cores       : 2
apicid          : 1
initial apicid  : 1
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge=20
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx l=
m=20
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx smx es=
t=20
tm2 ssse3 cx16 xtpr pdcm lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 5320.30
clflush size    : 64
power management:


mpstat -P ALL 1 10
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft =20
%steal   %idle    intr/s
Average:     all    0.00    0.00    0.15    0.00    0.00    0.10   =20
0.00   99.75  73231.70
Average:       0    0.00    0.00    0.20    0.00    0.00    0.10   =20
0.00   99.70      0.00
Average:       1    0.00    0.00    0.00    0.00    0.00    0.00   =20
0.00  100.00  27686.80
Average:       2    0.00    0.00    0.00    0.00    0.00    0.00   =20
0.00    0.00      0.00

Some opreport:
CPU: Core 2, speed 2659.84 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a=20
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        app name                 symbol name
7592      8.3103  vmlinux                  rb_next
5393      5.9033  vmlinux                  e1000_get_hw_control
4514      4.9411  vmlinux                  hfsc_dequeue
4069      4.4540  vmlinux                  e1000_intr_msi
3695      4.0446  vmlinux                  u32_classify
3522      3.8552  vmlinux                  poll_idle
2234      2.4454  vmlinux                  _raw_spin_lock
2077      2.2735  vmlinux                  read_tsc
1855      2.0305  vmlinux                  rb_prev
1834      2.0075  vmlinux                  getnstimeofday
1800      1.9703  vmlinux                  e1000_clean_rx_irq
1553      1.6999  vmlinux                  ip_route_input
1509      1.6518  vmlinux                  hfsc_enqueue
1451      1.5883  vmlinux                  irq_entries_start
1419      1.5533  vmlinux                  mwait_idle
1392      1.5237  vmlinux                  e1000_clean_tx_irq
1345      1.4723  vmlinux                  rb_erase
1294      1.4164  vmlinux                  sfq_enqueue
1187      1.2993  libc-2.6.1.so            (no symbols)
1162      1.2719  vmlinux                  sfq_dequeue
1134      1.2413  vmlinux                  ipt_do_table
1116      1.2216  vmlinux                  apic_timer_interrupt
1108      1.2128  vmlinux                  cftree_insert
1039      1.1373  vmlinux                  rtsc_y2x
985       1.0782  vmlinux                  e1000_xmit_frame
943       1.0322  vmlinux                  update_vf

 bwm-ng v0.6 (probing every 5.000s), press 'h' for help
  input: /proc/net/dev type: rate
  /         iface                   Rx                  =20
Tx                Total
 =20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
               lo:           0.00 KB/s            0.00 KB/s           =20
0.00 KB/s
             eth1:       20716.35 KB/s        24258.43 KB/s       =20
44974.78 KB/s
             eth0:       24365.31 KB/s        30691.10 KB/s       =20
55056.42 KB/s
 =20
-----------------------------------------------------------------------=
-------

bwm-ng v0.6 (probing every 5.000s), press 'h' for help
  input: /proc/net/dev type: rate
  |         iface                   Rx                  =20
Tx                Total
 =20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
               lo:            0.00 P/s             0.00 P/s            =
=20
0.00 P/s
             eth1:        38034.00 P/s         36751.00 P/s        =20
74785.00 P/s
             eth0:        37195.40 P/s         38115.00 P/s        =20
75310.40 P/s
     =20
Maximum CPU load is when rush hour (from 5:00 pm to 10:00 pm) then it i=
s=20
20% - 30% of each CPU.


So i think you must change type of your hash tree in u32 filtering.
I use simply split of big nets like /18, /20, /21 to /24 prefixes  to=20
build my hash tree.
I make many tests and this configuration of hash works best for my=20
configuration.



Regards
Pawe=C5=82 Sstaszewski





Calin Velea pisze:
> Thursday, April 30, 2009, 2:19:36 PM, you wrote:
>
>  =20
>> On Thu, 2009-04-30 at 01:49 +0300, Calin Velea wrote:
>>    =20
>>>    I tested with e1000 only, on a single quad-core CPU - the L2 cac=
he was
>>> shared between the cores.
>>>
>>>   For 8 cores I suppose you have 2 quad-core CPUs. If the cores act=
ually
>>> used belong to different physical CPUs, L2 cache sharing does not o=
ccur -
>>> maybe this could explain the performance drop in your case.
>>>   Or there may be other explanation...
>>>      =20
>
>  =20
>> It is correct, I have 2 quad-core CPUs. If adjacent kernel-identifie=
d
>> CPUs are on the same physical CPU (e.g. CPU0, CPU1, CPU2 and CPU3) -=
 and
>> it is very probable - then I think the L2 cache was actually shared.
>> That's because the used CPUs where either 0-3 or 4-7 but never a mix=
 of
>> them. So perhaps there is another explanation (maybe driver/hardware=
).
>>    =20
>
>  =20
>>>   It could be the only way to get more power is to increase the num=
ber=20
>>> of devices where you are shaping. You could split the IP space into=
 4 groups
>>> and direct the trafic to 4 IMQ devices with 4 iptables rules -
>>>
>>> -d 0.0.0.0/2 -j IMQ --todev imq0,
>>> -d 64.0.0.0/2 -j IMQ --todev imq1, etc...
>>>      =20
>
>  =20
>> Yes, but what if let's say 10.0.0.0/24 and 70.0.0.0/24 need to share
>> bandwidth? 10.a.b.c goes to imq0 qdisc, and 70.x.y.z goes to imq1 qd=
isc,
>> and the two qdiscs (HTB sets) are independent. This will result in a
>> maximum of double the allocated bandwidth (if HTB sets are identical=
 and
>> traffic is equally distributed).
>>    =20
>
>  =20
>>>   The performance gained through parallelism might be a lot higher =
than the=20
>>> added overhead of iptables and/or ipset nethash match. Anyway - thi=
s is more of
>>> a "hack" than a clean solution :)
>>>
>>> p.s.: latest IMQ at http://www.linuximq.net/ is for 2.6.26 so you w=
ill need to try with that
>>>      =20
>
>  =20
>> Yes, the performance gained through parallelism is expected to be hi=
gher
>> than the loss of the additional overhead. That's why I asked for
>> parallel HTB in the first place, but got very disappointed after Dav=
id
>> Miller's reply :)
>>    =20
>
>  =20
>> Thanks a lot for all the hints and for the imq link. Imq is very
>> interesting regardless of whether it proves to be useful for this
>> project of mine or not.
>>    =20
>
>  =20
>> Radu Rendec
>>    =20
>
>
>    Indeed, you need to use ipset with nethash to avoid bandwidth doub=
ling.
> Let's say we have a shaping bridge: customer side (download) is
> on eth0, the upstream side (upload) is on eth1.
>
>    Create customer groups with ipset (http://ipset.netfilter.org/)
>
> ipset -N cust_group1_ips nethash
> ipset -A cust_group1_ips <subnet/mask>
> ....
> ....for each subnet
>
>
>
> To shape the upload with multiple IMQs:
>
> -m physdev --physdev-in eth0 -m set --set cust_group1_ips src -j IMQ =
--to-dev 0
> -m physdev --physdev-in eth0 -m set --set cust_group2_ips src -j IMQ =
--to-dev 1
> -m physdev --physdev-in eth0 -m set --set cust_group3_ips src -j IMQ =
--to-dev 2
> -m physdev --physdev-in eth0 -m set --set cust_group4_ips src -j IMQ =
--to-dev 3
>
>
>  You will apply the same htb upload limits to imq 0-3.
>  Upload for customers having source IPs from the first group will be =
shaped
> by imq0, for the second, by imq1, etc...
>
>
> For download:
>
> -m physdev --physdev-in eth1 -m set --set cust_group1_ips dst -j IMQ =
--to-dev 4
> -m physdev --physdev-in eth1 -m set --set cust_group2_ips dst -j IMQ =
--to-dev 5
> -m physdev --physdev-in eth1 -m set --set cust_group3_ips dst -j IMQ =
--to-dev 6
> -m physdev --physdev-in eth1 -m set --set cust_group4_ips dst -j IMQ =
--to-dev 7
>
> and apply the same download limits on imq 4-7
>
>
>  =20
>> __________ NOD32 4045 (20090430) Information __________
>>    =20
>
>  =20
>> This message was checked by NOD32 antivirus system.
>> http://www.eset.com
>>    =20
>
>
>
>
>  =20

