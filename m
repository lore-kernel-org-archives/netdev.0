From: akpm@osdl.org
Subject: [patch 4/9] atm/firestream: handle thrown error
Date: Fri, 20 Oct 2006 14:43:14 -0700
Message-ID: <200610202143.k9KLhEFH003795@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@osdl.org, jeff@garzik.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14725 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992766AbWJTVo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:44:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jeff Garzik <jeff@garzik.org>

gcc emits the following warning:

drivers/atm/firestream.c: In function =E2=80=98fs_open=E2=80=99:
drivers/atm/firestream.c:870: warning: =E2=80=98tmc0=E2=80=99 may be us=
ed uninitialized in this function

This indicates a real bug.  We should check make_rate() return value fo=
r
potential errors.

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/firestream.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN drivers/atm/firestream.c~atm-firestream-handle-thrown-error d=
rivers/atm/firestream.c
--- a/drivers/atm/firestream.c~atm-firestream-handle-thrown-error
+++ a/drivers/atm/firestream.c
@@ -1002,6 +1002,10 @@ static int fs_open(struct atm_vcc *atm_v
 					r =3D ROUND_UP;
 				}
 				error =3D make_rate (pcr, r, &tmc0, NULL);
+				if (error) {
+					kfree(tc);
+					return error;
+				}
 			}
 			fs_dprintk (FS_DEBUG_OPEN, "pcr =3D %d.\n", pcr);
 		}
_
