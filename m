From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] fix drivers/net/wan/lmc/ compilation
Date: Tue, 30 Oct 2007 21:31:36 +0100
Message-ID: <20071030203136.GQ7227@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org
To: Roel Kluin <12o3l@tiscali.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59572 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752960AbXJ3Ubi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 16:31:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/SubmitChecklist, point 1:

<--  snip  -->

=2E..
  CC      drivers/net/wan/lmc/lmc_main.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/wan/lmc/lmc_main.=
c: In function =E2=80=98lmc_ioctl=E2=80=99:
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/wan/lmc/lmc_main.=
c:239: error: expected expression before =E2=80=98else=E2=80=99
=2E..
make[5]: *** [drivers/net/wan/lmc/lmc_main.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
d5e92a30491abf073e0a7f4d46b466c7c97f0f61=20
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_m=
ain.c
index 64eb578..37c52e1 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -234,7 +234,7 @@ int lmc_ioctl (struct net_device *dev, struct ifreq=
 *ifr, int cmd) /*fold00*/
         sc->lmc_xinfo.Magic1 =3D 0xDEADBEEF;
=20
         if (copy_to_user(ifr->ifr_data, &sc->lmc_xinfo,
-					sizeof(struct lmc_xinfo))) {
+			 sizeof(struct lmc_xinfo)))
 		ret =3D -EFAULT;
 	else
 		ret =3D 0;

