From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 12/26] drivers: isdn: Mark functions as static and remove
 unused function in hfcmulti.c
Date: Fri, 7 Feb 2014 18:04:18 +0530
Message-ID: <430c97088237a37ba8cea6e786171ee47b96d4c9.1390408517.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark functions as static in hardware/mISDN/hfcmulti.c because they are
not used outside this file. Remove unused function from
hardware/mISDN/hfcmulti.c.

This eliminates the following warnings in hardware/mISDN/hfcmulti.c:
drivers/isdn/hardware/mISDN/hfcmulti.c:568:1: warning: no previous prot=
otype for =E2=80=98enablepcibridge=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:574:1: warning: no previous prot=
otype for =E2=80=98disablepcibridge=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:580:1: warning: no previous prot=
otype for =E2=80=98readpcibridge=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:608:1: warning: no previous prot=
otype for =E2=80=98writepcibridge=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:638:1: warning: no previous prot=
otype for =E2=80=98cpld_set_reg=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:645:1: warning: no previous prot=
otype for =E2=80=98cpld_write_reg=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:657:1: warning: no previous prot=
otype for =E2=80=98cpld_read_reg=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:674:1: warning: no previous prot=
otype for =E2=80=98vpm_write_address=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:681:1: warning: no previous prot=
otype for =E2=80=98vpm_read_address=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:695:1: warning: no previous prot=
otype for =E2=80=98vpm_in=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:716:1: warning: no previous prot=
otype for =E2=80=98vpm_out=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/hfcmulti.c:1028:1: warning: no previous pro=
totype for =E2=80=98plxsd_checksync=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |   36 ++++++++++--------------=
--------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hard=
ware/mISDN/hfcmulti.c
index 28543d7..0c4021d 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -564,19 +564,19 @@ disable_hwirq(struct hfc_multi *hc)
 #define	MAX_TDM_CHAN 32
=20
=20
-inline void
+static inline void
 enablepcibridge(struct hfc_multi *c)
 {
 	HFC_outb(c, R_BRG_PCM_CFG, (0x0 << 6) | 0x3); /* was _io before */
 }
=20
-inline void
+static inline void
 disablepcibridge(struct hfc_multi *c)
 {
 	HFC_outb(c, R_BRG_PCM_CFG, (0x0 << 6) | 0x2); /* was _io before */
 }
=20
-inline unsigned char
+static inline unsigned char
 readpcibridge(struct hfc_multi *hc, unsigned char address)
 {
 	unsigned short cipv;
@@ -604,7 +604,7 @@ readpcibridge(struct hfc_multi *hc, unsigned char a=
ddress)
 	return data;
 }
=20
-inline void
+static inline void
 writepcibridge(struct hfc_multi *hc, unsigned char address, unsigned c=
har data)
 {
 	unsigned short cipv;
@@ -634,14 +634,14 @@ writepcibridge(struct hfc_multi *hc, unsigned cha=
r address, unsigned char data)
 	outl(datav, hc->pci_iobase);
 }
=20
-inline void
+static inline void
 cpld_set_reg(struct hfc_multi *hc, unsigned char reg)
 {
 	/* Do data pin read low byte */
 	HFC_outb(hc, R_GPIO_OUT1, reg);
 }
=20
-inline void
+static inline void
 cpld_write_reg(struct hfc_multi *hc, unsigned char reg, unsigned char =
val)
 {
 	cpld_set_reg(hc, reg);
@@ -653,7 +653,7 @@ cpld_write_reg(struct hfc_multi *hc, unsigned char =
reg, unsigned char val)
 	return;
 }
=20
-inline unsigned char
+static inline unsigned char
 cpld_read_reg(struct hfc_multi *hc, unsigned char reg)
 {
 	unsigned char bytein;
@@ -670,28 +670,14 @@ cpld_read_reg(struct hfc_multi *hc, unsigned char=
 reg)
 	return bytein;
 }
=20
-inline void
+static inline void
 vpm_write_address(struct hfc_multi *hc, unsigned short addr)
 {
 	cpld_write_reg(hc, 0, 0xff & addr);
 	cpld_write_reg(hc, 1, 0x01 & (addr >> 8));
 }
=20
-inline unsigned short
-vpm_read_address(struct hfc_multi *c)
-{
-	unsigned short addr;
-	unsigned short highbit;
-
-	addr =3D cpld_read_reg(c, 0);
-	highbit =3D cpld_read_reg(c, 1);
-
-	addr =3D addr | (highbit << 8);
-
-	return addr & 0x1ff;
-}
-
-inline unsigned char
+static inline unsigned char
 vpm_in(struct hfc_multi *c, int which, unsigned short addr)
 {
 	unsigned char res;
@@ -712,7 +698,7 @@ vpm_in(struct hfc_multi *c, int which, unsigned sho=
rt addr)
 	return res;
 }
=20
-inline void
+static inline void
 vpm_out(struct hfc_multi *c, int which, unsigned short addr,
 	unsigned char data)
 {
@@ -1024,7 +1010,7 @@ hfcmulti_resync(struct hfc_multi *locked, struct =
hfc_multi *newmaster, int rm)
 }
=20
 /* This must be called AND hc must be locked irqsave!!! */
-inline void
+static inline void
 plxsd_checksync(struct hfc_multi *hc, int rm)
 {
 	if (hc->syncronized) {
--=20
1.7.9.5
