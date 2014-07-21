From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: Re: [linux-nics] Problem: 82574L device (e1000e
 driver): Reset adapter unexpectedly / transmit queue 0 timed out
Date: Mon, 21 Jul 2014 15:22:33 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD6533A4E9C@ORSMSX114.amr.corp.intel.com>
References: <CAJtEV7bERYgwtQv1zAvk+XzaywF6g7K-QqAq3VLErNU1YSgxYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Lifshitz <lifshitz@compulab.co.il>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	Grinberg <grinberg@compulab.co.il>,
	"Igor@isotope.jf.intel.com" <Igor@isotope.jf.intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: Andrew Cooks <acooks@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAJtEV7bERYgwtQv1zAvk+XzaywF6g7K-QqAq3VLErNU1YSgxYA@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Need more -v's in the lspci. Also, what is the OS, kernel version, and driver version?

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565

-----Original Message-----
From: linux-nics-bounces@isotope.jf.intel.com [mailto:linux-nics-bounces@isotope.jf.intel.com] On Behalf Of Andrew Cooks
Sent: Sunday, July 20, 2014 8:01 PM
To: netdev
Cc: Dmitry Lifshitz; Linux NICS; Igor@isotope.jf.intel.com; e1000-devel@lists.sf.net; Grinberg
Subject: [linux-nics] Problem: 82574L device (e1000e driver): Reset adapter unexpectedly / transmit queue 0 timed out

Hi

The 82574L device, using the e1000e driver, is unstable on the fit-MultiLAN (aka CompuLab MultiLAN)[1] that I'm using and I need some help to understand what's causing it.

The fit-MultiLAN has four 82574L devices[2]. On two different occasions I've seen a (different) device drop into an unusable state, while the rest of the 82574L devices continue to function normally.
I'm not sure how to describe the state exactly, but it's as if the adapter can no longer detect a link and disconnecting/reconnecting the cable doesn't recover it.

I don't think there is any transition to/from a lower power state involved, because this happens while the device is in use (shunting packets), but I'm not sure how to rule it out either.

I can get the device working again without a power cycle, by doing the following (though I admit I'm not sure whether each of these is really
needed):
# echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove
# echo 1 > /sys/bus/pci/rescan
# echo 1 > /sys/bus/pci/drivers_autoprobe # echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/reset

This problem occurs with versions 3.15.0 and 3.16.0-rc5. I haven't tested older versions in the current configuration.

Hopefully the information below will help pin it down.

Kernel log:
[18439.527157] ------------[ cut here ]------------ [18439.527177] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
dev_watchdog+0x266/0x270()
[18439.527182] NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0 timed out [18439.527185] Modules linked in: sch_cbq sch_netem nf_conntrack_ipv4
nf_defrag_ipv4 xt_conntrack nf_conntrack xt_LOG xt_comment xt_tcpudp iptable_filter ip_tables x_tables nfnetlink_queue nfnetlink_log nfnetlink arc4 rtl8723ae rtl_pci rtlwifi mac80211 cfg80211 rtl8723_common microcode sp5100_tco k10temp i2c_piix4 video hid_generic usbhid hid r8169 mii firmware_class ohci_pci ohci_hcd [18439.527231] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.16.0-rc5 #2 [18439.527235] Hardware name: CompuLab fit-PC3i/SBC fit-PC3i, BIOS
SBCFP3I_2.1.0.333_1 X64 11/26/2013
[18439.527238]  0000000000000009 ffff88014ec03db0 ffffffff8164c94d
ffff88014ec03df8
[18439.527244]  ffff88014ec03de8 ffffffff810479dd 0000000000000000
ffff880091aec000
[18439.527249]  0000000000000001 0000000000000000 ffff880091aec000
ffff88014ec03e48
[18439.527254] Call Trace:
[18439.527258]  <IRQ>  [<ffffffff8164c94d>] dump_stack+0x45/0x56 [18439.527271]  [<ffffffff810479dd>] warn_slowpath_common+0x7d/0xa0 [18439.527277]  [<ffffffff81047a4c>] warn_slowpath_fmt+0x4c/0x50 [18439.527283]  [<ffffffff8156c276>] dev_watchdog+0x266/0x270 [18439.527288]  [<ffffffff8156c010>] ? dev_graft_qdisc+0x80/0x80 [18439.527294]  [<ffffffff81053c86>] call_timer_fn+0x36/0x100 [18439.527298]  [<ffffffff8156c010>] ? dev_graft_qdisc+0x80/0x80 [18439.527303]  [<ffffffff81053f4c>] run_timer_softirq+0x1fc/0x2e0 [18439.527309]  [<ffffffff8104c97d>] __do_softirq+0xed/0x2d0 [18439.527315]  [<ffffffff8104cdcd>] irq_exit+0xcd/0xe0 [18439.527320]  [<ffffffff81655695>] smp_apic_timer_interrupt+0x45/0x60
[18439.527325]  [<ffffffff81653cfa>] apic_timer_interrupt+0x6a/0x70 [18439.527328]  <EOI>  [<ffffffff8100cb9c>] ? default_idle+0x1c/0xb0 [18439.527339]  [<ffffffff810aab93>] ? rcu_eqs_enter+0x63/0x90 [18439.527344]  [<ffffffff8100d44f>] arch_cpu_idle+0xf/0x20 [18439.527350]  [<ffffffff8108da15>] cpu_startup_entry+0x355/0x420 [18439.527355]  [<ffffffff8164ecdd>] ? __schedule+0x30d/0x780 [18439.527361]  [<ffffffff8163fb77>] rest_init+0x77/0x80 [18439.527367]  [<ffffffff81cf9fd4>] start_kernel+0x435/0x442 [18439.527372]  [<ffffffff81cf99a6>] ? set_init_arg+0x53/0x53 [18439.527378]  [<ffffffff81cf95ad>] x86_64_start_reservations+0x2a/0x2c
[18439.527383]  [<ffffffff81cf96a0>] x86_64_start_kernel+0xf1/0xf4 [18439.527386] ---[ end trace e1cdd13e14fbe306 ]--- [18439.527405] e1000e 0000:01:00.0 eth2: Reset adapter unexpectedly [18439.548497] br_v401: port 1(eth2_v401) entered disabled state [18439.548616] br_v402: port 1(eth2_v402) entered disabled state [18439.548703] br_v403: port 1(eth2_v403) entered disabled state [18439.548776] br_v404: port 1(eth2_v404) entered disabled state [18439.548849] br_v405: port 1(eth2_v405) entered disabled state [18439.548929] br_v406: port 1(eth2_v406) entered disabled state [18439.548997] br_v407: port 1(eth2_v407) entered disabled state [18439.549067] br_v487: port 1(eth2_v487) entered disabled state [18439.549144] br_v600: port 1(eth2_v600) entered disabled state [18439.549216] br_v602: port
  1(eth2_v602) entered disabled state [18439.549284] br_v603: port 1(eth2_v603) entered disabled state [18439.549362] br_v1010: port 1(eth2_v1010) entered disabled state [18439.767733] e1000e 0000:01:00.0 eth2: Timesync Tx Control register not set as expected


# lspci -vvnnk:
01:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit Network Connection [8086:10d3]
        Subsystem: Intel Corporation Device [8086:0000]
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 16
        Region 0: [virtual] Memory at c1900000 (32-bit,
non-prefetchable) [size=128K]
        Region 1: [virtual] Memory at c1800000 (32-bit,
non-prefetchable) [size=1M]
        Region 2: I/O ports at 7000 [size=32]
        Region 3: [virtual] Memory at c1920000 (32-bit,
non-prefetchable) [size=16K]
        [virtual] Expansion ROM at c1940000 [disabled] [size=256K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [a0] MSI-X: Enable- Count=5 Masked-
                Vector table: BAR=3 offset=00000000
                PBA: BAR=3 offset=00002000
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Device Serial Number 00-01-c0-ff-ff-12-8a-64
        Kernel driver in use: e1000e


# ethtool eth2
Settings for eth2:
Supported ports: [ TP ]
Supported link modes:   10baseT/Half 10baseT/Full
                       100baseT/Half 100baseT/Full
                       1000baseT/Full
Supported pause frame use: No
Supports auto-negotiation: Yes
Advertised link modes:  10baseT/Half 10baseT/Full
                       100baseT/Half 100baseT/Full
                       1000baseT/Full
Advertised pause frame use: No
Advertised auto-negotiation: Yes
Speed: Unknown!
Duplex: Unknown! (255)
Port: Twisted Pair
PHYAD: 1
Transceiver: internal
Auto-negotiation: on
MDI-X: Unknown (auto)
Supports Wake-on: pumbg
Wake-on: g
Current message level: 0x00000007 (7)
      drv probe link
Link detected: no


# ethtool -d eth2
MAC Registers
-------------
0x00000: CTRL (Device control register)  0xFFFFFFFF
      Endian mode (buffers):             big
      Link reset:                        reset
      Set link up:                       1
      Invert Loss-Of-Signal:             yes
      Receive flow control:              enabled
      Transmit flow control:             enabled
      VLAN mode:                         enabled
      Auto speed detect:                 enabled
      Speed select:                      not used
      Force speed:                       yes
      Force duplex:                      yes
0x00008: STATUS (Device status register) 0xFFFFFFFF
      Duplex:                            full
      Link up:                           link config
      TBI mode:                          enabled
      Link speed:                        not used
      Bus type:                          PCI-X
      Bus speed:                         133MHz
      Bus width:                         64-bit
0x00100: RCTL (Receive control register) 0xFFFFFFFF
      Receiver:                          enabled
      Store bad packets:                 enabled
      Unicast promiscuous:               enabled
      Multicast promiscuous:             enabled
      Long packet:                       enabled
      Descriptor minimum threshold size: reserved
      Broadcast accept mode:             accept
      VLAN filter:                       enabled
      Canonical form indicator:          enabled
      Discard pause frames:              ignored
      Pass MAC control frames:           pass
      Receive buffer size:               4096
0x02808: RDLEN (Receive desc length)     0xFFFFFFFF
0x02810: RDH   (Receive desc head)       0xFFFFFFFF
0x02818: RDT   (Receive desc tail)       0xFFFFFFFF
0x02820: RDTR  (Receive delay timer)     0xFFFFFFFF
0x00400: TCTL (Transmit ctrl register)   0xFFFFFFFF
      Transmitter:                       enabled
      Pad short packets:                 enabled
      Software XOFF Transmission:        enabled
      Re-transmit on late collision:     enabled
0x03808: TDLEN (Transmit desc length)    0xFFFFFFFF
0x03810: TDH   (Transmit desc head)      0xFFFFFFFF
0x03818: TDT   (Transmit desc tail)      0xFFFFFFFF
0x03820: TIDV  (Transmit delay timer)    0xFFFFFFFF
PHY type:                                unknown


# ethtool -t eth2

The test result is FAIL
The test extra info:
Register test  (offline) 40
Eeprom test    (offline) 2
Interrupt test (offline) 4
Loopback test  (offline) 0
Link test   (on/offline) 0

References:
1. http://www.fit-pc.com/web/solutions/multilan/
2. http://fit-pc.com/download/face-modules/documents/face-modules-hw-specifications.pdf
(FM-XTDE4U2/4 FACE Module, p36)

Any suggestions of help to pin down the problem would be much appreciated.

Thanks.

a.
_______________________________________________
Linux-nics mailing list
Linux-nics@intel.com

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
