From: "Joseph Chang" <joseph_chang@mail.davicom.com.tw>
Subject: RE: About the Davicom PHY in drivers/net/phy in Linux kernel
Date: Thu, 28 Oct 2010 15:59:55 +0800
Message-ID: <20101028075051.53C8E5F947@mail.davicom.com.tw>
References: <50FD90C65C53FB45BADEEBCD84FF07F2029CB176@ATCPCS06.andestech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <afleming@freescale.com>, <jeff@garzik.org>,
	<f.rodo@til-technologies.fr>
To: <macpaul@andestech.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from davicom.com.tw ([202.39.11.22]:38517 "EHLO mail.davicom.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933149Ab0J1ITl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 04:19:41 -0400
In-Reply-To: <50FD90C65C53FB45BADEEBCD84FF07F2029CB176@ATCPCS06.andestech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Mac Paul,

=46or you are using DAVICOM PHY in this case.

Our suggestion, please check below red comment text:

 * =3D=3D > Would you tell us your:
=EF=83=98	CPU =3D ?
=EF=83=98	Linux Kernel version=3D ?
      I will like to download the same source code from LXR.
      And can check more detail for you.=20

+static int dm9161_config_aneg(struct phy_device *phydev) {
+	int err;
+
+	/* Isolate the PHY */
     err =3D 0;
+	//err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Configure the new settings */
+	err =3D genphy_config_aneg(phydev);
    err =3D phy_write(phydev, MII_BMCR, BMCR_ANENABLE | 0x200 );
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dm9161_config_init(struct phy_device *phydev) {
+	int err;
+
+	/* Isolate the PHY */
     err =3D 0;
+	//err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Do not bypass the scrambler/descrambler */
+	err =3D phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+
+	if (err < 0)
+		return err;
+
+	/* Clear 10BTCSR to default */
+	err =3D phy_write(phydev, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT=
);
+
+	if (err < 0)
+		return err;
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	err =3D phy_write(phydev, MII_BMCR, BMCR_ANENABLE | 0x200 );
+
+	if (err < 0)
+		return err;
+
+	return 0;

Best Regards,
Joseph CHANG=20
System Application Engineering Division=20
Davicom Semiconductor, Inc.=20
No. 6 Li-Hsin Rd. VI, Science-Based Park,=20
Hsin-Chu, Taiwan.=20
Tel: 886-3-5798797 Ex 8534
=46ax: 886-3-5646929=20
Web: http://www.davicom.com.tw=20


-----Original Message-----
=46rom: macpaul@andestech.com [mailto:macpaul@andestech.com]=20
Sent: Thursday, October 28, 2010 2:34 PM
To: netdev@vger.kernel.org
Cc: afleming@freescale.com; jeff@garzik.org; f.rodo@til-technologies.fr=
; joseph_chang@mail.davicom.com.tw
Subject: About the Davicom PHY in drivers/net/phy in Linux kernel

Hi all,

According to the source code of Davicom PHY in Linux,
We should do "ISOLATE" command to PHY before setting "auto negotiation"=
 or "MII/RMII".

However, I've found that with Faraday's MAC/GMAC controller (ftmac100/f=
tgmac100), setting ISOLATE for multiple PHY configuration will lead MDC=
 become stop because the flaw inside the MAC controller. Faraday's MAC/=
GMAC will leverage the TX_CLK as the MDC source. When FTMAC100 send "IS=
OLATE" to Davicom's PHY, the TX_CLK send out from PHY will be stopped, =
then MDC will also become stop.

However, this mail wasn't meant to discuss about the design flaw inside=
 the IC.

We've done two test to the following codes.

1st: if we just skip the " BMCR_ISOLATE" setting command, we will get P=
HY sometimes become unstable, for example, could not do DHCP request su=
ccessfully.

2nd: if we replace "BMCR_ISOLATE" to "BMCR_RESET", we could get rid of =
the problem occurred by Faraday GMAC. And the PHY works well still.

I've found that in some other PHY implementation, for example, in "marv=
ell.c", there are seems no ISOLATE commands. There are only RESET comma=
nds.
If we could replace BMCR_ISOLATE to BMCR_RESET in current kernel source=
, will there be any unpredictable behavior happened?

Please give us suggestion according to your experiences.
Thanks a lot.

+static int dm9161_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	/* Isolate the PHY */
+	err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Configure the new settings */
+	err =3D genphy_config_aneg(phydev);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dm9161_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Isolate the PHY */
+	err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Do not bypass the scrambler/descrambler */
+	err =3D phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+
+	if (err < 0)
+		return err;
+
+	/* Clear 10BTCSR to default */
+	err =3D phy_write(phydev, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT=
);
+
+	if (err < 0)
+		return err;
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	err =3D phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
+
+	if (err < 0)
+		return err;
+
+	return 0;

Best regards,
Macpaul Lin

--=20
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.


