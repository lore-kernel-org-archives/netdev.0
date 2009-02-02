From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 11:48:25 -0500
Message-ID: <498723D9.5020509@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1106 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752584AbZBBQsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 11:48:31 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id 26DBB4D49A
	for <netdev@vger.kernel.org>; Mon,  2 Feb 2009 11:48:28 -0500 (EST)
In-Reply-To: <20090131160333.GC23100@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>  =20
>> Kenny Chang a =E9crit :
>>    =20
>>> Ah, sorry, here's the test program attached.
>>>
>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
>>> 2.6.29.-rcX.
>>>
>>> Right now, we are trying to step through the kernel versions until =
we
>>> see where the performance drops significantly.  We'll try 2.6.29-rc=
 soon
>>> and post the result.
>>>      =20
>> 2.6.29-rc contains UDP receive improvements (lockless)
>>
>> Problem is multicast handling was not yet updated, but could be :)
>>
>>
>> I was asking you "cat /proc/interrupts" because I believe you might
>> have a problem NIC interrupts being handled by one CPU only (when ha=
ving problems)
>>
>>    =20
> That would be expected (if irqbalance is running), and desireable, si=
nce
> spreading high volume interrupts like NICS accross multiple cores (or=
 more
> specifically multiple L2 caches), is going increase your cache line m=
iss rate
> significantly and decrease rx throughput.
>
> Although you do have a point here, if the system isn't running irqbal=
ance, and
> the NICS irq affinity is spread accross multiple L2 caches, that woul=
d be a
> point of improvement performance-wise. =20
>
> Kenny, if you could provide the /proc/interrupts info along with /pro=
c/cpuinfo
> and your stats that I asked about earlier, that would be a big help.
>
> Regards
> Neil
>
>  =20
This is for a working setup.

-Kenny

kchang@fiji:~$ uname -a
Linux fiji 2.6.24-19-generic #1 SMP Wed Aug 20 17:53:40 UTC 2008 x86_64=
=20
GNU/Linux
kchang@fiji:~$ cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
stepping        : 11
cpu MHz         : 1600.000
cache size      : 4096 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 10
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
nx lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vm=
x=20
est tm2 ssse3 cx16 xtpr lahf_lm
bogomips    : 4791.31
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 15
model name    : Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
stepping    : 11
cpu MHz        : 1600.000
cache size    : 4096 KB
physical id    : 0
siblings    : 4
core id        : 1
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 10
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
nx lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vm=
x=20
est tm2 ssse3 cx16 xtpr lahf_lm
bogomips    : 4788.05
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 15
model name    : Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
stepping    : 11
cpu MHz        : 1600.000
cache size    : 4096 KB
physical id    : 0
siblings    : 4
core id        : 2
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 10
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
nx lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vm=
x=20
est tm2 ssse3 cx16 xtpr lahf_lm
bogomips    : 4788.08
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 15
model name    : Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
stepping    : 11
cpu MHz        : 1600.000
cache size    : 4096 KB
physical id    : 0
siblings    : 4
core id        : 3
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 10
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
nx lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vm=
x=20
est tm2 ssse3 cx16 xtpr lahf_lm
bogomips    : 4788.07
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

kchang@fiji:~$ cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3     =20
  0:        165          0          0          0   IO-APIC-edge      ti=
mer
  1:          2          0          0          0   IO-APIC-edge      i8=
042
  8:          1          0          0          0   IO-APIC-edge      rt=
c
  9:          0          0          0          0   IO-APIC-fasteoi   ac=
pi
 12:          4          0          0          0   IO-APIC-edge      i8=
042
 16:   25614400          0          0          0   IO-APIC-fasteoi  =20
uhci_hcd:usb3, HDA Intel, eth1, nvidia
 17:     571932          0          0          0   IO-APIC-fasteoi  =20
uhci_hcd:usb4, uhci_hcd:usb6
 18:     102824          0          0          0   IO-APIC-fasteoi  =20
uhci_hcd:usb7
 22:          0          0          0          0   IO-APIC-fasteoi  =20
ehci_hcd:usb1
 23:    1636819          0          0          0   IO-APIC-fasteoi  =20
ehci_hcd:usb2, uhci_hcd:usb5
507:   12542966          0          0          0   PCI-MSI-edge      et=
h0
508:    1201118          0          0          0   PCI-MSI-edge      ah=
ci
NMI:          0          0          0          0   Non-maskable interru=
pts
LOC:   29214662   20141857   21777347   14279251   Local timer interrup=
ts
RES:     205758     173268     238058     123958   Rescheduling interru=
pts
CAL:       2623       3732       3814       2747   function call interr=
upts
TLB:      29961      56621      31440      55783   TLB shootdowns
TRM:          0          0          0          0   Thermal event interr=
upts
THR:          0          0          0          0   Threshold APIC inter=
rupts
SPU:          0          0          0          0   Spurious interrupts
ERR:          0

