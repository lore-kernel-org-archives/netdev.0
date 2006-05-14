From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6548] New: MPPE Encrypt Decrypt module bug.
Date: Sun, 14 May 2006 05:10:15 -0700
Message-ID: <20060514051015.4b51ec35.akpm@osdl.org>
References: <200605141151.k4EBpsGI021236@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	James Cameron <james.cameron@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21221 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751411AbWENMNs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 08:13:48 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200605141151.k4EBpsGI021236@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=3D6548

I cc'ed the developers.  Please use reply-to-all henceforth on this bug=
 and
don't make updates via the bugzilla web interface, thanks.


>            Summary: MPPE Encrypt Decrypt module bug.
>     Kernel Version: 2.6.16.16
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: ffbi@mail.ru
>=20
>=20
> Most recent kernel where this bug did not occur: none
> Distribution:
> Hardware Environment:
>=20
> cat /proc/cpuinfo
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 8
> model name      : Celeron (Coppermine)
> stepping        : 3
> cpu MHz         : 855.153
> cache size      : 128 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 2
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca=
 cmov pat=20
> pse36 mmx fxsr sse
> bogomips        : 1712.02
>=20
>=20
> cat /proc/iomem
> 00000000-0009ffff : System RAM
> 000a0000-000bffff : Video RAM area
> 000c0000-000cbfff : Video ROM
> 000f0000-000fffff : System ROM
> 00100000-2ffebfff : System RAM
>   00100000-003190ce : Kernel code
>   003190cf-003d518b : Kernel data
> 2ffec000-2ffeefff : ACPI Tables
> 2ffef000-2fffefff : reserved
> 2ffff000-2fffffff : ACPI Non-volatile Storage
> 40000000-4000ffff : 0000:00:0b.0
> d6000000-d60003ff : 0000:00:0b.0
>   d6000000-d60003ff : @
>                        &R;e=A0i=A6u*PAa?
> d6800000-d68000ff : 0000:00:0a.0
>   d6800000-d68000ff : 8139too
> d7000000-d7dfffff : PCI Bus #01
>   d7000000-d700ffff : 0000:01:00.0
>     d7000000-d700ffff : radeonfb mmio
> d7f00000-e3ffffff : PCI Bus #01
>   d7fe0000-d7ffffff : 0000:01:00.0
>   d8000000-dfffffff : 0000:01:00.0
>     d8000000-dfffffff : radeonfb framebuffer
> e4000000-e7ffffff : 0000:00:00.0
> ffff0000-ffffffff : reserved
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> cat /proc/ioports
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-006f : keyboard
> 0070-0077 : rtc
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : ide1
> 01f0-01f7 : ide0
> 02f8-02ff : serial
> 0376-0376 : ide1
> 0378-037a : parport0
> 03c0-03df : vga+
> 03f6-03f6 : ide0
> 03f8-03ff : serial
> 0cf8-0cff : PCI conf1
> 9400-94ff : 0000:00:0b.0
>   9400-94ff : @
>                &ie=A0R;=A6iu*PAa?
> 9800-98ff : 0000:00:0a.0
>   9800-98ff : 8139too
> a000-a003 : 0000:00:04.5
> a400-a403 : 0000:00:04.5
> a800-a8ff : 0000:00:04.5
> b000-b01f : 0000:00:04.3
> b400-b41f : 0000:00:04.2
> b800-b80f : 0000:00:04.1
>   b800-b807 : ide0
>   b808-b80f : ide1
> d000-dfff : PCI Bus #01
>   d800-d8ff : 0000:01:00.0
> e400-e4ff : 0000:00:04.4
>   e400-e47f : motherboard
>     e400-e403 : PM1a_EVT_BLK
>     e404-e405 : PM1a_CNT_BLK
>     e408-e40b : PM_TMR
>     e410-e415 : ACPI CPU throttle
>     e420-e423 : GPE0_BLK
> e800-e80f : 0000:00:04.4
>   e800-e80f : motherboard
>     e800-e80f : pnp 00:02
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> lspci -vvv
> 00:00.0 Host bridge: VIA Technologies, Inc. VT82C693A/694x [Apollo PR=
O133x]=20
> (rev c4)
> 	Subsystem: ASUSTeK Computer Inc.: Unknown device 8020
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort+ >SERR- <PERR+
> 	Latency: 0
> 	Region 0: Memory at e4000000 (32-bit, prefetchable) [size=3D64M]
> 	Capabilities: [a0] AGP version 2.0
> 		Status: RQ=3D32 Iso- ArqSz=3D0 Cal=3D0 SBA+ ITACoh- GART64- HTrans-=
=20
> 64bit- FW- AGP3- Rate=3Dx1,x2,x4
> 		Command: RQ=3D1 ArqSz=3D0 Cal=3D0 SBA- AGP- GART64- 64bit- FW-=20
> Rate=3D<none>
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT82C598/694x [Apollo MVP3=
/Pro133x=20
> AGP] (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort+ >SERR- <PERR-
> 	Latency: 0
> 	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
> 	I/O behind bridge: 0000d000-0000dfff
> 	Memory behind bridge: d7000000-d7dfffff
> 	Prefetchable memory behind bridge: d7f00000-e3ffffff
> 	Secondary status: 66Mhz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TA=
bort-
>  <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
> 	Capabilities: [80] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:04.0 ISA bridge: VIA Technologies, Inc. VT82C686 [Apollo Super Sou=
th] (rev=20
> 22)
> 	Subsystem: ASUSTeK Computer Inc.: Unknown device 8020
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 0
>=20
> 00:04.1 IDE interface: VIA Technologies, Inc.=20
> VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 10) (pro=
g-if 8a=20
> [Master SecP PriP])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32
> 	Region 4: I/O ports at b800 [size=3D16]
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:04.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1=
=20
> Controller (rev 10) (prog-if 00 [UHCI])
> 	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, Cache Line Size 08
> 	Interrupt: pin D routed to IRQ 5
> 	Region 4: I/O ports at b400 [size=3D32]
> 	Capabilities: [80] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:04.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1=
=20
> Controller (rev 10) (prog-if 00 [UHCI])
> 	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32, Cache Line Size 08
> 	Interrupt: pin D routed to IRQ 5
> 	Region 4: I/O ports at b000 [size=3D32]
> 	Capabilities: [80] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:04.4 Host bridge: VIA Technologies, Inc. VT82C686 [Apollo Super AC=
PI] (rev=20
> 30)
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Interrupt: pin ? routed to IRQ 9
> 	Capabilities: [68] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:04.5 Multimedia audio controller: VIA Technologies, Inc. VT82C686 =
AC97=20
> Audio Controller (rev 20)
> 	Subsystem: ASUSTeK Computer Inc.: Unknown device 11d4
> 	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Interrupt: pin C routed to IRQ 12
> 	Region 0: I/O ports at a800 [size=3D256]
> 	Region 1: I/O ports at a400 [size=3D4]
> 	Region 2: I/O ports at a000 [size=3D4]
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-
> 8139/8139C/8139C+ (rev 10)
> 	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (8000ns min, 16000ns max)
> 	Interrupt: pin A routed to IRQ 12
> 	Region 0: I/O ports at 9800 [size=3D256]
> 	Region 1: Memory at d6800000 (32-bit, non-prefetchable) [size=3D256]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0-
> ,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 00:0b.0 Ethernet controller: MYSON Technology Inc SURECOM EP-320X-S 1=
00/10M=20
> Ethernet PCI Adapter
> 	Subsystem: Surecom Technology: Unknown device 1320
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=20
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (8000ns min, 16000ns max), Cache Line Size 08
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: I/O ports at 9400 [size=3D256]
> 	Region 1: Memory at d6000000 (32-bit, non-prefetchable) [size=3D1K]
> 	[virtual] Expansion ROM at 40000000 [disabled] [size=3D64K]
> 	Capabilities: [88] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D375mA PME(D0-,D1+,D2-
> ,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 01:00.0 VGA compatible controller: ATI Technologies Inc Radeon RV100 =
QY=20
> [Radeon 7000/VE] (prog-if 00 [VGA])
> 	Subsystem: Palit Microsystems Inc.: Unknown device 5159
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=20
> Stepping+ SERR- FastB2B-
> 	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 64 (2000ns min), Cache Line Size 08
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at d8000000 (32-bit, prefetchable) [size=3D128M]
> 	Region 1: I/O ports at d800 [size=3D256]
> 	Region 2: Memory at d7000000 (32-bit, non-prefetchable) [size=3D64K]
> 	Expansion ROM at d7fe0000 [disabled] [size=3D128K]
> 	Capabilities: [58] AGP version 2.0
> 		Status: RQ=3D48 Iso- ArqSz=3D0 Cal=3D0 SBA+ ITACoh- GART64- HTrans-=
=20
> 64bit- FW- AGP3- Rate=3Dx1,x2,x4
> 		Command: RQ=3D1 ArqSz=3D0 Cal=3D0 SBA+ AGP- GART64- 64bit- FW-=20
> Rate=3D<none>
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-
> ,D3hot-,D3cold-)
> 		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
>=20
>=20
>=20
> Software Environment:Linux version 2.6.15.6  Fedora Core 3
>=20
> env
> HOSTNAME=3Dstdafx.net
> TERM=3Dlinux
> SHELL=3D/bin/bash
> HISTSIZE=3D1000
> USER=3Droot
> LS_COLORS=3Dno=3D00:fi=3D00:di=3D01;34:ln=3D01;36:pi=3D40;33:so=3D01;=
35:bd=3D40;33;01:cd=3D40;33;
> 01:or=3D01;05;37;41:mi=3D01;05;37;41:ex=3D01;32:*.cmd=3D01;32:*.exe=3D=
01;32:*.com=3D01;32:*
> .btm=3D01;32:*.bat=3D01;32:*.sh=3D01;32:*.csh=3D01;32:*.tar=3D01;31:*=
=2Etgz=3D01;31:*.arj=3D01;
> 31:*.taz=3D01;31:*.lzh=3D01;31:*.zip=3D01;31:*.z=3D01;31:*.Z=3D01;31:=
*.gz=3D01;31:*.bz2=3D01;
> 31:*.bz=3D01;31:*.tz=3D01;31:*.rpm=3D01;31:*.cpio=3D01;31:*.jpg=3D01;=
35:*.gif=3D01;35:*.bmp
> =3D01;35:*.xbm=3D01;35:*.xpm=3D01;35:*.png=3D01;35:*.tif=3D01;35:
> CXXFLAGS=3D-O3 -funroll-loops -ffast-math -malign-double -mcpu=3Dpent=
iumpro -
> march=3Dpentiumpro -fomit-frame-pointer -fno-exceptions
> MC_TMPDIR=3D/tmp/mc-root
> PATH=3D/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/loca=
l/bin:/sbin:
> /bin:/usr/sbin:/usr/bin:/usr/X11R6/bin:/root/bin
> MAIL=3D/var/spool/mail/root
> PWD=3D/usr/local/src/linux-2.6.16.16
> INPUTRC=3D/etc/inputrc
> LANG=3Den_US.UTF-8
> HISTCONTROL=3Dignorespace
> HOME=3D/root
> SHLVL=3D2
> CFLAGS=3D-O3 -funroll-loops -ffast-math -malign-double -mcpu=3Dpentiu=
mpro -
> march=3Dpentiumpro -fomit-frame-pointer -fno-exceptions
> MC_SID=3D3607
> LOGNAME=3Droot
> LESSOPEN=3D|/usr/bin/lesspipe.sh %s
> G_BROKEN_FILENAMES=3D1
> OLDPWD=3D/usr/local/src/linux-2.6.15.6
> _=3D/bin/env
>=20
>=20
>=20
> Problem Description:
>=20
> MPPE doesnt work correctly with any VPN daemons (such pptpd)=20
> when requesting some URL's such=20
> ya.ru or microsoft.com
>=20
>=20
> Steps to reproduce: download pptpd at http://www.poptop.org/ or any o=
ther VPN=20
> daemon that supports MPPE
>=20
> in /etc/ppp/options.pptpd turn MPPE encryption ON
> require-mppe-128
> or=20
> #require-mppe-40
>=20
> Connect to VPN and try goto over vpn : www.ya.ru or microsoft.com (an=
d try to=20
> use windows update)
>=20
> Explorer freeze while timeout not reach
>=20
> without MPPE option this site works fine.=20
>  I think that it is a bug in the Encrypt Decrypt data To/FROM MPPE
>=20
> P.S Try connect to ya.ru in telnet and type GET /=20
> when mppe enabled
>=20
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
