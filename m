From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Tue, 20 Nov 2012 21:24:01 +0800
Message-ID: <50AB8471.7080607@oracle.com>
References: <509B5038.8090304@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com> <50A30656.6090508@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com> <50A43828.6000702@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com> <50A9C5CC.1030300@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/20/12 16:59, Dave, Tushar N wrote:
> Have you power off the system completely after modifying eeprom? If not please do so.

seems not works for me, would you please help to check what is wrong of my operations?

Original eeprom dump:

# ethtool -e eth3 | head -8
Offset		Values
------		------
0x0000		00 15 17 16 ee 9a 24 05 ff ff a2 50 ff ff ff ff 
0x0010		57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1 
0x0020		08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01 
0x0030		f6 6c b0 37 a6 07 03 84 83 07 00 00 03 c3 02 06 
                            ^^^^^
0x0040		08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

# lspci -s 0000:52:00.1 -vvv
52:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
<--snip-->
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
                        ^^^^^^^^^^^^^^^^^^^^^
<--snip-->

# ethtool eth3
Settings for eth3:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: off
	Supports Wake-on: d
	Wake-on: d
	Current message level: 0x00000007 (7)
	Link detected: yes

# ethtool -E eth3 magic 0x10a48086 offset 0x34 value 0xa7
# ethtool -e eth3 | head -8
Offset		Values
------		------
0x0000		00 15 17 16 ee 9a 24 05 ff ff a2 50 ff ff ff ff 
0x0010		57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1 
0x0020		08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01 
0x0030		f6 6c b0 37 a7 07 03 84 83 07 00 00 03 c3 02 06 
                            ^^^^^ <== a6 --> a7
0x0040		08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

# reboot

# ethtool -e eth3 | head -8
Offset		Values
------		------
0x0000		00 15 17 16 ee 9a 24 05 ff ff a2 50 ff ff ff ff 
0x0010		57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1 
0x0020		08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01 
0x0030		f6 6c b0 37 a7 07 03 84 83 07 00 00 03 c3 02 06 
0x0040		08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

# lspci -s 0000:52:00.1 -vvv
52:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
<--snip-->
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
                        ^^^^^^^^^^^^^^^^^^^^^
		DevSta:	CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 <4us, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
<--snip-->

#  ethtool -E eth3 magic 0x10a48086 offset 0x35 value 0x17

# ethtool -e eth3 | head -8
Offset		Values
------		------
0x0000		00 15 17 16 ee 9a 24 05 ff ff a2 50 ff ff ff ff 
0x0010		57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1 
0x0020		08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01 
0x0030		f6 6c b0 37 a6 17 03 84 83 07 00 00 03 c3 02 06 
                            ^^^^^<== 07 -> 17
0x0040		08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

# reboot

# ethtool -e eth3 | head -8
Offset		Values
------		------
0x0000		00 15 17 16 ee 9a 24 05 ff ff a2 50 ff ff ff ff 
0x0010		57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1 
0x0020		08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01 
0x0030		f6 6c b0 37 a6 17 03 84 83 07 00 00 03 c3 02 06 
                            ^^^^^<== 07 -> 17
0x0040		08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

# lspci -s 0000:52:00.1 -vvv
52:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
<--snip-->
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
                        ^^^^^^^^^^^^^^^^^^^^^
		DevSta:	CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 <4us, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
<--snip-->

Thanks,
Joe
