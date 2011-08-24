From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/9][pull request] Complete drivers/net/ move
Date: Wed, 24 Aug 2011 01:18:33 -0700
Message-ID: <1314173914.2128.249.camel@jtkirshe-mobl>
References: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110824.002513.807528305559470333.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-8X9lcTak3yZfJJKBo5a6"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40949 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab1HXISq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 04:18:46 -0400
In-Reply-To: <20110824.002513.807528305559470333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8X9lcTak3yZfJJKBo5a6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-24 at 00:25 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 23 Aug 2011 21:39:25 -0700
>=20
> > The following series moves the FDDI, PPP, HIPPI, PLIP, SLIP and the cle=
anup
> > of the drivers/net/ Kconfig & Makefile's.  This series in addition move=
s
> > the 2 remaining drivers in drivers/net/pcmcia/ into their respective
> > directories (arcnet & tokenring).  The last remaining change is to
> > make the all the "new" Kconfig options introduced by the Ethernet
> > drivers move to yes, so that current defconfig's will compile the expec=
ted
> > drivers.
> >=20
> > v2- remove the changes for FDDI, HIPPI, PPP, etc Kconfig from menuconfi=
g back
> > to config and used tristate instead of bool.  Apparently some configs l=
oad
> > FDDI and others as a module.
>=20
> Still has build failures:
>=20
> In file included from drivers/net/fddi/skfp/hwmtm.c:29:0:
> drivers/net/fddi/skfp/h/smc.h:41:24: fatal error: h/osdef1st.h: No such f=
ile or directory
> compilation terminated.
> make[4]: *** [drivers/net/fddi/skfp/hwmtm.o] Error 1
> make[4]: *** Waiting for unfinished jobs....
> In file included from drivers/net/fddi/skfp/skfddi.c:97:0:
> drivers/net/fddi/skfp/h/smc.h:41:24: fatal error: h/osdef1st.h: No such f=
ile or directory
> compilation terminated.
> make[4]: *** [drivers/net/fddi/skfp/skfddi.o] Error 1
> make[3]: *** [drivers/net/fddi/skfp] Error 2
> make[2]: *** [drivers/net/fddi] Error 2
> make[2]: *** Waiting for unfinished jobs....
> drivers/net/tokenring/ibmtr_cs.c: In function =E2=80=98ibmtr_config=E2=80=
=99:
> drivers/net/tokenring/ibmtr_cs.c:195:5: warning: =E2=80=98pcmcia_request_=
exclusive_irq=E2=80=99 is deprecated (declared at include/pcmcia/ds.h:201) =
[-Wdeprecated-declarations]
> make[1]: *** [drivers/net] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [drivers] Error 2

I am flabbergasted that this built just fine before the move.  I am
wondering why the move exposed the problem in the driver.  I get the
driver working, but had to make the following changes (NOTE- I will
submit a for these changes):

diff --git a/drivers/net/fddi/skfp/h/cmtdef.h
b/drivers/net/fddi/skfp/h/cmtdef.h
index 5a6c612..f5bc90f 100644
--- a/drivers/net/fddi/skfp/h/cmtdef.h
+++ b/drivers/net/fddi/skfp/h/cmtdef.h
@@ -477,8 +477,8 @@ struct s_plc {
 /*
  * function prototypes
  */
-#include "h/mbuf.h"	/* Type definitions for MBUFs */
-#include "h/smtstate.h"	/* struct smt_state */
+#include "mbuf.h"	/* Type definitions for MBUFs */
+#include "smtstate.h"	/* struct smt_state */
=20
 void hwt_restart(struct s_smc *smc);	/* hwt.c */
 SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
diff --git a/drivers/net/fddi/skfp/h/hwmtm.h
b/drivers/net/fddi/skfp/h/hwmtm.h
index e1a7e5f..5924d42 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -15,7 +15,7 @@
 #ifndef	_HWM_
 #define	_HWM_
=20
-#include "h/mbuf.h"
+#include "mbuf.h"
=20
 /*
  * MACRO for DMA synchronization:
diff --git a/drivers/net/fddi/skfp/h/sba.h
b/drivers/net/fddi/skfp/h/sba.h
index 638cf02..35ddb44 100644
--- a/drivers/net/fddi/skfp/h/sba.h
+++ b/drivers/net/fddi/skfp/h/sba.h
@@ -19,8 +19,8 @@
 #ifndef _SBA_
 #define _SBA_
=20
-#include "h/mbuf.h"
-#include "h/sba_def.h"
+#include "mbuf.h"
+#include "sba_def.h"
=20
 #ifdef	SBA
=20
diff --git a/drivers/net/fddi/skfp/h/skfbiinc.h
b/drivers/net/fddi/skfp/h/skfbiinc.h
index ac2d719..ce72557 100644
--- a/drivers/net/fddi/skfp/h/skfbiinc.h
+++ b/drivers/net/fddi/skfp/h/skfbiinc.h
@@ -15,7 +15,7 @@
 #ifndef	_SKFBIINC_
 #define _SKFBIINC_
=20
-#include "h/supern_2.h"
+#include "supern_2.h"
=20
 /*
  * special defines for use into .asm files
diff --git a/drivers/net/fddi/skfp/h/smc.h
b/drivers/net/fddi/skfp/h/smc.h
index c774a95..3ca308b 100644
--- a/drivers/net/fddi/skfp/h/smc.h
+++ b/drivers/net/fddi/skfp/h/smc.h
@@ -38,18 +38,18 @@
  *	fddi.h
  */
 #ifdef	OSDEF
-#include "h/osdef1st.h"
+#include "osdef1st.h"
 #endif	/* OSDEF */
 #ifdef	OEM_CONCEPT
 #include "oemdef.h"
 #endif	/* OEM_CONCEPT */
-#include "h/smt.h"
-#include "h/cmtdef.h"
-#include "h/fddimib.h"
-#include "h/targethw.h"		/* all target hw dependencies */
-#include "h/targetos.h"		/* all target os dependencies */
+#include "smt.h"
+#include "cmtdef.h"
+#include "fddimib.h"
+#include "targethw.h"		/* all target hw dependencies */
+#include "targetos.h"		/* all target os dependencies */
 #ifdef	ESS
-#include "h/sba.h"
+#include "sba.h"
 #endif
=20
 /*
diff --git a/drivers/net/fddi/skfp/h/targethw.h
b/drivers/net/fddi/skfp/h/targethw.h
index 626dc72..842a690 100644
--- a/drivers/net/fddi/skfp/h/targethw.h
+++ b/drivers/net/fddi/skfp/h/targethw.h
@@ -25,11 +25,11 @@
 #define SK_ML_ID_2	0x30
 #endif
=20
-#include	"h/skfbi.h"
+#include	"skfbi.h"
 #ifndef TAG_MODE=09
-#include	"h/fplus.h"
+#include	"fplus.h"
 #else
-#include	"h/fplustm.h"
+#include	"fplustm.h"
 #endif
=20
 #ifndef	HW_PTR
diff --git a/drivers/net/fddi/skfp/h/targetos.h
b/drivers/net/fddi/skfp/h/targetos.h
index 5d940e7..53bacc1 100644
--- a/drivers/net/fddi/skfp/h/targetos.h
+++ b/drivers/net/fddi/skfp/h/targetos.h
@@ -58,7 +58,7 @@
 #define	ADDR(a) (((a)>>7) ? (outp(smc->hw.iop+B0_RAP,(a)>>7),
(smc->hw.iop+( ((a)&0x7F) | ((a)>>7 ? 0x80:0)) )) : (smc->hw.iop
+(((a)&0x7F)|((a)>>7 ? 0x80:0))))
 #endif
=20
-#include "h/hwmtm.h"
+#include "hwmtm.h"
=20
 #define TRUE  1
 #define FALSE 0

--=-8X9lcTak3yZfJJKBo5a6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOVLPZAAoJECTsCADr/EWUfl8H/jsAVIwdyhbrF163dDSWfSVI
p2Z6mX2hNyaKswum0T+MTTscryNFmt7jC6Nohr21dUke3qkv6Ul4zWV8srU+brlo
+dYT4VGdes9KGqxyJtSXtn9PNUV+MxUBI5tIoUX6H54e1BhpwcIuoFQwP4GYXMJx
izXnlylUg7mCkb+XYuyyWWQmAzWCs3HGMRcIta76wm2tchBgx8MUUVGcFcyhghCy
VxsMAD5EAjnrsG9cux4Mgp3h/ptOA0gEVUVDUOqYhE9jcDhVi+MFw+YG37mNM+Lb
lbqFRovkOazc3TDrKjsSVi3jV7irmr9bc75vl+uhyisR/PirWY1d937/77o/zME=
=KFpG
-----END PGP SIGNATURE-----

--=-8X9lcTak3yZfJJKBo5a6--
