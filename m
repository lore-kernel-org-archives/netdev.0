From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom 5461S
Date: Thu, 07 May 2015 12:57:46 -0400
Message-ID: <554B998A.9010001@cumulusnetworks.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com> <CAJ+vNU0NP4Lmc2=y_j9NN0AxK1pUTPs8rSNJ78SCp4CBQ6wtMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	gospo@cumulusnetworks.com, shm@cumulusnetworks.com,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:35531 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbEGQ5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:57:48 -0400
Received: by qcbgu10 with SMTP id gu10so24244675qcb.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 09:57:48 -0700 (PDT)
In-Reply-To: <CAJ+vNU0NP4Lmc2=y_j9NN0AxK1pUTPs8rSNJ78SCp4CBQ6wtMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/15 12:18 PM, Tim Harvey wrote:
> On Fri, Apr 17, 2015 at 1:23 PM, Jonathan Toppins
> <jtoppins@cumulusnetworks.com> wrote:
>> From: Alan Liebthal <alanl@cumulusnetworks.com>
>>
>> The Quanta LY8 Ethernet management port uses a Broadcom 5461S chip for
>> the PHY layer. This adds support for this PHY to the Intel igb driver.
>>
>> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
>> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>> ---
> <snip>
>> --- a/drivers/net/ethernet/intel/igb/e1000_phy.c
>> +++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
>> @@ -148,6 +148,13 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
>>           * Control register.  The MAC will take care of interfacing with the
>>           * PHY to retrieve the desired data.
>>           */
>> +       if (phy->type == e1000_phy_bcm5461s) {
>> +               mdic = rd32(E1000_MDICNFG);
>> +               mdic &= ~E1000_MDICNFG_PHY_MASK;
>> +               mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
>> +               wr32(E1000_MDICNFG, mdic);
>> +       }
>> +
>>          mdic = ((offset << E1000_MDIC_REG_SHIFT) |
>>                  (phy->addr << E1000_MDIC_PHY_SHIFT) |
>>                  (E1000_MDIC_OP_READ));
>> @@ -204,6 +211,13 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
>>           * Control register.  The MAC will take care of interfacing with the
>>           * PHY to retrieve the desired data.
>>           */
>> +       if (phy->type == e1000_phy_bcm5461s) {
>> +               mdic = rd32(E1000_MDICNFG);
>> +               mdic &= ~E1000_MDICNFG_PHY_MASK;
>> +               mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
>> +               wr32(E1000_MDICNFG, mdic);
>> +       }
>> +
>>          mdic = (((u32)data) |
>>                  (offset << E1000_MDIC_REG_SHIFT) |
>>                  (phy->addr << E1000_MDIC_PHY_SHIFT) |
>> @@ -2509,3 +2523,68 @@ static s32 igb_set_master_slave_mode(struct e1000_hw *hw)
>>
>>          return hw->phy.ops.write_reg(hw, PHY_1000T_CTRL, phy_data);
>>   }
>
> Jonathan,
>
> Is this bcm5461s attached to an i210/i211? These changes look a lot
> like some changes I'm trying to upstream to add support for i210/i211
> which require the phy address in the MDICNFG register. If this is the
> case, then I think the right approach is to check for hw->mac.type =
> e1000_i210/e1000_i211 and I can submit my patch for review.
>
> Regards,
>
> Tim
>

Hi Tim,

The MAC in question are the ones integrated with Intel's Atom processor, 
I don't recall the series off hand, output of lspci and /proc/cpuinfo 
below. If you think your change may apply to this controller as well I 
would be more than happy to apply your change and test.

Thanks,
-Jon

Supplementary Information.

Processor info (8 processors total):
root@qct-ly8-01:~# uname -a
Linux qct-ly8-01 3.2.60-1+deb7u1+cl2.5+1 #3.2.60-1+deb7u1+cl2.5+1 SMP 
Mon Apr 13 23:18:31 PDT 2015 x86_64 GNU/Linux

root@qct-ly8-01:~# cat /proc/cpuinfo  | grep "processor" | wc -l
8

root@qct-ly8-01:~# cat /proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 77
model name	: Intel(R) Atom(TM) CPU  C2758  @ 2.40GHz
stepping	: 8
microcode	: 0x11d
cpu MHz		: 2400.191
cache size	: 1024 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 8
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov 
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx 
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 movbe popcnt tsc_deadline_timer aes 
rdrand lahf_lm 3dnowprefetch arat epb dtherm tpr_shadow vnmi 
flexpriority ept vpid smep erms
bogomips	: 4800.38
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

...trimmed...


The PCI info for the controller:
root@qct-ly8-01:~# lspci -vvx -s 00:14.0
00:14.0 Ethernet controller: Intel Corporation Device 1f41 (rev 03)
	Subsystem: Intel Corporation Device 1f41
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at dff60000 (64-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 1000 [size=32]
	Region 4: Memory at dff84000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
		Address: 0000000000000000  Data: 0000
		Masking: 00000000  Pending: 00000000
	Capabilities: [70] MSI-X: Enable+ Count=10 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00002000
	Capabilities: [a0] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 
<64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- 
BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, 
Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- 
ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, 
EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Kernel driver in use: igb
00: 86 80 41 1f 07 04 10 00 03 00 00 02 10 00 00 00
10: 04 00 f6 df 00 00 00 00 01 10 00 00 00 00 00 00
20: 04 40 f8 df 00 00 00 00 00 00 00 00 86 80 41 1f
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
