From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue
 timed out" when skb has huge linear buffer
Date: Wed, 5 Feb 2014 20:23:56 +0000
Message-ID: <52F29DDC.7010908@citrix.com>
References: <52EAA31B.1090606@schaman.hu>	
	<1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	
	<52EBA51E.808@citrix.com>
	<1391543271.4804.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Carolyn, Tushar,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, Cooper <andrew.cooper3@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Peter, Andrew
To: Michael Chan <mchan@broadcom.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1391543271.4804.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 04/02/14 19:47, Michael Chan wrote:
> On Fri, 2014-01-31 at 14:29 +0100, Zoltan Kiss wrote:
>> [ 5417.275472] WARNING: at net/sched/sch_generic.c:255
>> dev_watchdog+0x156/0x1f0()
>> [ 5417.275474] NETDEV WATCHDOG: eth1 (bnx2): transmit queue 2 timed out
>
> The dump shows an internal IRQ pending on MSIX vector 2 which matches
> the the queue number that is timing out.  I don't know what happened to
> the MSIX and why the driver is not seeing it.  Do you see an IRQ error
> message from the kernel a few seconds before the tx timeout message?

I haven't seen any IRQ related error message. Note, this is on Xen 
4.3.1. Now I have new results with a reworked version of the patch, 
unfortunately it still has this issue. Here is a bnx2 dump, lspci output 
and some Xen debug output (MSI and interrupt bindings, I have more if 
needed).

[82099.288743] bnx2 0000:02:00.0 eth0: <--- start FTQ dump --->
[82099.288767] bnx2 0000:02:00.0 eth0: RV2P_PFTQ_CTL 00010002
[82099.288779] bnx2 0000:02:00.0 eth0: RV2P_TFTQ_CTL 00020000
[82099.288790] bnx2 0000:02:00.0 eth0: RV2P_MFTQ_CTL 00004000
[82099.288801] bnx2 0000:02:00.0 eth0: TBDR_FTQ_CTL 00404002
[82099.288812] bnx2 0000:02:00.0 eth0: TDMA_FTQ_CTL 00010002
[82099.288823] bnx2 0000:02:00.0 eth0: TXP_FTQ_CTL 00810002
[82099.288834] bnx2 0000:02:00.0 eth0: TXP_FTQ_CTL 01010002
[82099.288845] bnx2 0000:02:00.0 eth0: TPAT_FTQ_CTL 00010002
[82099.288878] bnx2 0000:02:00.0 eth0: RXP_CFTQ_CTL 00008000
[82099.288889] bnx2 0000:02:00.0 eth0: RXP_FTQ_CTL 00100002
[82099.288899] bnx2 0000:02:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
[82099.288911] bnx2 0000:02:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
[82099.288923] bnx2 0000:02:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
[82099.288934] bnx2 0000:02:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
[82099.288944] bnx2 0000:02:00.0 eth0: CPU states:
[82099.288960] bnx2 0000:02:00.0 eth0: 045000 mode b84c state 80005000 
evt_mask 500 pc 8001284 pc 8000cb8 instr 35690100
[82099.288984] bnx2 0000:02:00.0 eth0: 085000 mode b84c state 80001000 
evt_mask 500 pc 8000a58 pc 8000a4c instr 38420001
[82099.289007] bnx2 0000:02:00.0 eth0: 0c5000 mode b84c state 80001000 
evt_mask 500 pc 8004c14 pc 8004c14 instr 32050003
[82099.289030] bnx2 0000:02:00.0 eth0: 105000 mode b8cc state 80000000 
evt_mask 500 pc 8000a94 pc 8000a94 instr 8c420020
[82099.289063] bnx2 0000:02:00.0 eth0: 145000 mode b880 state 80000000 
evt_mask 500 pc 800d244 pc 8008aac instr 8c460000
[82099.289087] bnx2 0000:02:00.0 eth0: 185000 mode b8cc state 80000000 
evt_mask 500 pc 8000c6c pc 8000c6c instr 3c056000
[82099.289103] bnx2 0000:02:00.0 eth0: <--- end FTQ dump --->
[82099.289112] bnx2 0000:02:00.0 eth0: <--- start TBDC dump --->
[82099.289124] bnx2 0000:02:00.0 eth0: TBDC free cnt: 31
[82099.289133] bnx2 0000:02:00.0 eth0: LINE     CID  BIDX   CMD  VALIDS
[82099.289148] bnx2 0000:02:00.0 eth0: 00    000800  a3b8   00    [1]
[82099.289163] bnx2 0000:02:00.0 eth0: 01    001100  1b58   00    [0]
[82099.289178] bnx2 0000:02:00.0 eth0: 02    000800  a390   00    [0]
[82099.289193] bnx2 0000:02:00.0 eth0: 03    000800  a370   00    [0]
[82099.289217] bnx2 0000:02:00.0 eth0: 04    000800  a378   00    [0]
[82099.289232] bnx2 0000:02:00.0 eth0: 05    000800  a388   00    [0]
[82099.289247] bnx2 0000:02:00.0 eth0: 06    000800  a398   00    [0]
[82099.289262] bnx2 0000:02:00.0 eth0: 07    000800  a3a8   00    [0]
[82099.289277] bnx2 0000:02:00.0 eth0: 08    000800  a3b0   00    [0]
[82099.289291] bnx2 0000:02:00.0 eth0: 09    000800  a3b8   00    [0]
[82099.289306] bnx2 0000:02:00.0 eth0: 0a    000800  8c10   00    [0]
[82099.289321] bnx2 0000:02:00.0 eth0: 0b    000800  eaf0   00    [0]
[82099.289336] bnx2 0000:02:00.0 eth0: 0c    000800  eaf8   00    [0]
[82099.289351] bnx2 0000:02:00.0 eth0: 0d    001100  5e60   00    [0]
[82099.289365] bnx2 0000:02:00.0 eth0: 0e    001100  5e68   00    [0]
[82099.289380] bnx2 0000:02:00.0 eth0: 0f    001100  5e70   00    [0]
[82099.289395] bnx2 0000:02:00.0 eth0: 10    001100  5e88   00    [0]
[82099.289410] bnx2 0000:02:00.0 eth0: 11    001100  5e90   00    [0]
[82099.289425] bnx2 0000:02:00.0 eth0: 12    001100  5ee8   00    [0]
[82099.289440] bnx2 0000:02:00.0 eth0: 13    001100  5ef8   00    [0]
[82099.289454] bnx2 0000:02:00.0 eth0: 14    001100  5e00   00    [0]
[82099.289470] bnx2 0000:02:00.0 eth0: 15    001100  5a20   00    [0]
[82099.289485] bnx2 0000:02:00.0 eth0: 16    001100  59a8   00    [0]
[82099.289499] bnx2 0000:02:00.0 eth0: 17    001100  59b0   00    [0]
[82099.289514] bnx2 0000:02:00.0 eth0: 18    001100  59b8   00    [0]
[82099.289529] bnx2 0000:02:00.0 eth0: 19    001100  5a28   00    [0]
[82099.289544] bnx2 0000:02:00.0 eth0: 1a    001100  5a30   00    [0]
[82099.289559] bnx2 0000:02:00.0 eth0: 1b    000800  8c58   00    [0]
[82099.289573] bnx2 0000:02:00.0 eth0: 1c    000800  8c60   00    [0]
[82099.289588] bnx2 0000:02:00.0 eth0: 1d    055e80  dca8   fb    [0]
[82099.289603] bnx2 0000:02:00.0 eth0: 1e    1cf780  f7b8   af    [0]
[82099.289618] bnx2 0000:02:00.0 eth0: 1f    1dff80  efe0   bf    [0]
[82099.289629] bnx2 0000:02:00.0 eth0: <--- end TBDC dump --->
[82099.289644] bnx2 0000:02:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100406]
[82099.289661] bnx2 0000:02:00.0 eth0: DEBUG: PCI_PM[19002008] 
PCI_MISC_CFG[92000088]
[82099.289676] bnx2 0000:02:00.0 eth0: DEBUG: EMAC_TX_STATUS[0000000e] 
EMAC_RX_STATUS[00000000]
[82099.289691] bnx2 0000:02:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
[82099.289703] bnx2 0000:02:00.0 eth0: DEBUG: 
HC_STATS_INTERRUPT_STATUS[01ee0000]
[82099.289716] bnx2 0000:02:00.0 eth0: DEBUG: PBA[00000000]
[82099.289726] bnx2 0000:02:00.0 eth0: <--- start MCP states dump --->
[82099.289739] bnx2 0000:02:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] 
MCP_STATE_P1[0003610e]
[82099.289756] bnx2 0000:02:00.0 eth0: DEBUG: MCP mode[0000b880] 
state[80008000] evt_mask[00000500]
[82099.289773] bnx2 0000:02:00.0 eth0: DEBUG: pc[0800b110] pc[0800aff0] 
instr[afbf0048]
[82099.289787] bnx2 0000:02:00.0 eth0: DEBUG: shmem states:
[82099.289800] bnx2 0000:02:00.0 eth0: DEBUG: drv_mb[0d000005] 
fw_mb[00000005] link_status[0010026f]
[82099.289820] bnx2 0000:02:00.0 eth0: DEBUG: 
dev_info_signature[44564903] reset_type[01005254]
[82099.289842] bnx2 0000:02:00.0 eth0: DEBUG: 000001c0: 01005254 
42530088 0003610e 00000000
[82099.289860] bnx2 0000:02:00.0 eth0: DEBUG: 000003cc: 44444444 
44444444 44444444 00000a28
[82099.289879] bnx2 0000:02:00.0 eth0: DEBUG: 000003dc: 000cffff 
00000000 ffff0000 00000000
[82099.289897] bnx2 0000:02:00.0 eth0: DEBUG: 000003ec: 00000000 
00000000 00000000 00000000
[82099.289911] bnx2 0000:02:00.0 eth0: DEBUG: 0x3fc[0000ffff]
[82099.289921] bnx2 0000:02:00.0 eth0: <--- end MCP states dump --->

lspci -s 02:00.0 -vv
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709S 
Gigabit Ethernet (rev 20)
	Subsystem: Dell Device 045f
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 32
	Region 0: Memory at c8000000 (64-bit, non-prefetchable) [size=32M]
	Expansion ROM at c6000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetXtreme II Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95709C0
			[EC] Engineering changes: 220197-2
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 30 32 38
			[V0] Vendor specific: 6.2.14
			[RV] Reserved: checksum good, 22 byte(s) reserved
		End
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
		Vector table: BAR=0 offset=0000c000
		PBA: BAR=0 offset=0000e000
	Capabilities: [ac] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr+ NoSnoop+
			MaxPayload 256 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 5GT/s, Width x4, ASPM L0s L1, Latency L0 <2us, 
L1 <2us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- 
BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not 
Supported
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF 
Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- 
ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, 
EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Device Serial Number b8-ac-6f-ff-fe-b4-17-20
	Capabilities: [110 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- 
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt+ UnxCmplt+ RxOF- 
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP+ FCP+ CmpltTO+ CmpltAbrt- UnxCmplt- RxOF+ 
MalfTLP+ ECRC+ UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [150 v1] Power Budgeting <?>
	Capabilities: [160 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Kernel driver in use: bnx2
	Kernel modules: bnx2



(XEN) [2014-02-05 20:15:20] MSI information:
(XEN) [2014-02-05 20:15:20]  IOMMU   56 vec=28  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/?
(XEN) [2014-02-05 20:15:20]  MSI     57 vec=d0  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI     58 vec=d8  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI     59 vec=21  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI     60 vec=29  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI     61 vec=31  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI     62 vec=39  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   63 vec=62  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   64 vec=d7  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   65 vec=ba  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   66 vec=92  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   67 vec=3a  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   68 vec=b8  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   69 vec=2a  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X   70 vec=33  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   71 vec=c2  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   72 vec=9a  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   73 vec=d0  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   74 vec=da  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   75 vec=b2  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X   76 vec=6b  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   77 vec=68  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   78 vec=b2  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   79 vec=53  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   80 vec=78  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   81 vec=4b  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X   82 vec=a7  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   83 vec=63  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   84 vec=6f  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   85 vec=5b  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   86 vec=99  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   87 vec=a3  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X   88 vec=73  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   89 vec=58  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   90 vec=aa  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   91 vec=38  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   92 vec=8f  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   93 vec=3c  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X   94 vec=3b  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   95 vec=ca  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   96 vec=a8  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   97 vec=32  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   98 vec=23  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   99 vec=94  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X  100 vec=7b  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  101 vec=60  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  102 vec=a2  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  103 vec=4b  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  104 vec=a1  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  105 vec=2d  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:20]  MSI-X  106 vec=43  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  107 vec=d2  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  108 vec=61  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  109 vec=21  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  110 vec=2b  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X  111 vec=85  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
(XEN) [2014-02-05 20:15:22] Guest interrupt information:
(XEN) [2014-02-05 20:15:22]    IRQ:   0 affinity:00000001 vec:f0 
type=IO-APIC-edge    status=00000000 timer_interrupt+0/0x18f
(XEN) [2014-02-05 20:15:22]    IRQ:   1 affinity:00000001 vec:30 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:   3 affinity:00000001 vec:38 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:   4 affinity:00000001 vec:f1 
type=IO-APIC-edge    status=00000000 ns16550_interrupt+0/0x73
(XEN) [2014-02-05 20:15:22]    IRQ:   5 affinity:00000001 vec:40 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:   6 affinity:00000001 vec:48 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:   7 affinity:00000001 vec:50 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:   8 affinity:00000001 vec:58 
type=IO-APIC-edge    status=00000030 in-flight=0 domain-list=0:  8(---),
(XEN) [2014-02-05 20:15:22]    IRQ:   9 affinity:00000001 vec:60 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0:  9(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  10 affinity:00000001 vec:68 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  11 affinity:00000001 vec:70 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  12 affinity:00000001 vec:78 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  13 affinity:0000ffff vec:88 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  14 affinity:00000001 vec:90 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  15 affinity:00000001 vec:98 
type=IO-APIC-edge    status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  17 affinity:00000010 vec:59 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0: 17(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  18 affinity:00000010 vec:61 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0: 18(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  19 affinity:00000010 vec:b9 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0: 19(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  20 affinity:00000010 vec:71 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0: 20(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  21 affinity:00000400 vec:6d 
type=IO-APIC-level   status=00000030 in-flight=0 domain-list=0: 21(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  32 affinity:0000ffff vec:79 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  33 affinity:0000ffff vec:89 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  36 affinity:0000ffff vec:41 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  38 affinity:0000ffff vec:99 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  39 affinity:0000ffff vec:a9 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  42 affinity:0000ffff vec:81 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  43 affinity:0000ffff vec:91 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  45 affinity:0000ffff vec:a1 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  47 affinity:0000ffff vec:b1 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  53 affinity:0000ffff vec:a0 
type=IO-APIC-level   status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  56 affinity:0000ffff vec:28 
type=DMA_MSI         status=00000000 iommu_page_fault+0/0x12
(XEN) [2014-02-05 20:15:22]    IRQ:  57 affinity:00000001 vec:d0 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:311(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  58 affinity:00000001 vec:d8 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:310(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  59 affinity:00000001 vec:21 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:309(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  60 affinity:00000001 vec:29 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:308(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  61 affinity:00000001 vec:31 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:307(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  62 affinity:00000001 vec:39 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:306(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  63 affinity:00000004 vec:62 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:305(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  64 affinity:00000004 vec:d7 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:304(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  65 affinity:00000100 vec:ba 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:303(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  66 affinity:00000004 vec:92 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:302(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  67 affinity:00000002 vec:3a 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:301(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  68 affinity:00000004 vec:b8 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:300(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  69 affinity:00000001 vec:2a 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  70 affinity:00000002 vec:33 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:298(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  71 affinity:00000100 vec:c2 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:297(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  72 affinity:00000004 vec:9a 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:296(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  73 affinity:00000004 vec:d0 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:295(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  74 affinity:00000004 vec:da 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:294(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  75 affinity:00000001 vec:b2 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  76 affinity:00000002 vec:6b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:292(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  77 affinity:00000004 vec:68 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:291(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  78 affinity:00000004 vec:b2 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:290(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  79 affinity:00000002 vec:53 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:289(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  80 affinity:00000004 vec:78 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:288(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  81 affinity:00000001 vec:4b 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  82 affinity:00000004 vec:a7 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:286(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  83 affinity:00000004 vec:63 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:285(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  84 affinity:00000100 vec:6f 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:284(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  85 affinity:00000004 vec:5b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:283(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  86 affinity:00000004 vec:99 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:282(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  87 affinity:00000001 vec:a3 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  88 affinity:00000100 vec:73 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:280(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  89 affinity:00000004 vec:58 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:279(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  90 affinity:00000100 vec:aa 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:278(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  91 affinity:00000004 vec:38 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:277(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  92 affinity:00000004 vec:8f 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:276(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  93 affinity:00000001 vec:3c 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ:  94 affinity:00000002 vec:3b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:274(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  95 affinity:00000004 vec:ca 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:273(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  96 affinity:00000004 vec:a8 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:272(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  97 affinity:00000004 vec:32 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:271(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  98 affinity:00000100 vec:23 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:270(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  99 affinity:00000001 vec:94 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ: 100 affinity:00000002 vec:7b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:268(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 101 affinity:00000004 vec:60 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:267(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 102 affinity:00000004 vec:a2 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:266(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 103 affinity:00000002 vec:4b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:265(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 104 affinity:00000002 vec:a1 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:264(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 105 affinity:00000001 vec:2d 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22]    IRQ: 106 affinity:00000100 vec:43 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:262(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 107 affinity:00000004 vec:d2 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:261(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 108 affinity:00000100 vec:61 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:260(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 109 affinity:00000004 vec:21 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:259(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 110 affinity:00000100 vec:2b 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:258(---),
(XEN) [2014-02-05 20:15:22]    IRQ: 111 affinity:00000001 vec:85 
type=PCI-MSI/-X      status=00000002 mapped, unbound
(XEN) [2014-02-05 20:15:22] IO-APIC interrupt information:
(XEN) [2014-02-05 20:15:22]     IRQ  0 Vec240:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  2: vec=f0 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  1 Vec 48:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  1: vec=30 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  3 Vec 56:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  3: vec=38 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  4 Vec241:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  4: vec=f1 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  5 Vec 64:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  5: vec=40 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  6 Vec 72:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  6: vec=48 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  7 Vec 80:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  7: vec=50 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  8 Vec 88:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  8: vec=58 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ  9 Vec 96:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin  9: vec=60 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=L mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 10 Vec104:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 10: vec=68 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 11 Vec112:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 11: vec=70 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 12 Vec120:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 12: vec=78 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 13 Vec136:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 13: vec=88 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 14 Vec144:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 14: vec=90 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 15 Vec152:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 15: vec=98 
delivery=Fixed dest=P status=0 polarity=0 irr=0 trig=E mask=0 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 17 Vec 89:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 17: vec=59 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=0 dest_id:50
(XEN) [2014-02-05 20:15:22]     IRQ 18 Vec 97:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 18: vec=61 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=0 dest_id:50
(XEN) [2014-02-05 20:15:22]     IRQ 19 Vec185:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 19: vec=b9 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=0 dest_id:50
(XEN) [2014-02-05 20:15:22]     IRQ 20 Vec113:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 20: vec=71 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=0 dest_id:50
(XEN) [2014-02-05 20:15:22]     IRQ 21 Vec109:
(XEN) [2014-02-05 20:15:22]       Apic 0x00, Pin 21: vec=6d 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=0 dest_id:2
(XEN) [2014-02-05 20:15:22]     IRQ 32 Vec121:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin  0: vec=79 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 33 Vec137:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin  1: vec=89 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 36 Vec 65:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin  4: vec=41 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 38 Vec153:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin  6: vec=99 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 39 Vec169:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin  7: vec=a9 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 42 Vec129:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin 10: vec=81 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 43 Vec145:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin 11: vec=91 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 45 Vec161:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin 13: vec=a1 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 47 Vec177:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin 15: vec=b1 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32
(XEN) [2014-02-05 20:15:22]     IRQ 53 Vec160:
(XEN) [2014-02-05 20:15:22]       Apic 0x01, Pin 21: vec=a0 
delivery=Fixed dest=P status=0 polarity=1 irr=0 trig=L mask=1 dest_id:32


------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
