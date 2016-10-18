From: Roberto Fichera <kernel@tekno-soft.it>
Subject: PowerEdge R530 show rx dropped packet with BCM5720
Date: Tue, 18 Oct 2016 10:03:33 +0200
Message-ID: <ed850c6a-dd19-dfe1-8541-c1af183be134@tekno-soft.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: linux-netdev <netdev@vger.kernel.org>,
        For users of Fedora <fedora-list@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li153-180.members.linode.com ([109.74.206.180]:35344 "EHLO
        mail.tekno-soft.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758957AbcJRIMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 04:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'm having a problem  with a Dell PowerEdge R530 running a Fedora 24 with kernel 4.7.7-200.fc24.x86_64
that is showing RX dropped packet on all the onboard BCM5720 4x1Gbits interfaces.
I've done several tests replacing cables and switches as well as disabling all rx offload
features but the problem still there.

Can anyone help here?

Thanks in advance,
Roberto Fichera.

[root@server ~]# ifconfig eno1
eno1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.10.1.11  netmask 255.255.255.0  broadcast 10.10.1.255
        inet6 fe80::931b:276f:74db:943  prefixlen 64  scopeid 0x20<link>
        ether 18:66:da:5c:e9:81  txqueuelen 3000  (Ethernet)
        RX packets 566596  bytes 84798649 (80.8 MiB)
        RX errors 0  dropped 9274  overruns 0  frame 0
        TX packets 518318  bytes 208948763 (199.2 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 18

root@server ~]# ethtool -i eno1
driver: tg3
version: 3.137
firmware-version: FFV20.2.17 bc 5720-v1.39
expansion-rom-version:
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

[root@server ~]# ethtool eno1
Settings for eno1:
    Supported ports: [ TP ]
    Supported link modes:   10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Half 1000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Half 1000baseT/Full
    Advertised pause frame use: Symmetric
    Advertised auto-negotiation: Yes
    Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                         100baseT/Half 100baseT/Full
                                         1000baseT/Full
    Link partner advertised pause frame use: No
    Link partner advertised auto-negotiation: Yes
    Speed: 1000Mb/s
    Duplex: Full
    Port: Twisted Pair
    PHYAD: 1
    Transceiver: internal
    Auto-negotiation: on
    MDI-X: off
    Supports Wake-on: g
    Wake-on: d
    Current message level: 0x000000ff (255)
                   drv probe link timer ifdown ifup rx_err tx_err
    Link detected: yes

02:00.0 Ethernet controller: Broadcom Limited NetXtreme BCM5720 Gigabit Ethernet PCIe
    Subsystem: Dell Device 0639
    Flags: bus master, fast devsel, latency 0, IRQ 18, NUMA node 0
    Memory at 91a30000 (64-bit, prefetchable) [size=64K]
    Memory at 91a40000 (64-bit, prefetchable) [size=64K]
    Memory at 91a50000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at 91f00000 [disabled] [size=256K]
    Capabilities: [48] Power Management version 3
    Capabilities: [50] Vital Product Data
    Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
    Capabilities: [a0] MSI-X: Enable+ Count=17 Masked-
    Capabilities: [ac] Express Endpoint, MSI 00
    Capabilities: [100] Advanced Error Reporting
    Capabilities: [13c] Device Serial Number 00-00-18-66-da-5c-e9-81
    Capabilities: [150] Power Budgeting <?>
    Capabilities: [160] Virtual Channel
    Kernel driver in use: tg3
    Kernel modules: tg3

02:00.1 Ethernet controller: Broadcom Limited NetXtreme BCM5720 Gigabit Ethernet PCIe
    Subsystem: Dell Device 0639
    Flags: bus master, fast devsel, latency 0, IRQ 19, NUMA node 0
    Memory at 91a00000 (64-bit, prefetchable) [size=64K]
    Memory at 91a10000 (64-bit, prefetchable) [size=64K]
    Memory at 91a20000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at 91f40000 [disabled] [size=256K]
    Capabilities: [48] Power Management version 3
    Capabilities: [50] Vital Product Data
    Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
    Capabilities: [a0] MSI-X: Enable+ Count=17 Masked-
    Capabilities: [ac] Express Endpoint, MSI 00
    Capabilities: [100] Advanced Error Reporting
    Capabilities: [13c] Device Serial Number 00-00-18-66-da-5c-e9-82
    Capabilities: [150] Power Budgeting <?>
    Capabilities: [160] Virtual Channel
    Kernel driver in use: tg3
    Kernel modules: tg3

03:00.0 Ethernet controller: Broadcom Limited NetXtreme BCM5720 Gigabit Ethernet PCIe
    Subsystem: Dell Device 0639
    Flags: bus master, fast devsel, latency 0, IRQ 19, NUMA node 0
    Memory at 91b30000 (64-bit, prefetchable) [size=64K]
    Memory at 91b40000 (64-bit, prefetchable) [size=64K]
    Memory at 91b50000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at 92000000 [disabled] [size=256K]
    Capabilities: [48] Power Management version 3
    Capabilities: [50] Vital Product Data
    Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
    Capabilities: [a0] MSI-X: Enable+ Count=17 Masked-
    Capabilities: [ac] Express Endpoint, MSI 00
    Capabilities: [100] Advanced Error Reporting
    Capabilities: [13c] Device Serial Number 00-00-18-66-da-5c-e9-83
    Capabilities: [150] Power Budgeting <?>
    Capabilities: [160] Virtual Channel
    Kernel driver in use: tg3
    Kernel modules: tg3

03:00.1 Ethernet controller: Broadcom Limited NetXtreme BCM5720 Gigabit Ethernet PCIe
    Subsystem: Dell Device 0639
    Flags: bus master, fast devsel, latency 0, IRQ 16, NUMA node 0
    Memory at 91b00000 (64-bit, prefetchable) [size=64K]
    Memory at 91b10000 (64-bit, prefetchable) [size=64K]
    Memory at 91b20000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at 92040000 [disabled] [size=256K]
    Capabilities: [48] Power Management version 3
    Capabilities: [50] Vital Product Data
    Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
    Capabilities: [a0] MSI-X: Enable+ Count=17 Masked-
    Capabilities: [ac] Express Endpoint, MSI 00
    Capabilities: [100] Advanced Error Reporting
    Capabilities: [13c] Device Serial Number 00-00-18-66-da-5c-e9-84
    Capabilities: [150] Power Budgeting <?>
    Capabilities: [160] Virtual Channel
    Kernel driver in use: tg3
    Kernel modules: tg3

[root@server ~]# cat /proc/interrupts
            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       CPU8      
CPU9       CPU10      CPU11      CPU12      CPU13      CPU14      CPU15     
   0:        150          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-IO-APIC    2-edge      timer
   8:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-IO-APIC    8-edge      rtc0
   9:         52          0          0          0          0          0          0          0         67         
0          0          0          0          0          0          0  IR-IO-APIC    9-fasteoi   acpi
  10:        246          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-IO-APIC   10-edge      ipmi_si
  18:         34          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-IO-APIC   18-fasteoi   ehci_hcd:usb1, ehci_hcd:usb2
  25:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 16384-edge      PCIe PME
  26:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 32768-edge      PCIe PME
  27:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 36864-edge      PCIe PME
  28:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 49152-edge      PCIe PME
  29:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 458752-edge      PCIe PME
  30:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 460800-edge      PCIe PME
  31:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 462848-edge      PCIe PME
  32:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 464896-edge      PCIe PME
  33:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 466944-edge      PCIe PME
  34:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 286720-edge      ahci[0000:00:11.4]
  35:         73          0          0       7744          0       4555          0          0          0         
0          0       2510       7578          0        825          0  IR-PCI-MSI 512000-edge      ahci[0000:00:1f.2]
  36:       3663          0          0          0          0       2883          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 327680-edge      xhci_hcd
  38:       2842          0          0          0       3964       1082          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 524288-edge      megasas
  39:          0       1191          0      84886      22401          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 524289-edge      megasas
  40:          0          0      21035          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 524290-edge      megasas
  41:          0     103285          0       3229          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 524291-edge      megasas
  42:          0          0          0       7870       2855       1772          0          0       4877         
0          0       4426       2373      18702          0          0  IR-PCI-MSI 524292-edge      megasas
  43:          0          0          0          0          0       2602          0          0          0         
0          0          0          0          0          0      34475  IR-PCI-MSI 524293-edge      megasas
  44:          0          0          0          0          0          0       2475          0          0         
0          0          0          0          0      84085          0  IR-PCI-MSI 524294-edge      megasas
  45:          0          0          0       6712       1227          0          0       2600          0         
0          0        978       8650      26936          0          0  IR-PCI-MSI 524295-edge      megasas
  46:          0          0          0       2051          0          0          0          0        287         
0          0        140      15289        157          0          0  IR-PCI-MSI 524296-edge      megasas
  47:          0          0          0          0          0          0          0          0          0       
321          0      96926          0          0          0          0  IR-PCI-MSI 524297-edge      megasas
  48:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  DMAR-MSI    0-edge      dmar0
  49:          0          0          0          0          0          0          0          0          0         
0        633          0          0          0          0          0  IR-PCI-MSI 524298-edge      megasas
  50:          0          0          0          0          0          0          0          0          0    
116952          0        139          0          0          0          0  IR-PCI-MSI 524299-edge      megasas
  51:          0          0          0          0          0          0          0          0       4479         
0          0          0       9880          0          0          0  IR-PCI-MSI 524300-edge      megasas
  52:          0          0          0          0          0          0          0      20108          0         
0          0          0          0        127          0          0  IR-PCI-MSI 524301-edge      megasas
  53:          0          0          0          0          0          0      84765          0          0         
0          0          0          0          0        280          0  IR-PCI-MSI 524302-edge      megasas
  54:          0          0          0      12840        722      51632          0          0          0         
0          0      16374        625          0          0         84  IR-PCI-MSI 524303-edge      megasas
  56:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 65536-edge      ioat-msix
  58:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 67584-edge      ioat-msix
  59:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 69632-edge      ioat-msix
  60:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 71680-edge      ioat-msix
  61:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 73728-edge      ioat-msix
  62:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 75776-edge      ioat-msix
  63:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 77824-edge      ioat-msix
  64:          2          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 79872-edge      ioat-msix
  65:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1574912-edge      eno4-tx-0
  66:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1574913-edge      eno4-rx-1
  67:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1574914-edge      eno4-rx-2
  68:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1574915-edge      eno4-rx-3
  69:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1574916-edge      eno4-rx-4
  70:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1572864-edge      eno3-tx-0
  71:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1572865-edge      eno3-rx-1
  72:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1572866-edge      eno3-rx-2
  73:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1572867-edge      eno3-rx-3
  74:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1572868-edge      eno3-rx-4
  75:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1050624-edge      eno2-tx-0
  76:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1050625-edge      eno2-rx-1
  77:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1050626-edge      eno2-rx-2
  78:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1050627-edge      eno2-rx-3
  79:          1          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1050628-edge      eno2-rx-4
  80:         27          0          0     237076     152591          0          0          0          0         
0          0          0          0          0          0          0  IR-PCI-MSI 1048576-edge      eno1-tx-0
  81:         27          0          0       4412      17854      60369          0          0          0         
0          0          0          0          0       5260          0  IR-PCI-MSI 1048577-edge      eno1-rx-1
  82:         13          0        147          0          0          0          0          0          0         
0          0          0          0     281274          0          0  IR-PCI-MSI 1048578-edge      eno1-rx-2
  83:          1         30          0          0       3997          0          0          0          0         
0          0      15092      24149          0          0          0  IR-PCI-MSI 1048579-edge      eno1-rx-3
  84:         12          0          0          0          0          0          0          0      62250         
0          0          0          0          0          0          0  IR-PCI-MSI 1048580-edge      eno1-rx-4
 NMI:       1131       1088       1038       1235       1079       1110       1047       1168        132       
419        182        423        181        157        296        268   Non-maskable interrupts
 LOC:    6159157    9652456    7667907   12679976    8318814    9250168    9793903    8433998     855179   11849165    
560772   11980808    3036730    2068369    7644596    6501494   Local timer interrupts
 SPU:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Spurious interrupts
 PMI:       1131       1088       1038       1235       1079       1110       1047       1168        132       
419        182        423        181        157        296        268   Performance monitoring interrupts
 IWI:       1134       1088       1038       1236       1079       1110       1047       1168        132       
419        182        423        181        157        296        268   IRQ work interrupts
 RTR:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   APIC ICR read retries
 RES:    2627838     898345    1648111    1092940    1643644    1664029    1207350    1499096      22322      28230     
32662      23121      20965      14704      37382      19706   Rescheduling interrupts
 CAL:      80329      77363      73116      76848      85910      85560      83319      81882       2341      
2533       2592       2622       2535       2534       2451       2178   Function call interrupts
 TLB:        245        114        368        120        104        373       1615       2165         51      
2118        292         80         35         22         51         35   TLB shootdowns
 TRM:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Threshold APIC interrupts
 DFR:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Deferred Error APIC interrupts
 MCE:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Machine check exceptions
 MCP:        159        159        159        159        159        159        159        159        159       
159        159        159        159        159        159        159   Machine check polls
 ERR:        139
 MIS:          0
 PIN:     300005     295650     348415     290934     274430     260562     232418     294068       7160       3286     
40264       1178      11093       5205       8358       3100   Posted-interrupt notification event
 PIW:          0          0          0          0          0          0          0          0          0         
0          0          0          0          0          0          0   Posted-interrupt wakeup event
