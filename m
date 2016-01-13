From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: cxgb3 Chelsio S310 tx drops and latency
Date: Wed, 13 Jan 2016 11:08:33 +0200
Message-ID: <6f526b0e78afba5db1b39d70d6e39821@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>,
	Santosh Raspatur <santosh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59370 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbcAMJPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 04:15:50 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 266C1481C86
	for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 11:08:37 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am trying to use Chelsio S310 on haproxy balancers and noticed 
following problems:

1)Latency on load 2.5+ Gbps is going in spikes 10ms+. Comparing with 
other vendors who is going to 7-8Gbps without problems.
2)I see a lot of drops in qdisc queues, while comparing with other 
vendors without drops on higher loads.

I suspect it might be or problem of card or drivers, because i am doing 
tests with similar cards from other vendor on same setup.
CPU resources are fine, i am monitoring them with with mpstat -P ALL, 
and cpufreq set to performance (always max freq on CPU).

Kernel 4.4 vanilla

HTTPS-VISP ~ # ethtool -i eth0
driver: cxgb3
version: 1.1.5-ko
firmware-version: T 7.12.0 TP 1.1.0
expansion-rom-version:
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: no
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

Here is more details about my setup:

As far as i see i am having 2.5GT/s x8 PCI-Express established, i 
checked and tried perftune.sh, it made no difference.

05:00.0 Ethernet controller: Chelsio Communications Inc S310-CR 10GbE 
Single Port Adapter
         Subsystem: Chelsio Communications Inc Device 0001
         Physical Slot: 785
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 0
         Region 0: Memory at 92800000 (64-bit, non-prefetchable) 
[size=4K]
         Region 2: Memory at 92000000 (64-bit, non-prefetchable) 
[size=8M]
         Region 4: Memory at 92801000 (64-bit, non-prefetchable) 
[size=4K]
         Expansion ROM at 92880000 [disabled] [size=512K]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold-)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [48] MSI: Enable- Count=1/32 Maskable- 64bit+
                 Address: 0000000000000000  Data: 0000
         Capabilities: [58] Express (v2) Endpoint, MSI 00
                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L0s 
<64ns, L1 <1us
                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ 
Unsupported-
                         RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 256 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- 
TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s L1, 
Exit Latency L0s unlimited, L1 unlimited
                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
                 DevCap2: Completion Timeout: Range ABC, TimeoutDis-, 
LTR-, OBFF Not Supported
                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, 
LTR-, OBFF Disabled
                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- 
SpeedDis-
                          Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
                          Compliance De-emphasis: -6dB
                 LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
                          EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
         Capabilities: [94] Vital Product Data
                 Unknown small resource type 00, will not decode more.
         Capabilities: [9c] MSI-X: Enable+ Count=32 Masked-
                 Vector table: BAR=4 offset=00000000
                 PBA: BAR=4 offset=00000800
         Capabilities: [100 v1] Device Serial Number 
00-00-00-01-00-00-00-01
         Capabilities: [300 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt+ 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UESvrt: DLP+ SDES+ TLP+ FCP+ CmpltTO+ CmpltAbrt+ 
UnxCmplt+ RxOF+ MalfTLP+ ECRC+ UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ 
ChkEn-
         Kernel driver in use: cxgb3

With uptime just 10 hours, over lowest load time:

BALANCER ~ # tc -s -d qdisc
qdisc mq 0: dev eth0 root
  Sent 3445096608552 bytes 2777441550 pkt (dropped 6509380, overlimits 0 
requeues 1156)
  backlog 0b 0p requeues 1156
qdisc pfifo_fast 0: dev eth0 parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 428721781866 bytes 880919921 pkt (dropped 1403007, overlimits 0 
requeues 243)
  backlog 0b 0p requeues 243
qdisc pfifo_fast 0: dev eth0 parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 429526790584 bytes 879237430 pkt (dropped 560836, overlimits 0 
requeues 102)
  backlog 0b 0p requeues 102
qdisc pfifo_fast 0: dev eth0 parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 427233606632 bytes 882026985 pkt (dropped 1255127, overlimits 0 
requeues 221)
  backlog 0b 0p requeues 221
qdisc pfifo_fast 0: dev eth0 parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 429138959430 bytes 882420516 pkt (dropped 914917, overlimits 0 
requeues 164)
  backlog 0b 0p requeues 164
qdisc pfifo_fast 0: dev eth0 parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 435498527047 bytes 888437887 pkt (dropped 325962, overlimits 0 
requeues 60)
  backlog 0b 0p requeues 60
qdisc pfifo_fast 0: dev eth0 parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 427458674980 bytes 881585256 pkt (dropped 610681, overlimits 0 
requeues 113)
  backlog 0b 0p requeues 113
qdisc pfifo_fast 0: dev eth0 parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 435164189156 bytes 891730352 pkt (dropped 891579, overlimits 0 
requeues 156)
  backlog 0b 0p requeues 156
qdisc pfifo_fast 0: dev eth0 parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 
1 1 1 1 1 1 1 1
  Sent 432354080111 bytes 886050500 pkt (dropped 547271, overlimits 0 
requeues 97)
