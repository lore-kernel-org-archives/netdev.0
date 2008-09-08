From: "Victor Gallardo" <vgallardo@amcc.com>
Subject: RE: [PATCH] ibm_newemac: Add support for GPCS, SGMII and M88E1112PHY
Date: Sun, 7 Sep 2008 22:57:49 -0700
Message-ID: <0CA0A16855646F4FA96D25A158E299D602C8135D@SDCEXCHANGE01.ad.amcc.com>
References: <1220658734-13944-1-git-send-email-vgallardo@amcc.com>
	<1220833754.4879.228.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0967269263=="
Cc: linuxppc-dev@ozlabs.org, Feng Kan <fkan@amcc.com>, netdev@vger.kernel.org
To: <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============0967269263==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C91177.D3064E63"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C91177.D3064E63
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello Benjamin,
=20
On the 460EX/GT in SGMII mode, GPCS access is needed for communication =
with the internal SGMII SerDes. It is possible that there is still a =
PHY. So we need a way to access both addresses.
=20
For Example on the AMCC Arches Board.
=20
EMAC 0 has only a GPCS PHY (address 0xA)
EMAC 1 has M88E1112 PHY (address 0x0) and GPCS PHY (address 0xB)
EMAC 2 has M88E1112 PHY (address 0x1) and GPCS PHY (address 0xC)
=20
Regards,
=20
Victor Gallardo

________________________________

From: Benjamin Herrenschmidt [mailto:benh@kernel.crashing.org]
Sent: Sun 9/7/2008 5:29 PM
To: Victor Gallardo
Cc: linuxppc-dev@ozlabs.org; Feng Kan
Subject: Re: [PATCH] ibm_newemac: Add support for GPCS, SGMII and =
M88E1112PHY



On Fri, 2008-09-05 at 16:52 -0700, Victor Gallardo wrote:
> From: Victor Gallardo <vgallardo@amcc.com>
>
> This patch adds GPCS, SGMII and M88E1112 PHY support
> for the AMCC PPC460GT/EX processors.

So if I understand the patch correctly, either there is an *MII PHY in
which case phy_address is used, or there's a GPCS one and phy_address is
-1 and gpcs_address is used right ?

Why not instead always use phy_address, and have a flag indicating
whether it's an MII or GPCS PHY ? This would avoid the added
gpcs_read/write functions, among other things, and I believe would look
cleaner... Or am I missing something ?

Cheers,
Ben.





------_=_NextPart_001_01C91177.D3064E63
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<HTML dir=3Dltr><HEAD><TITLE>Re: [PATCH] ibm_newemac: Add support for =
GPCS, SGMII and M88E1112PHY</TITLE>=0A=
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Dunicode">=0A=
<META content=3D"MSHTML 6.00.2800.1589" name=3DGENERATOR></HEAD>=0A=
<BODY>=0A=
<DIV id=3DidOWAReplyText89008 dir=3Dltr>=0A=
<DIV dir=3Dltr><FONT face=3DArial color=3D#000000 size=3D2>=0A=
<DIV dir=3Dltr><FONT face=3DArial color=3D#000000 size=3D2>Hello =
Benjamin,</FONT></DIV>=0A=
<DIV dir=3Dltr><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>=0A=
<DIV dir=3Dltr><FONT face=3DArial size=3D2>On the 460EX/GT in SGMII =
mode, GPCS access is needed for communication with the internal SGMII =
SerDes. It is possible that there is still a PHY. So we need a way to =
access both addresses.</FONT></DIV>=0A=
<DIV dir=3Dltr>&nbsp;</DIV>=0A=
<DIV dir=3Dltr>For Example on the AMCC Arches Board.</DIV>=0A=
<DIV dir=3Dltr>&nbsp;</DIV>=0A=
<DIV dir=3Dltr>EMAC 0 has only a GPCS PHY (address 0xA)</DIV>=0A=
<DIV dir=3Dltr>EMAC 1 has M88E1112 PHY (address 0x0) and GPCS PHY =
(address 0xB)</DIV>=0A=
<DIV dir=3Dltr>EMAC 2 has M88E1112 PHY (address 0x1) and GPCS PHY =
(address 0xC)</DIV>=0A=
<DIV dir=3Dltr><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>=0A=
<DIV dir=3Dltr>Regards,</DIV>=0A=
<DIV dir=3Dltr>&nbsp;</DIV>=0A=
<DIV dir=3Dltr>Victor Gallardo</DIV></FONT></DIV></DIV>=0A=
<DIV dir=3Dltr><BR>=0A=
<HR tabIndex=3D-1>=0A=
<FONT face=3DTahoma size=3D2><B>From:</B> Benjamin Herrenschmidt =
[mailto:benh@kernel.crashing.org]<BR><B>Sent:</B> Sun 9/7/2008 5:29 =
PM<BR><B>To:</B> Victor Gallardo<BR><B>Cc:</B> linuxppc-dev@ozlabs.org; =
Feng Kan<BR><B>Subject:</B> Re: [PATCH] ibm_newemac: Add support for =
GPCS, SGMII and M88E1112PHY<BR></FONT><BR></DIV>=0A=
<DIV>=0A=
<P><FONT size=3D2>On Fri, 2008-09-05 at 16:52 -0700, Victor Gallardo =
wrote:<BR>&gt; From: Victor Gallardo =
&lt;vgallardo@amcc.com&gt;<BR>&gt;<BR>&gt; This patch adds GPCS, SGMII =
and M88E1112 PHY support<BR>&gt; for the AMCC PPC460GT/EX =
processors.<BR><BR>So if I understand the patch correctly, either there =
is an *MII PHY in<BR>which case phy_address is used, or there's a GPCS =
one and phy_address is<BR>-1 and gpcs_address is used right ?<BR><BR>Why =
not instead always use phy_address, and have a flag =
indicating<BR>whether it's an MII or GPCS PHY ? This would avoid the =
added<BR>gpcs_read/write functions, among other things, and I believe =
would look<BR>cleaner... Or am I missing something =
?<BR><BR>Cheers,<BR>Ben.<BR><BR><BR></FONT></P></DIV></BODY></HTML>
------_=_NextPart_001_01C91177.D3064E63--

--===============0967269263==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0967269263==--
