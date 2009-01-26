From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: DCA/IOAT problem
Date: Mon, 26 Jan 2009 20:49:12 +0100
Message-ID: <497E13B8.9040803@itcare.pl>
References: <497DF609.9000600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:55717 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbZAZT4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 14:56:00 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.7.230.35])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 26 Jan 2009 19:49:16 -0000
In-Reply-To: <497DF609.9000600@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Some lspci:
lspci
00:00.0 Host bridge: Intel Corporation Memory Controller Hub (rev 90)
00:02.0 PCI bridge: Intel Corporation PCI Express x8 Port 2-3 (rev 90)
00:04.0 PCI bridge: Intel Corporation PCI Express x16 Port 4-7 (rev 90)
00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
00:10.0 Host bridge: Intel Corporation FSB Registers (rev 90)
00:10.1 Host bridge: Intel Corporation FSB Registers (rev 90)
00:10.2 Host bridge: Intel Corporation FSB Registers (rev 90)
00:11.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
00:13.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
00:15.0 Host bridge: Intel Corporation DDR Channel 0 Registers (rev 90)
00:16.0 Host bridge: Intel Corporation DDR Channel 1 Registers (rev 90)
00:1a.0 USB Controller: Intel Corporation USB UHCI Controller #4 (rev 02)
00:1a.7 USB Controller: Intel Corporation USB2 EHCI Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation PCI Express Port 1 (rev 02)
00:1c.4 PCI bridge: Intel Corporation PCI Express Port 5 (rev 02)
00:1c.5 PCI bridge: Intel Corporation PCI Express Port 6 (rev 02)
00:1d.0 USB Controller: Intel Corporation USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation USB2 EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation LPC Interface Controller (rev 02)
00:1f.2 IDE interface: Intel Corporation 4 port SATA IDE Controller (rev 02)
00:1f.3 SMBus: Intel Corporation SMBus Controller (rev 02)
00:1f.5 IDE interface: Intel Corporation 2 port SATA IDE Controller (rev 02)
01:00.0 Ethernet controller: Intel Corporation Device 10dd (rev 01)
04:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet 
Controller (Copper) (rev 03)
05:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet 
Controller
06:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)

and then:
modprobe ioatdma

dmesg:
...
...
IPv4 FIB: Using LC-trie version 0.408
e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
0000:05:00.0: eth1: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
dca service started, version 1.4
ioatdma 0000:00:08.0: can't find IRQ for PCI INT A; probably buggy MP table
ioatdma 0000:00:08.0: setting latency timer to 64
ioatdma 0000:00:08.0: Intel(R) I/OAT DMA Engine found, 4 channels, 
device version 0x12, driver version 3.30
ioatdma 0000:00:08.0: irq 1255 for MSI/MSI-X
ioatdma 0000:00:08.0: DCA is disabled in BIOS
ixgbe: eth2: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow Control: None
e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X

...
...


lspvi -vvv (for dma engine)
00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
        Subsystem: Super Micro Computer Inc Device de80
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 1255
        Region 0: Memory at fe700000 (64-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit- 
Queue=0/0 Enable+
                Address: feeff00c  Data: 41b2
        Capabilities: [6c] Express (v1) Root Complex Integrated 
Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
<64ns, L1 <1us
                        ExtTag- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal+ 
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
                LnkCap: Port #0, Speed unknown, Width x0, ASPM unknown, 
Latency L0 <64ns, L1 <1us
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed unknown, Width x0, TrErr- Train- SlotClk- 
DLActive- BWMgmt- ABWMgmt-
        Kernel driver in use: ioatdma


cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3       CPU4       
CPU5       CPU6       CPU7
  0:         81          6          9          7          5          
3          9          5   IO-APIC-edge      timer
  1:          1          0          0          0          1          
0          0          0   IO-APIC-edge      i8042
  2:          0          0          0          0          0          
0          0          0    XT-PIC-XT        cascade
 14:        901        857        867        864        708        
674        693        692   IO-APIC-edge      ata_piix
 15:        686        728        691        703        826        
897        876        872   IO-APIC-edge      ata_piix
 18:          0          0          0          0          0          
0          0          0   IO-APIC-fasteoi   ata_piix
1255:          1          0          1          0          1          
0          1          1   PCI-MSI-edge      ioat-msi
1256:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth2:lsc
1257:        857        720       1176        802        960        
751        706        841   PCI-MSI-edge      eth2:v15-Tx
1258:        958        751        706        841       1176        
802        720        859   PCI-MSI-edge      eth2:v14-Tx
1259:       1176        802        720        859        706        
841        751        958   PCI-MSI-edge      eth2:v13-Tx
1260:        706        842        751        959        720        
858        802       1175   PCI-MSI-edge      eth2:v12-Tx
1261:        720        858        802       1174        751        
960        842        706   PCI-MSI-edge      eth2:v11-Tx
1262:        751        960        842        706        802       
1174        858        720   PCI-MSI-edge      eth2:v10-Tx
1263:        802       1174        858        720        842        
706        960        751   PCI-MSI-edge      eth2:v9-Tx
1264:        842        707        960        751        859        
719       1173        802   PCI-MSI-edge      eth2:v8-Tx
1265:     814186     813591     813713     814872     814537     
816002     812892     814292   PCI-MSI-edge      eth2:v7-Rx
1266:     626856     626688     627886     627507     628067     
625730     626561     626521   PCI-MSI-edge      eth2:v6-Rx
1267:     592474     591312     591741     592107     592214     
593218     591271     591386   PCI-MSI-edge      eth2:v5-Rx
1268:     558076     559008     557856     558677     557894     
556703     557997     558879   PCI-MSI-edge      eth2:v4-Rx
1269:     723457     725019     723746     724688     723165     
724716     724037     725136   PCI-MSI-edge      eth2:v3-Rx
1270:     553387     554096     553204     552603     553078     
553587     553838     553769   PCI-MSI-edge      eth2:v2-Rx
1271:     603820     605323     605368     602989     604948     
604887     606911     604745   PCI-MSI-edge      eth2:v1-Rx
1272:     800828     798049     799471     799703     799183     
798322     799220     798254   PCI-MSI-edge      eth2:v0-Rx
1273:       2868       2894       2970       2808       2863       
2803       3167       2860   PCI-MSI-edge      eth1
1274:        873        856        882        924        933        
904        864        943   PCI-MSI-edge      eth0
NMI:          0          0          0          0          0          
0          0          0   Non-maskable interrupts
LOC:      40527      41783      40049      40903      42180      
39477      49021      47628   Local timer interrupts
RES:        858         58        232        283         89         
97        284        435   Rescheduling interrupts
CAL:         52        101         99         88         96         
93         92         58   Function call interrupts
TLB:        143        133        486        452        141        
159        396        429   TLB shootdowns
SPU:          0          0          0          0          0          
0          0          0   Spurious interrupts
ERR:          0
MIS:          0


cat /proc/cpuinfo
 cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 4
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
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 5999.79
clflush size    : 64
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 1
siblings        : 4
core id         : 0
cpu cores       : 4
apicid          : 4
initial apicid  : 4
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6065.40
clflush size    : 64
power management:

processor       : 2
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 4
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
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.46
clflush size    : 64
power management:

processor       : 3
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 1
siblings        : 4
core id         : 1
cpu cores       : 4
apicid          : 5
initial apicid  : 5
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.47
clflush size    : 64
power management:

processor       : 4
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 2
cpu cores       : 4
apicid          : 2
initial apicid  : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.43
clflush size    : 64
power management:

processor       : 5
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 1
siblings        : 4
core id         : 2
cpu cores       : 4
apicid          : 6
initial apicid  : 6
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.50
clflush size    : 64
power management:

processor       : 6
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 3
cpu cores       : 4
apicid          : 3
initial apicid  : 3
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.43
clflush size    : 64
power management:

processor       : 7
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 2999.898
cache size      : 6144 KB
physical id     : 1
siblings        : 4
core id         : 3
cpu cores       : 4
apicid          : 7
initial apicid  : 7
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm 
constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.47
clflush size    : 64
power management:




I have enabled DCA in my Bios.
So why i have info:
ioatdma 0000:00:08.0: DCA is disabled in BIOS

and:
ls -la /sys/class/dca/
total 0
drwxr-xr-x  2 root root 0 Jan 26 16:21 .
drwxr-xr-x 33 root root 0 Jan 26 16:14 ..

cat /sys/class/dma/dma0chan0/in_use
0
cat /sys/class/dma/dma0chan1/in_use
1
cat /sys/class/dma/dma0chan2/in_use
0
cat /sys/class/dma/dma0chan3/in_use
0


Why DCA is not working (or workink but no info about in ioat)



