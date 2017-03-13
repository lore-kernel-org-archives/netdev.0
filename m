From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: Legacy features in PCI Express devices
Date: Mon, 13 Mar 2017 10:24:53 -0700
Message-ID: <b26272ff-346a-9774-405f-f1238a89aa8b@gmail.com>
References: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        David Laight <david.laight@aculab.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Phuong Nguyen <phuong_nguyen@sigmadesigns.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Tim Harvey <tharvey@gateworks.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, linux-pci <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 09:10 AM, Mason wrote:
> Hello,
>
> There are two revisions of our PCI Express controller.
>
> Rev 1 did not support the following features:
>
>   1) legacy PCI interrupt delivery (INTx signals)
>   2) I/O address space
>
> Internally, someone stated that such missing support would prevent
> some PCIe cards from working with our controller.
>
> Are there really modern PCIe cards that require 1) and/or 2)
> to function?

It depends on your definition of "modern".  I have some JMicron AHCI 
SATA controllers that support legacy interrupts only.  These are cheap 
$20 PCIe devices I picked up at Fry's a couple of years ago.  Do they 
count as modern?

I/O address space is probably less important I would say.

David.

>
> Can someone provide examples of such cards, so that I may test them
> on both revisions?


[root@localhost ddaney]# lspci -s 0005:90:00.0 -vvv
0005:90:00.0 SATA controller: JMicron Technology Corp. JMB363 SATA/IDE 
Controller (rev 03) (prog-if 01 [AHCI 1.0])
	Subsystem: JMicron Technology Corp. JMB363 SATA/IDE Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 26
	NUMA node: 0
	Region 5: Memory at 899010010000 (32-bit, non-prefetchable) [size=8K]
	Expansion ROM at 899010000000 [disabled] [size=64K]
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Express (v1) Legacy Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s, Exit Latency L0s 
unlimited, L1 unlimited
			ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- 
BWMgmt- ABWMgmt-
	Kernel driver in use: ahci

[root@localhost ddaney]# lspci -s 0005:90:00.0 -vvv -n
0005:90:00.0 0106: 197b:2363 (rev 03) (prog-if 01 [AHCI 1.0])
	Subsystem: 197b:2363
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 26
	NUMA node: 0
	Region 5: Memory at 899010010000 (32-bit, non-prefetchable) [size=8K]
	Expansion ROM at 899010000000 [disabled] [size=64K]
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Express (v1) Legacy Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s, Exit Latency L0s 
unlimited, L1 unlimited
			ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- 
BWMgmt- ABWMgmt-
	Kernel driver in use: ahci



Look!  No MSI.

>
> I was told to check ath9k-based cards. Any other examples?
>
> Looking around, I came across this thread:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/418254.html
> "i.MX6 PCIe: Fix imx6_pcie_deassert_core_reset() polarity"
>
> IIUC, although some PCIe boards do support MSI, the driver might not
> put in the work to use that infrastructure, and instead reverts to
> legacy interrupts. (So it is a SW issue, in a sense.)
>
> Regards.
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
