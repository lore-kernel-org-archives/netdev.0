From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 11:13:19 -0500
Message-ID: <49871B9F.8080707@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1063 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752673AbZBBQNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 11:13:22 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id 24B6E4D492
	for <netdev@vger.kernel.org>; Mon,  2 Feb 2009 11:13:19 -0500 (EST)
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
Hi Neil,

Here's the information you requested.

Kenny

kchang@beast8:~$ uname -a
Linux beast8 2.6.24-19-server #1 SMP Wed Aug 20 18:43:06 UTC 2008 x86_6=
4=20
GNU/Linux
kchang@beast8:~$ cat /proc/cpuinfo
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 0
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5322.91
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 1
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.03
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 2
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.06
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 3
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.06
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 4
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 1
siblings    : 4
core id        : 0
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.07
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 5
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 1
siblings    : 4
core id        : 1
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.07
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 6
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 1
siblings    : 4
core id        : 2
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.08
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 7
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           L5430  @ 2.66GHz
stepping    : 10
cpu MHz        : 2659.999
cache size    : 6144 KB
physical id    : 1
siblings    : 4
core id        : 3
cpu cores    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
=20
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall=20
lm constant_tsc arch_perfmon pebs bts rep_good pni monitor ds_cpl vmx=20
est tm2 ssse3 cx16 xtpr dca sse4_1 lahf_lm
bogomips    : 5320.08
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

kchang@beast8:~$ cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3       CPU4      =20
CPU5       CPU6       CPU7     =20
  0:         67          0          1          0          0         =20
0          0          0   IO-APIC-edge      timer
  1:          0          0          0          0          0         =20
0          0          0   IO-APIC-edge      i8042
  8:          0          0          0          1          0         =20
0          0          0   IO-APIC-edge      rtc
  9:          0          0          0          0          0         =20
0          0          0   IO-APIC-fasteoi   acpi
 14:         12         13         13         13         12        =20
10         13         13   IO-APIC-edge      libata
 15:          0          0          0          0          0         =20
0          0          0   IO-APIC-edge      libata
 17:        294        295        293        294        294       =20
296        293        288   IO-APIC-fasteoi   aacraid
 22:          6          5          5          5          6         =20
6          6          6   IO-APIC-fasteoi   uhci_hcd:usb3
 23:          7          8          8          7          7         =20
8          7          8   IO-APIC-fasteoi   ehci_hcd:usb1,=20
uhci_hcd:usb2, uhci_hcd:usb4
2294:         48         46         48         48         49        =20
47         48         51   PCI-MSI-edge      eth0
NMI:          0          0          0          0          0         =20
0          0          0   Non-maskable interrupts
LOC:       5088       3394       3129       2835       2561      =20
2938       2576       2798   Local timer interrupts
RES:         59        119         58         36         34        =20
71         50         17   Rescheduling interrupts
CAL:        132        128        149        141        138       =20
140        152        140   function call interrupts
TLB:        285        178        278        183        297       =20
191        295        157   TLB shootdowns
TRM:          0          0          0          0          0         =20
0          0          0   Thermal event interrupts
THR:          0          0          0          0          0         =20
0          0          0   Threshold APIC interrupts
SPU:          0          0          0          0          0         =20
0          0          0   Spurious interrupts
ERR:          0

