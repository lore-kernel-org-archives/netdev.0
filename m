From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: DCA/IOAT problem
Date: Tue, 27 Jan 2009 02:50:42 +0100
Message-ID: <497E6872.4030706@itcare.pl>
References: <497DF609.9000600@chelsio.com> <497E13B8.9040803@itcare.pl> <F169D4F5E1F1974DBFAFABF47F60C10A1C225006@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:59176 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbZA0Bur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 20:50:47 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1C225006@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse pisze:
> Forwarding entire message to include e1000-devel
>
> Pawel Staszewski wrote:
>   
>> Hello
>>
>> Some lspci:
>> lspci
>> 00:00.0 Host bridge: Intel Corporation Memory Controller Hub (rev 90)
>> 00:02.0 PCI bridge: Intel Corporation PCI Express x8 Port 2-3 (rev 90)
>> 00:04.0 PCI bridge: Intel Corporation PCI Express x16 Port 4-7 (rev
>> 90) 00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
>> 00:10.0 Host bridge: Intel Corporation FSB Registers (rev 90)
>> 00:10.1 Host bridge: Intel Corporation FSB Registers (rev 90)
>> 00:10.2 Host bridge: Intel Corporation FSB Registers (rev 90)
>> 00:11.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
>> 00:13.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
>> 00:15.0 Host bridge: Intel Corporation DDR Channel 0 Registers (rev
>> 90) 00:16.0 Host bridge: Intel Corporation DDR Channel 1 Registers
>> (rev 90) 00:1a.0 USB Controller: Intel Corporation USB UHCI
>> Controller #4 (rev 02) 00:1a.7 USB Controller: Intel Corporation USB2
>> EHCI Controller #2 (rev 02) 00:1c.0 PCI bridge: Intel Corporation PCI
>> Express Port 1 (rev 02) 00:1c.4 PCI bridge: Intel Corporation PCI
>> Express Port 5 (rev 02) 00:1c.5 PCI bridge: Intel Corporation PCI
>> Express Port 6 (rev 02) 00:1d.0 USB Controller: Intel Corporation USB
>> UHCI Controller #1 (rev 02) 00:1d.1 USB Controller: Intel Corporation
>> USB UHCI Controller #2 (rev 02) 00:1d.2 USB Controller: Intel
>> Corporation USB UHCI Controller #3 (rev 02) 00:1d.7 USB Controller:
>> Intel Corporation USB2 EHCI Controller #1 (rev 02) 00:1e.0 PCI
>> bridge: Intel Corporation 82801 PCI Bridge (rev 92) 00:1f.0 ISA
>> bridge: Intel Corporation LPC Interface Controller (rev 02) 00:1f.2
>> IDE interface: Intel Corporation 4 port SATA IDE Controller (rev 02)
>> 00:1f.3 SMBus: Intel Corporation SMBus Controller (rev 02) 00:1f.5
>> IDE interface: Intel Corporation 2 port SATA IDE Controller (rev 02)
>> 01:00.0 Ethernet controller: Intel Corporation Device 10dd (rev 01)
>> 04:00.0 Ethernet controller: Intel Corporation 82573E Gigabit
>> Ethernet Controller (Copper) (rev 03) 05:00.0 Ethernet controller:
>> Intel Corporation 82573L Gigabit Ethernet Controller
>> 06:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev
>> 02)
>> and then:
>> modprobe ioatdma
>>
>> dmesg:
>> ...
>> ...
>> IPv4 FIB: Using LC-trie version 0.408
>> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
>> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
>> e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
>> e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
>> 0000:05:00.0: eth1: Link is Up 1000 Mbps Full Duplex, Flow Control:
>> RX/TX dca service started, version 1.4
>> ioatdma 0000:00:08.0: can't find IRQ for PCI INT A; probably buggy MP
>> table ioatdma 0000:00:08.0: setting latency timer to 64
>> ioatdma 0000:00:08.0: Intel(R) I/OAT DMA Engine found, 4 channels,
>> device version 0x12, driver version 3.30
>> ioatdma 0000:00:08.0: irq 1255 for MSI/MSI-X
>> ioatdma 0000:00:08.0: DCA is disabled in BIOS
>> ixgbe: eth2: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow
>> Control: None e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
>> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
>>
>> ...
>> ...
>>
>>
>> lspvi -vvv (for dma engine)
>> 00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
>>         Subsystem: Super Micro Computer Inc Device de80
>>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B- DisINTx+
>>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>         Latency: 0
>>         Interrupt: pin A routed to IRQ 1255
>>         Region 0: Memory at fe700000 (64-bit, non-prefetchable)
>>         [size=1K] Capabilities: [50] Power Management version 2
>>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
>> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit-
>> Queue=0/0 Enable+
>>                 Address: feeff00c  Data: 41b2
>>         Capabilities: [6c] Express (v1) Root Complex Integrated
>> Endpoint, MSI 00
>>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
>> <64ns, L1 <1us
>>                         ExtTag- RBE- FLReset-
>>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal+
>> Unsupported-
>>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
>> AuxPwr- TransPend-
>>                 LnkCap: Port #0, Speed unknown, Width x0, ASPM
>> unknown, Latency L0 <64ns, L1 <1us
>>                         ClockPM- Suprise- LLActRep- BwNot-
>>                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
>>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>                 LnkSta: Speed unknown, Width x0, TrErr- Train-
>> SlotClk- DLActive- BWMgmt- ABWMgmt-
>>         Kernel driver in use: ioatdma
>>
>>
>> cat /proc/interrupts
>>            CPU0       CPU1       CPU2       CPU3       CPU4
>> CPU5       CPU6       CPU7
>>   0:         81          6          9          7          5
>> 3          9          5   IO-APIC-edge      timer
>>   1:          1          0          0          0          1
>> 0          0          0   IO-APIC-edge      i8042
>>   2:          0          0          0          0          0
>> 0          0          0    XT-PIC-XT        cascade
>>  14:        901        857        867        864        708
>> 674        693        692   IO-APIC-edge      ata_piix
>>  15:        686        728        691        703        826
>> 897        876        872   IO-APIC-edge      ata_piix
>>  18:          0          0          0          0          0
>> 0          0          0   IO-APIC-fasteoi   ata_piix
>> 1255:          1          0          1          0          1
>> 0          1          1   PCI-MSI-edge      ioat-msi
>> 1256:          0          0          0          0          0
>> 0          0          0   PCI-MSI-edge      eth2:lsc
>> 1257:        857        720       1176        802        960
>> 751        706        841   PCI-MSI-edge      eth2:v15-Tx
>> 1258:        958        751        706        841       1176
>> 802        720        859   PCI-MSI-edge      eth2:v14-Tx
>> 1259:       1176        802        720        859        706
>> 841        751        958   PCI-MSI-edge      eth2:v13-Tx
>> 1260:        706        842        751        959        720
>> 858        802       1175   PCI-MSI-edge      eth2:v12-Tx
>> 1261:        720        858        802       1174        751
>> 960        842        706   PCI-MSI-edge      eth2:v11-Tx
>> 1262:        751        960        842        706        802
>> 1174        858        720   PCI-MSI-edge      eth2:v10-Tx
>> 1263:        802       1174        858        720        842
>> 706        960        751   PCI-MSI-edge      eth2:v9-Tx
>> 1264:        842        707        960        751        859
>> 719       1173        802   PCI-MSI-edge      eth2:v8-Tx
>> 1265:     814186     813591     813713     814872     814537
>> 816002     812892     814292   PCI-MSI-edge      eth2:v7-Rx
>> 1266:     626856     626688     627886     627507     628067
>> 625730     626561     626521   PCI-MSI-edge      eth2:v6-Rx
>> 1267:     592474     591312     591741     592107     592214
>> 593218     591271     591386   PCI-MSI-edge      eth2:v5-Rx
>> 1268:     558076     559008     557856     558677     557894
>> 556703     557997     558879   PCI-MSI-edge      eth2:v4-Rx
>> 1269:     723457     725019     723746     724688     723165
>> 724716     724037     725136   PCI-MSI-edge      eth2:v3-Rx
>> 1270:     553387     554096     553204     552603     553078
>> 553587     553838     553769   PCI-MSI-edge      eth2:v2-Rx
>> 1271:     603820     605323     605368     602989     604948
>> 604887     606911     604745   PCI-MSI-edge      eth2:v1-Rx
>> 1272:     800828     798049     799471     799703     799183
>> 798322     799220     798254   PCI-MSI-edge      eth2:v0-Rx
>> 1273:       2868       2894       2970       2808       2863
>> 2803       3167       2860   PCI-MSI-edge      eth1
>> 1274:        873        856        882        924        933
>> 904        864        943   PCI-MSI-edge      eth0
>> NMI:          0          0          0          0          0
>> 0          0          0   Non-maskable interrupts
>> LOC:      40527      41783      40049      40903      42180
>> 39477      49021      47628   Local timer interrupts
>> RES:        858         58        232        283         89
>> 97        284        435   Rescheduling interrupts
>> CAL:         52        101         99         88         96
>> 93         92         58   Function call interrupts
>> TLB:        143        133        486        452        141
>> 159        396        429   TLB shootdowns
>> SPU:          0          0          0          0          0
>> 0          0          0   Spurious interrupts
>> ERR:          0
>> MIS:          0
>>
>>
>> cat /proc/cpuinfo
>>  cat /proc/cpuinfo
>> processor       : 0
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 0
>> siblings        : 4
>> core id         : 0
>> cpu cores       : 4
>> apicid          : 0
>> initial apicid  : 0
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 5999.79
>> clflush size    : 64
>> power management:
>>
>> processor       : 1
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 1
>> siblings        : 4
>> core id         : 0
>> cpu cores       : 4
>> apicid          : 4
>> initial apicid  : 4
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6065.40
>> clflush size    : 64
>> power management:
>>
>> processor       : 2
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 0
>> siblings        : 4
>> core id         : 1
>> cpu cores       : 4
>> apicid          : 1
>> initial apicid  : 1
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.46
>> clflush size    : 64
>> power management:
>>
>> processor       : 3
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 1
>> siblings        : 4
>> core id         : 1
>> cpu cores       : 4
>> apicid          : 5
>> initial apicid  : 5
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.47
>> clflush size    : 64
>> power management:
>>
>> processor       : 4
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 0
>> siblings        : 4
>> core id         : 2
>> cpu cores       : 4
>> apicid          : 2
>> initial apicid  : 2
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.43
>> clflush size    : 64
>> power management:
>>
>> processor       : 5
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 1
>> siblings        : 4
>> core id         : 2
>> cpu cores       : 4
>> apicid          : 6
>> initial apicid  : 6
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.50
>> clflush size    : 64
>> power management:
>>
>> processor       : 6
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 0
>> siblings        : 4
>> core id         : 3
>> cpu cores       : 4
>> apicid          : 3
>> initial apicid  : 3
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.43
>> clflush size    : 64
>> power management:
>>
>> processor       : 7
>> vendor_id       : GenuineIntel
>> cpu family      : 6
>> model           : 23
>> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> stepping        : 6
>> cpu MHz         : 2999.898
>> cache size      : 6144 KB
>> physical id     : 1
>> siblings        : 4
>> core id         : 3
>> cpu cores       : 4
>> apicid          : 7
>> initial apicid  : 7
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 10
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
>> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
>> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
>> flexpriority bogomips        : 6000.47
>> clflush size    : 64
>> power management:
>>
>>
>>
>>
>> I have enabled DCA in my Bios.
>> So why i have info:
>> ioatdma 0000:00:08.0: DCA is disabled in BIOS
>>     
>
> Probably because the BIOS is not working correctly or there is a bug in 
> dca. Is that a supermicro machine?  Can you include the output of 
> dmidecode?  Are you running the latest BIOS?  What are you trying to 
> achieve?  DCA or IOAT DMA copy offload (two separate features)
>
>   
Yes this is an supermicro board X7DCT-10G
http://www.supermicro.com/products/motherboard/Xeon1333/5100/X7DCT-10G.cfm
Bios is no latest but in new bios is no info in changelog about ioat/dca 
so i don't update
i want to test / compare DCA over IOAT with my env that is Traffic 
management Linux sever
with more than 3Gbit/s traffic and 10k users.


dmidecode:
# dmidecode 2.9
SMBIOS 2.5 present.
39 structures occupying 1950 bytes.
Table at 0xDFF5F000.

Handle 0x0000, DMI type 0, 24 bytes
BIOS Information
        Vendor: Phoenix Technologies LTD
        Version: 1.0c
        Release Date: 07/10/2008
        Address: 0xE5100
        Runtime Size: 110336 bytes
        ROM Size: 2048 kB
        Characteristics:
                ISA is supported
                PCI is supported
                PNP is supported
                BIOS is upgradeable
                BIOS shadowing is allowed
                ESCD support is available
                Boot from CD is supported
                Selectable boot is supported
                BIOS ROM is socketed
                EDD is supported
                5.25"/1.2 MB floppy services are supported (int 13h)
                3.5"/720 KB floppy services are supported (int 13h)
                3.5"/2.88 MB floppy services are supported (int 13h)
                Print screen service is supported (int 5h)
                8042 keyboard services are supported (int 9h)
                Serial services are supported (int 14h)
                Printer services are supported (int 17h)
                CGA/mono video services are supported (int 10h)
                ACPI is supported
                USB legacy is supported
                BIOS boot specification is supported
                Targeted content distribution is supported

Handle 0x0001, DMI type 1, 27 bytes
System Information
        Manufacturer: Supermicro
        Product Name: X7DCT
        Version: 0123456789
        Serial Number: 0123456789
        UUID: E3D0A497-4663-90E7-895F-003048D333D7
        Wake-up Type: Power Switch
        SKU Number: Not Specified
        Family: Not Specified

Handle 0x0002, DMI type 2, 10 bytes
Base Board Information
        Manufacturer: Supermicro
        Product Name: X7DCT
        Version: PCB Version
        Serial Number: 0123456789

Handle 0x0003, DMI type 3, 17 bytes
Chassis Information
        Manufacturer: Supermicro
        Type: Other
        Lock: Not Present
        Version: 0123456789
        Serial Number: 0123456789
        Asset Tag:
        Boot-up State: Safe
        Power Supply State: Safe
        Thermal State: Safe
        Security Status: None
        OEM Information: 0x00001234

Handle 0x0004, DMI type 4, 35 bytes
Processor Information
        Socket Designation: LGA771
        Type: Central Processor
        Family: Xeon
        Manufacturer: GenuineIntel
        ID: 76 06 01 00 FF FB EB BF
        Signature: Type 0, Family 6, Model 23, Stepping 6
        Flags:
                FPU (Floating-point unit on-chip)
                VME (Virtual mode extension)
                DE (Debugging extension)
                PSE (Page size extension)
                TSC (Time stamp counter)
                MSR (Model specific registers)
                PAE (Physical address extension)
                MCE (Machine check exception)
                CX8 (CMPXCHG8 instruction supported)
                APIC (On-chip APIC hardware supported)
                SEP (Fast system call)
                MTRR (Memory type range registers)
                PGE (Page global enable)
                MCA (Machine check architecture)
                CMOV (Conditional move instruction supported)
                PAT (Page attribute table)
                PSE-36 (36-bit page size extension)
                CLFSH (CLFLUSH instruction supported)
                DS (Debug store)
                ACPI (ACPI supported)
                MMX (MMX technology supported)
                FXSR (Fast floating-point save and restore)
                SSE (Streaming SIMD extensions)
                SSE2 (Streaming SIMD extensions 2)
                SS (Self-snoop)
                HTT (Hyper-threading technology)
                TM (Thermal monitor supported)
                PBE (Pending break enabled)
        Version: Intel(R) Xeon(R) CPU           X
        Voltage: 1.4 V
        External Clock: Unknown
        Max Speed: 3200 MHz
        Current Speed: 3000 MHz
        Status: Populated, Enabled
        Upgrade: Socket LGA771
        L1 Cache Handle: 0x0006
        L2 Cache Handle: 0x0007
        L3 Cache Handle: Not Provided
        Serial Number: Not Specified
        Asset Tag: Not Specified
        Part Number: Not Specified

Handle 0x0005, DMI type 4, 35 bytes
Processor Information
        Socket Designation: LGA771
        Type: Central Processor
        Family: Xeon
        Manufacturer: GenuineIntel
        ID: 76 06 01 00 FF FB EB BF
        Signature: Type 0, Family 6, Model 23, Stepping 6
        Flags:
                FPU (Floating-point unit on-chip)
                VME (Virtual mode extension)
                DE (Debugging extension)
                PSE (Page size extension)
                TSC (Time stamp counter)
                MSR (Model specific registers)
                PAE (Physical address extension)
                MCE (Machine check exception)
                CX8 (CMPXCHG8 instruction supported)
                APIC (On-chip APIC hardware supported)
                SEP (Fast system call)
                MTRR (Memory type range registers)
                PGE (Page global enable)
                MCA (Machine check architecture)
                CMOV (Conditional move instruction supported)
                PAT (Page attribute table)
                PSE-36 (36-bit page size extension)
                CLFSH (CLFLUSH instruction supported)
                DS (Debug store)
                ACPI (ACPI supported)
                MMX (MMX technology supported)
                FXSR (Fast floating-point save and restore)
                SSE (Streaming SIMD extensions)
                SSE2 (Streaming SIMD extensions 2)
                SS (Self-snoop)
                HTT (Hyper-threading technology)
                TM (Thermal monitor supported)
                PBE (Pending break enabled)
        Version: Intel(R) Xeon(R) CPU           X5
        Voltage: 1.4 V
        External Clock: Unknown
        Max Speed: 3200 MHz
        Current Speed: 3000 MHz
        Status: Populated, Enabled
        Upgrade: Socket LGA771
        L1 Cache Handle: 0x0008
        L2 Cache Handle: 0x0009
        L3 Cache Handle: Not Provided
        Serial Number: Not Specified
        Asset Tag: Not Specified
        Part Number: Not Specified

Handle 0x0006, DMI type 7, 19 bytes
Cache Information
        Socket Designation: L1 Cache
        Configuration: Enabled, Socketed, Level 1
        Operational Mode: Write Back
        Location: Internal
        Installed Size: 16 KB
        Maximum Size: 16 KB
        Supported SRAM Types:
                Burst
                Pipeline Burst
                Asynchronous
        Installed SRAM Type: Asynchronous
        Speed: Unknown
        Error Correction Type: Unknown
        System Type: Unknown
        Associativity: Unknown

Handle 0x0007, DMI type 7, 19 bytes
Cache Information
        Socket Designation: L2 Cache
        Configuration: Enabled, Socketed, Level 2
        Operational Mode: Write Back
        Location: Internal
        Installed Size: 12288 KB
        Maximum Size: 8192 KB
        Supported SRAM Types:
                Burst
                Pipeline Burst
                Asynchronous
        Installed SRAM Type: Burst
        Speed: Unknown
        Error Correction Type: Unknown
        System Type: Unknown
        Associativity: Unknown

Handle 0x0008, DMI type 7, 19 bytes
Cache Information
        Socket Designation: L1 Cache
        Configuration: Enabled, Socketed, Level 1
        Operational Mode: Write Back
        Location: Internal
        Installed Size: 16 KB
        Maximum Size: 16 KB
        Supported SRAM Types:
                Burst
                Pipeline Burst
                Asynchronous
        Installed SRAM Type: Asynchronous
        Speed: Unknown
        Error Correction Type: Unknown
        System Type: Unknown
        Associativity: Unknown

Handle 0x0009, DMI type 7, 19 bytes
Cache Information
        Socket Designation: L2 Cache
        Configuration: Enabled, Socketed, Level 2
        Operational Mode: Write Back
        Location: Internal
        Installed Size: 12288 KB
        Maximum Size: 8192 KB
        Supported SRAM Types:
                Burst
                Pipeline Burst
                Asynchronous
        Installed SRAM Type: Burst
        Speed: Unknown
        Error Correction Type: Unknown
        System Type: Unknown
        Associativity: Unknown

Handle 0x000A, DMI type 8, 9 bytes
Port Connector Information
        Internal Reference Designator: JCOM1
        Internal Connector Type: 9 Pin Dual Inline (pin 10 cut)
        External Reference Designator: COM1
        External Connector Type: DB-9 male
        Port Type: Serial Port 16550A Compatible

Handle 0x000B, DMI type 8, 9 bytes
Port Connector Information
        Internal Reference Designator: JCOM2
        Internal Connector Type: 9 Pin Dual Inline (pin 10 cut)
        External Reference Designator: COM2
        External Connector Type: DB-9 male
        Port Type: Serial Port 16550A Compatible

Handle 0x000C, DMI type 9, 13 bytes
System Slot Information
        Designation: PCIE#1-x16
        Type: PCI Express
        Current Usage: Available
        Length: Other
        ID: 1
        Characteristics:
                3.3 V is provided

Handle 0x000D, DMI type 11, 5 bytes
OEM Strings
        String 1: Intel Dempsey/San Clemente/ICH9
        String 2: Supermicro motherboard X7DCT

Handle 0x000E, DMI type 12, 5 bytes
System Configuration Options
        Option 1: Jumper settings can be described here.

Handle 0x000F, DMI type 15, 29 bytes
System Event Log
        Area Length: 192 bytes
        Header Start Offset: 0x0000
        Header Length: 16 bytes
        Data Start Offset: 0x0010
        Access Method: General-purpose non-volatile data functions
        Access Address: 0x0000
        Status: Valid, Not Full
        Change Token: 0x0000008D
        Header Format: Type 1
        Supported Log Type Descriptors: 3
        Descriptor 1: POST error
        Data Format 1: POST results bitmap
        Descriptor 2: Single-bit ECC memory error
        Data Format 2: Multiple-event
        Descriptor 3: Multi-bit ECC memory error
        Data Format 3: Multiple-event

Handle 0x0010, DMI type 16, 15 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: None
        Maximum Capacity: 64 GB
        Error Information Handle: Not Provided
        Number Of Devices: 6

Handle 0x0011, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH0_DIMM0
        Bank Locator: DIMM 0-1
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: B8CC1345
        Asset Tag:
        Part Number:

Handle 0x0012, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH1_DIMM0
        Bank Locator: DIMM 1-1
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: B8CC0545
        Asset Tag:
        Part Number:

Handle 0x0013, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH0_DIMM1
        Bank Locator: DIMM 0-2
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: BACCFD44
        Asset Tag:
        Part Number:

Handle 0x0014, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH1_DIMM1
        Bank Locator: DIMM 1-2
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: B8CC0845
        Asset Tag:
        Part Number:

Handle 0x0015, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH0_DIMM2
        Bank Locator: DIMM 0-3
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: BACCF444
        Asset Tag:
        Part Number:

Handle 0x0016, DMI type 17, 27 bytes
Memory Device
        Array Handle: 0x0010
        Error Information Handle: No Error
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 2048 MB
        Form Factor: DIMM
        Set: 1
        Locator: CH1_DIMM2
        Bank Locator: DIMM 1-3
        Type: DDR2
        Type Detail: Synchronous
        Speed: 667 MHz (1.5 ns)
        Manufacturer: 7F98000000000000
        Serial Number: B8CC1045
        Asset Tag:
        Part Number:

Handle 0x0017, DMI type 19, 15 bytes
Memory Array Mapped Address
        Starting Address: 0x00000000000
        Ending Address: 0x002FFFFFFFF
        Range Size: 12 GB
        Physical Array Handle: 0x0010
        Partition Width: 0

Handle 0x0018, DMI type 20, 19 bytes
Memory Device Mapped Address
        Starting Address: 0x00000000000
        Ending Address: 0x0007FFFFFFF
        Range Size: 2 GB
        Physical Device Handle: 0x0011
        Memory Array Mapped Address Handle: 0x0017
        Partition Row Position: Unknown
        Interleave Position: Unknown
        Interleaved Data Depth: Unknown

Handle 0x0019, DMI type 20, 19 bytes
Memory Device Mapped Address
        Starting Address: 0x00080000000
        Ending Address: 0x000FFFFFFFF
        Range Size: 2 GB
        Physical Device Handle: 0x0012
        Memory Array Mapped Address Handle: 0x0017
        Partition Row Position: Unknown
        Interleave Position: Unknown
        Interleaved Data Depth: Unknown

Handle 0x001A, DMI type 20, 19 bytes
Memory Device Mapped Address
        Starting Address: 0x00100000000
        Ending Address: 0x0017FFFFFFF
        Range Size: 2 GB
        Physical Device Handle: 0x0013
        Memory Array Mapped Address Handle: 0x0017
        Partition Row Position: Unknown
        Interleave Position: Unknown
        Interleaved Data Depth: Unknown

Handle 0x001B, DMI type 23, 13 bytes
System Reset
        Status: Enabled
        Watchdog Timer: Present
        Boot Option: Do Not Reboot
        Boot Option On Limit: Do Not Reboot
        Reset Count: Unknown
        Reset Limit: Unknown
        Timer Interval: Unknown
        Timeout: Unknown

Handle 0x001C, DMI type 24, 5 bytes
Hardware Security
        Power-On Password Status: Disabled
        Keyboard Password Status: Unknown
        Administrator Password Status: Disabled
        Front Panel Reset Status: Unknown

Handle 0x001D, DMI type 25, 9 bytes
        System Power Controls
        Next Scheduled Power-on: 12-31 23:59:59

Handle 0x001E, DMI type 26, 20 bytes
Voltage Probe
        Description: Voltage Probe
        Location: Processor
        Status: OK
        Maximum Value: Unknown
        Minimum Value: Unknown
        Resolution: Unknown
        Tolerance: Unknown
        Accuracy: Unknown
        OEM-specific Information: 0x00000000

Handle 0x001F, DMI type 27, 12 bytes
Cooling Device
        Temperature Probe Handle: 0x0020
        Type: Fan
        Status: OK
        OEM-specific Information: 0x00000000

Handle 0x0020, DMI type 28, 20 bytes
Temperature Probe
        Description: Temperature Probe
        Location: Processor
        Status: OK
        Maximum Value: Unknown
        Minimum Value Unknown
        Resolution: Unknown
        Tolerance: Unknown
        Accuracy: Unknown
        OEM-specific Information: 0x00000000

Handle 0x0021, DMI type 29, 20 bytes
Electrical Current Probe
        Description: Electrical Current Probe
        Location: Processor
        Status: OK
        Maximum Value: Unknown
        Minimum Value: Unknown
        Resolution: Unknown
        Tolerance: Unknown
        Accuracy: Unknown
        OEM-specific Information: 0x00000000

Handle 0x0022, DMI type 30, 6 bytes
Out-of-band Remote Access
        Manufacturer Name: Intel
        Inbound Connection: Disabled
        Outbound Connection: Enabled

Handle 0x0023, DMI type 32, 19 bytes
System Boot Information
        Status: No errors detected

Handle 0x0024, DMI type 38, 18 bytes
IPMI Device Information
        Interface Type: Unknown
        Specification Version: 1.0
        I2C Slave Address: 0x00
        NV Storage Device: Not Present
        Base Address: 0x0000000000000000 (Memory-mapped)
        Register Spacing: Successive Byte Boundaries

Handle 0x0025, DMI type 126, 4 bytes
Inactive

Handle 0x0026, DMI type 127, 4 bytes
End Of Table

>> and:
>> ls -la /sys/class/dca/
>> total 0
>> drwxr-xr-x  2 root root 0 Jan 26 16:21 .
>> drwxr-xr-x 33 root root 0 Jan 26 16:14 ..
>>
>> cat /sys/class/dma/dma0chan0/in_use
>> 0
>> cat /sys/class/dma/dma0chan1/in_use
>> 1
>> cat /sys/class/dma/dma0chan2/in_use
>> 0
>> cat /sys/class/dma/dma0chan3/in_use
>> 0
>>
>>
>> Why DCA is not working (or working but no info about in ioat)
>>     
>
> The DMA channels (copy offload) are different than the DCA feature.  DCA 
> involves front side bus hints sent from the adapter to the CPU handling 
> the interrupt, where DMA channels are for copy offload from the processor 
> to the independent data movers (DMA channels)
>
>   

