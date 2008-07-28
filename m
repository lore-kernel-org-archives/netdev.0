From: Jaswinder Singh <jaswinder@infradead.org>
Subject: Re: [PATCH] smc91c92_cs: use request_firmware
Date: Mon, 28 Jul 2008 14:32:54 +0530
Message-ID: <1217235775.6407.3.camel@jaswinder.satnam>
References: <1217170341.3537.9.camel@jaswinder.satnam>
	 <20080728082814.GA4708@isilmar.linta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, dahinds@users.sourceforge.net,
	becker@scyld.com, x-csrdh@jcu.edu.au, erik@vt.edu,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755450AbYG1JEa@vger.kernel.org>
In-Reply-To: <20080728082814.GA4708@isilmar.linta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello =EF=BB=BFDominik,

On Mon, 2008-07-28 at 10:28 +0200, Dominik Brodowski wrote:
> > +static int osi_load_firmware(struct pcmcia_device *link)
> > +{
> > +	struct platform_device *pdev;
> > +	const struct firmware *fw;
> > +	const char fw_name[] =3D "ositech/Xilinx7OD.bin";=20
> > +	int i, err;
> > +=20
> > +	pdev =3D platform_device_register_simple("ositech", 0, NULL, 0);
>=20
> Why do we need a platform_device here? Can't we just use the pcmcia d=
evice
> (so &link->dev) here?
>=20

Thanks for pointing it out, I was searching for it.

Here is the fix:

diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc9=
1c92_cs.c
index 03f9be9..43d8e23 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -43,7 +43,6 @@
 #include <linux/mii.h>
 #include <linux/jiffies.h>
 #include <linux/firmware.h>
-#include <linux/platform_device.h>
=20
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
@@ -794,18 +793,11 @@ static int osi_config(struct pcmcia_device *link)
=20
 static int osi_load_firmware(struct pcmcia_device *link)
 {
-	struct platform_device *pdev;
 	const struct firmware *fw;
 	const char fw_name[] =3D "ositech/Xilinx7OD.bin";=20
 	int i, err;
 =20
-	pdev =3D platform_device_register_simple("ositech", 0, NULL, 0);
-	if (IS_ERR(pdev)) {
-		printk(KERN_ERR "Failed to register platform device ositech\n");
-		return IS_ERR(pdev);
-	}
-	err =3D request_firmware(&fw, fw_name, &pdev->dev);
-	platform_device_unregister(pdev);
+	err =3D request_firmware(&fw, fw_name, &link->dev);
 	if (err) {
 		printk(KERN_ERR "Failed to load firmware \"%s\"\n",
 		       fw_name);

You can check updated patch from :-

http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git

Thank you,

Jaswinder Singh.
