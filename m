From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: r8169: hard freezes on TX
Date: Sun, 20 May 2007 15:20:30 +0200
Message-ID: <200705201520.36672.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2096043.qFVYWEbOtv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:47296 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754934AbXEUHbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 03:31:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2096043.qFVYWEbOtv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

I often see freezes when I do much outgoing transfer. I have never seen thi=
s=20
happening on incoming transfers. When this happens the system locks up hard=
,=20
I don't see anything in the log. Since this is my laptop I have trouble=20
debugging it: there is no serial console and debugging this via netconsole=
=20
doesn't look like a good idea.

When I say "much outgoing transfer" this means "several megabytes". If I co=
py=20
out 30 MB I almost everytime get this. I usually copy that much only at hom=
e=20
when I feed my gentoo server. That host only has a 10 MBit connection.=20
Nevertheless I've also seen that on different hosts using different files o=
n=20
different protocols (ftp, scp, smb).

This is the output of lspci for my NIC:

05:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E PCI=20
Express Fast Ethernet controller (rev 01)
        Subsystem: Toshiba America Info Systems Unknown device ff00
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: I/O ports at 4000 [size=3D256]
        Region 2: Memory at da000000 (64-bit, non-prefetchable) [size=3D4K]
        [virtual] Expansion ROM at d4000000 [disabled] [size=3D64K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [48] Vital Product Data
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+=20
Queue=3D0/1 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [60] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTa=
g+
                Device: Latency L0s <1us, L1 unlimited
                Device: AtnBtn+ AtnInd+ PwrInd+
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
                Link: Latency L0s unlimited, L1 unlimited
                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [84] Vendor Specific Information
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [12c] Virtual Channel
        Capabilities: [148] Device Serial Number xx-xx-xx-xx-xx-xx-xx-xx
        Capabilities: [154] Power Budgeting

Hm, is there a reason why we don't use MSI here?

Ah, one thing is missing: I've not tested it with current kernel, latest I=
=20
tested was 2.6.21-rc7. But I've seen this on many previous version, althoug=
h=20
I thought it became better some versions ago. I wont bet on it, it might ju=
st=20
have been luck.

Eike

--nextPart2096043.qFVYWEbOtv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGUEskXKSJPmm5/E4RAteKAJwN00UXIeN3T6G9HiZUDXqHjLULlwCgouBt
CJT0L8czhskErz0cVp+CZko=
=HD5E
-----END PGP SIGNATURE-----

--nextPart2096043.qFVYWEbOtv--
