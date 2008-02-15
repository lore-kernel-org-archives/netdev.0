From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: BUG/ spinlock lockup, 2.6.24
Date: Fri, 15 Feb 2008 17:19:10 +0200
Message-ID: <20080215150044.M24489@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:50771 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964AbYBOPT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 10:19:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Server crashed(not responding over network), last line over netconsole was 

Feb 15 15:50:17 217.151.X.X [1521315.068984] BUG: spinlock lockup on CPU#1, 
ksoftirqd/1/7, f0551180

I have random crashes, at least once per week. It is very difficult to catch 
error message, and only recently i setup netconsole. Now i got crash, but 
there is no traceback and only single line came over netconsole, mentioned 
before.

.config file 
http://www.nuclearcat.com/files/config_qos

Kernel is 2.6.24 with epoll patch(it is from mainline) applied.
cat /proc/version
Linux version 2.6.24-devel (root@visp-1) (gcc version 4.1.1 (Gentoo 4.1.1-
r3)) #1 SMP Sat Jan 26 17:26:54 EET 2008

visp-1 ~ # cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3
  0:      18361      17785      17471      17748   IO-APIC-edge      timer
  1:          2          0          0          0   IO-APIC-edge      i8042
  8:          5          4          3          4   IO-APIC-edge      rtc
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          1          0          1          2   IO-APIC-edge      i8042
 14:         14         17         17         15   IO-APIC-edge      libata
 15:          0          0          0          0   IO-APIC-edge      libata
 17:        269        259        256        259   IO-APIC-fasteoi   ioc0
 18:          5          5          6          7   IO-APIC-fasteoi   
ehci_hcd:usb1, uhci_hcd:usb2, uhci_hcd:usb4
 19:          0          0          0          0   IO-APIC-fasteoi   
uhci_hcd:usb3
 66:          1          0          0          0      none-<NULL>
212:         27         32         35         32   PCI-MSI-edge      eth1
213:      36818      36995      37307      37029   PCI-MSI-edge      eth0
214:          0          1          1          1   PCI-MSI-edge
NMI:      71107      70983      70962      70962   Non-maskable interrupts
LOC:      53005      53178      53490      53214   Local timer interrupts
RES:        414        434        363        378   Rescheduling interrupts
CAL:         52         46         56         47   function call interrupts
TLB:        398        288        403        264   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
SPU:          0          0          0          0   Spurious interrupts
ERR:          0
MIS:          0

visp-1 ~ # cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 6
model name      : Intel(R) Xeon(TM) CPU 3.20GHz
stepping        : 4
cpu MHz         : 3192.163
cache size      : 2048 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 6
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl vmx cid cx16 xtpr lahf_lm
bogomips        : 6390.17
clflush size    : 64

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 15
model           : 6
model name      : Intel(R) Xeon(TM) CPU 3.20GHz
stepping        : 4
cpu MHz         : 3192.163
cache size      : 2048 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 6
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl vmx cid cx16 xtpr lahf_lm
bogomips        : 6383.72
clflush size    : 64

processor       : 2
vendor_id       : GenuineIntel
cpu family      : 15
model           : 6
model name      : Intel(R) Xeon(TM) CPU 3.20GHz
stepping        : 4
cpu MHz         : 3192.163
cache size      : 2048 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 6
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl vmx cid cx16 xtpr lahf_lm
bogomips        : 6383.75
clflush size    : 64

processor       : 3
vendor_id       : GenuineIntel
cpu family      : 15
model           : 6
model name      : Intel(R) Xeon(TM) CPU 3.20GHz
stepping        : 4
cpu MHz         : 3192.163
cache size      : 2048 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 6
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl vmx cid cx16 xtpr lahf_lm
bogomips        : 6383.76
clflush size    : 64


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

