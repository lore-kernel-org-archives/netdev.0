From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH] ISDN, hfcpci Fix uninitialized warning
Date: Fri, 13 Sep 2013 08:28:16 -0400
Message-ID: <1379075296-19976-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, dzickus@redhat.com,
	Karsten Keil <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab3IMM2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 08:28:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix uninitialized warning.  Use same fix as
drivers/media/pci/cx18/cx18-alsa-main.c

  CC [M]  drivers/isdn/hardware/mISDN/hfcpci.o
  drivers/isdn/hardware/mISDN/hfcpci.c: In function =E2=80=98hfcpci_sof=
tirq=E2=80=99:
  drivers/isdn/hardware/mISDN/hfcpci.c:2298:2: error: ignoring return
  value of =E2=80=98driver_for_each_device=E2=80=99, declared with attr=
ibute
  warn_unused_result [-Werror=3Dunused-result]
    (void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
		      ^

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: dzickus@redhat.com
Cc: Karsten Keil <isdn@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/hfcpci.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardwa=
re/mISDN/hfcpci.c
index 7f910c7..2373b44 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2295,8 +2295,12 @@ _hfcpci_softirq(struct device *dev, void *arg)
 static void
 hfcpci_softirq(void *arg)
 {
-	(void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
+	int ret;
+
+	ret =3D driver_for_each_device(&hfc_driver.driver, NULL, arg,
 				      _hfcpci_softirq);
+	if (unlikely(ret))
+		pr_warn("hfcpci_softirq: driver softirq failed\n");
=20
 	/* if next event would be in the past ... */
 	if ((s32)(hfc_jiffies + tics - jiffies) <=3D 0)
--=20
1.7.9.3
