From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: tg3: not checking dma errors?
Date: Wed, 02 Dec 2009 19:03:47 +0100
Message-ID: <1259777028.16397.4.camel@johannes.local>
References: <1259762466.32171.159.camel@johannes.local>
	 <20091202171359.GB32112@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-b0xR1+BmRMqNzxaoziPi"
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60081 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbZLBSE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 13:04:26 -0500
In-Reply-To: <20091202171359.GB32112@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-b0xR1+BmRMqNzxaoziPi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-12-02 at 09:13 -0800, Matt Carlson wrote:

> Yes.  I submitted a patch to the net-next-2.6 tree addressing this exact
> problem.  It will appear in the 2.6.33 kernel.  The patch is appended at
> the bottom of this email.

Cool, thanks, I'll stick it into my tree and see what happens.

> What kind of trouble are you seeing?  What device are you working with?

I have a dual-port device, see lspci info below. The device is in a
machine with 6.5GiB memory, and large disks. Now I rsync a lot of data
over gigabit (but I think I never set up jumbo frames) to the disk, say
50GiB data. During that, eventually the memory will fill with cached
filesystem data.

If I allow that to happen, the machine will eventually crash, and tg3
shows up in the stack trace -- but I can't see all of it on the display.
I can work around it by periodically telling the kernel to drop
filesystem caches so it never fills the entire memory with cached data.

johannes

0001:05:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5780 Gi=
gabit Ethernet (rev 03)
	Subsystem: Apple Computer Inc. Device 0085
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 16 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 34
	Region 0: Memory at fa530000 (64-bit, non-prefetchable) [size=3D64K]
	Region 2: Memory at fa520000 (64-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO- RBC=3D512 OST=3D1
		Status: Dev=3D05:04.0 64bit+ 133MHz+ SCD- USC- DC=3Dsimple DMMRBC=3D2048 =
DMOST=3D1 DMCRS=3D16 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable+ DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetXtreme Gigabit Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95780
			[EC] Engineering changes: 106679-15
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 34 65 34
			[RV] Reserved: checksum bad, 28 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: XYZ01234567
			[RW] Read-write area: 107 byte(s) free
		End
	Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
		Address: 00000000fee00000  Data: 000d
	Kernel driver in use: tg3

0001:05:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5780 Gi=
gabit Ethernet (rev 03)
	Subsystem: Apple Computer Inc. Device 0085
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 16 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 67
	Region 0: Memory at fa510000 (64-bit, non-prefetchable) [size=3D64K]
	Region 2: Memory at fa500000 (64-bit, non-prefetchable) [size=3D64K]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO+ RBC=3D512 OST=3D1
		Status: Dev=3D05:04.1 64bit+ 133MHz+ SCD- USC- DC=3Dsimple DMMRBC=3D2048 =
DMOST=3D1 DMCRS=3D16 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetXtreme Gigabit Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95780
			[EC] Engineering changes: 106679-15
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 34 65 34
			[RV] Reserved: checksum bad, 28 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: XYZ01234567
			[RW] Read-write area: 107 byte(s) free
		End
	Capabilities: [58] MSI: Enable- Count=3D1/8 Maskable- 64bit+
		Address: 820170100a07bcb4  Data: 6548
	Kernel driver in use: tg3


--=-b0xR1+BmRMqNzxaoziPi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLFqv9AAoJEODzc/N7+QmaLXUP/3OXhfuaiDAmj50FEesajsJ5
7YuYTh7mxf/IuCzd6MqjY22zL2gqj+D09V3wZwFHcO7TIgSrcptGT90RNB/vm6RH
dKvhGifMcgh834nr8sIny6CFtDuVDLp/HdzY32meY6ZrI88XUwxrV4EnIgYyA+Z3
gX431jGSATQORBMt5Ji85TOg7XW75RnRpKGUQxUBCvl1BE3P+GXVeu3Z0c9PYW1k
F5p5eSiq83xpYprgh3y2kB8fEjIm66sgGgZwbyPXBqqS12Kchrn3VoWLctPpSxuK
VhrrizWU21CK9YreZjxczyfRkU2b3GiZjYfhs8bcfMJulWivBeyMAsC/hHxyxnY5
2hjb+FuytIvnVvqQM0YJc1fgBw2MO2UdCZRDBRsxrW3QKITY1HFQbd7FSprClasp
VA8s21Q1uBOTut8Xu0NInPMExcvlvA9Hm/gzQMzedZFgLrMIuoSEVUBEG4WtLco6
QKDlC+DyFGMxlhp/TTBI87RcEBVbe8//ZztbqS95bs7SX71AZ1306wndrUuOK9dM
7JiEJ6udMlqQ8hO8ducWqWEBrhGkODqMXe9Q1raj0wt0NDKKGgafOWfPgCkfeJUQ
mAxcKYFnAkG24Y7xPQjzhxnPHAm8ZJKTGlpHSJ5mpzMvncdb9OnXPuFFCasXJ/op
hi6/jJjaXRE7GnQ+nkb3
=nkIr
-----END PGP SIGNATURE-----

--=-b0xR1+BmRMqNzxaoziPi--

