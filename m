From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [E1000-devel] 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
Date: Fri, 22 Oct 2010 14:01:36 +0300
Message-ID: <20101022140136.141634lkqh3y9b7k@hayate.sektori.org>
References: <20101014052242.GA8998@pcnci.linuxbox.cz>
	<EA929A9653AAE14F841771FB1DE5A1366027CEFF1C@rrsmsx501.amr.corp.intel.com>
	<20101020144640.GA3009@pcnci.linuxbox.cz>
	<20101020163659.GB3009@pcnci.linuxbox.cz>
	<20101021190208.GA7289@nik-comp.lan>
	<alpine.WNT.2.00.1010211207220.5208@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Nikola Ciprich" <extmaillist@linuxbox.cz>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"linux-net maillist" <linux-net@vger.kernel.org>,
	"e1000-devel list" <e1000-devel@lists.sourceforge.net>,
	"nikola.ciprich@linuxbox.cz" <nikola.ciprich@linuxbox.cz>,
	"Linux kernel list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.1010211207220.5208@jbrandeb-desk1.amr.corp.intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I seem to have same problem but with r8169 device:

  02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. =20
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
	Subsystem: ASUSTeK Computer Inc. Device 83a3
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =20
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =20
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 40
	Region 0: I/O ports at e800 [size=3D256]
	Region 2: Memory at f8fff000 (64-bit, prefetchable) [size=3D4K]
	Region 4: Memory at f8ff8000 (64-bit, prefetchable) [size=3D16K]
	Expansion ROM at febf0000 [disabled] [size=3D64K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,D1+,D2+,D3hot+=
,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ =20
Queue=3D0/0 Enable+
		Address: 00000000fee0100c  Data: 4161
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64=
us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 =20
<512ns, L1 <64us
			ClockPM+ Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- =20
BWMgmt- ABWMgmt-
	Capabilities: [ac] MSI-X: Enable- Mask- TabSize=3D4
		Vector table: BAR=3D4 offset=3D00000000
		PBA: BAR=3D4 offset=3D00000800
	Capabilities: [cc] Vital Product Data <?>
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [140] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
	Kernel driver in use: r8169
	Kernel modules: r8169

When I tried to boot, computer freezes at vlan_hwaccel_do_receive =20
(gpf), with computer completely frozen and not responding to sysrq. =20
With quick search I found this thread and figured problem must be in =20
shared hardware vlan acceleration code. So I disabled vlan hwaccel in =20
r8169 driver (CONFIG_R8169_VLAN=3Dn) and got computer booting ok.

Network is set up with two VLANs and two bridges:
  bridge name	bridge id		STP enabled	interfaces
  br0		8000.xxxxxxxxxxxx	no		dummy0
							dummy2
							dummy4
							dummy6
							eth0.0000
  wanbr0		8000.yyyyyyyyyyyy	no		dummy1
							dummy3
							eth0.0009

-Jussi

Quoting "Brandeburg, Jesse" <jesse.brandeburg@intel.com>:

>
> Adding netdev... beware the top post ordering in the thread.
>
> On Thu, 21 Oct 2010, Nikola Ciprich wrote:
>
>> Ok, here're the steps to reproduce the problem:
>>
>> ip link set up dev eth0
>> vconfig add eth0 10
>> ip link set up dev eth0.10
>> brctl addbr brtest
>> # to bylo ok, sund=C3=A1 to a=C5=BE:
>> brctl add brtest eth0.10
>>
>> last command causes panic in few seconds..
>>
>> Interesting thing is that it're reproducible only for eth0, not for
>> eth1 (both are onboard 80003ES2LAN)
>>
>> here's the lspci for those:
>> 06:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit =20
>> Ethernet Controller (Copper) (rev 01)
>> 	Subsystem: Super Micro Computer Inc Unknown device 0000
>> 	Flags: bus master, fast devsel, latency 0, IRQ 65
>> 	Memory at d8300000 (32-bit, non-prefetchable) [size=3D128K]
>> 	I/O ports at 3000 [size=3D32]
>> 	Capabilities: [c8] Power Management version 2
>> 	Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=3D0/0=
 Enable+
>> 	Capabilities: [e0] Express Endpoint IRQ 0
>> 	Capabilities: [100] Advanced Error Reporting
>> 	Capabilities: [140] Device Serial Number 5a-19-34-ff-ff-48-30-00
>>
>> 06:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit =20
>> Ethernet Controller (Copper) (rev 01)
>> 	Subsystem: Super Micro Computer Inc Unknown device 0000
>> 	Flags: bus master, fast devsel, latency 0, IRQ 66
>> 	Memory at d8320000 (32-bit, non-prefetchable) [size=3D128K]
>> 	I/O ports at 3020 [size=3D32]
>> 	Capabilities: [c8] Power Management version 2
>> 	Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=3D0/0=
 Enable+
>> 	Capabilities: [e0] Express Endpoint IRQ 0
>> 	Capabilities: [100] Advanced Error Reporting
>> 	Capabilities: [140] Device Serial Number 5a-19-34-ff-ff-48-30-00
>>
>> last but not least, I've done bisect and it leads to:
>> commit ae878ae280bea286ff2b1e1cb6e609dd8cb4501d
>> Author: Maciej =C5=BBenczykowski <maze@google.com>
>> Date:   Sun Oct 3 14:49:00 2010 -0700                               =
=20
>>                                                                     =
=20
>>                                                                     =
=20
>>                                net: Fix IPv6 PMTU disc. w/ =20
>> asymmetric routes
>>
>> doesn't seem to me to be related at all, but reverting really seems =
=20
>> to fix the problem for me..
>> I hope it helps..
>> with best regards
>> nik
>>
>>
>>
>> On Wed, Oct 20, 2010 at 06:36:59PM +0200, Nikola Ciprich wrote:
>> > so unfortunately I have to take back what I just wrote :(
>> > the problem still persists, it just seems to be more random
>> > so I'll try to separate the exact command that causes the panic..
>> > n.
>> >
>> > On Wed, Oct 20, 2010 at 04:46:40PM +0200, Nikola Ciprich wrote:
>> > > Hello Emil,
>> > >
>> > > I tried it now, I can still 100% reproduce with 2.6.36-rc7-git2,=
 but
>> > > with 2.6.36-rc8-git5 it works OK. So it certainly got fixed in =20
>> the meantime!
>> > > I'll therefore close the bug in BZ.
>> > >
>> > > have a nice day!
>> > >
>> > > best regards
>> > >
>> > > nik
>> > >
>> > >
>> > > On Fri, Oct 15, 2010 at 10:58:15AM -0600, Tantilov, Emil S wrote=
:
>> > > > >-----Original Message-----
>> > > > >From: Nikola Ciprich [mailto:extmaillist@linuxbox.cz]
>> > > > >Sent: Wednesday, October 13, 2010 10:23 PM
>> > > > >To: Linux kernel list; linux-net maillist; e1000-devel list
>> > > > >Cc: nikola.ciprich@linuxbox.cz
>> > > > >Subject: [E1000-devel] 2.6.36-rc7-git2 - panic/GPF: e1000e/vl=
ans?
>> > > > >
>> > > > >Hi,
>> > > > >when I try to boot 2.6.36-rc7-git2 on one of my machines, it =
=20
>> crashes while
>> > > > >setting up the network.
>> > > >
>> > > > Thanks for letting us know!
>> > > >
>> > > > >The setup is quite complex, with bonding, lots of vlans and 3=
 intel
>> > > > >adapters (system is quad x86_64)
>> > > >
>> > > > Could you provide more details about the exact setup and the =20
>> sequence of
>> > > > commands that lead to the crash? If you can narrow it down to =
=20
>> the actual
>> > > > command that caused the crash that would be very helpful.
>> > > >
>> > > > Also - are you testing from Linus or net-next tree? If you =20
>> are not using
>> > > > net-next, could you give it a try and see if you can =20
>> reproduce it there?
>> > > >
>> > > > >
>> > > > >snip of lspci:
>> > > > >06:00.0 Ethernet controller: Intel Corporation 80003ES2LAN =20
>> Gigabit Ethernet
>> > > > >Controller (Copper) (rev 01)
>> > > > >06:00.1 Ethernet controller: Intel Corporation 80003ES2LAN =20
>> Gigabit Ethernet
>> > > > >Controller (Copper) (rev 01)
>> > > > >09:00.0 Ethernet controller: Intel Corporation 82574L Gigabit=
 Network
>> > > > >Connection
>> > > >
>> > > > Could you provide the output of lspci -vvv and a kernel config=
?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
