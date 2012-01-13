From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 3/5] bcma: add stub for bcma_bus_suspend()
Date: Fri, 13 Jan 2012 23:58:40 +0100
Message-ID: <1326495522-6024-3-git-send-email-zajec5@gmail.com>
References: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42276 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2AMW67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 17:58:59 -0500
Received: by eekd4 with SMTP id d4so1238257eek.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 14:58:57 -0800 (PST)
In-Reply-To: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>

=2E. and connect it up with the pci host bcma driver.

Now, the next step is to connect those bcma bus-level suspend/resume
functions to the actual bcma device suspend resume functions.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/bcma/bcma_private.h |    1 +
 drivers/bcma/host_pci.c     |    2 +-
 drivers/bcma/main.c         |    5 +++++
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index fda56bd..0def898 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -19,6 +19,7 @@ int __init bcma_bus_early_register(struct bcma_bus *b=
us,
 				   struct bcma_device *core_cc,
 				   struct bcma_device *core_mips);
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus);
 int bcma_bus_resume(struct bcma_bus *bus);
 #endif
=20
diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 86dfeea..f59244e 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -242,7 +242,7 @@ static int bcma_host_pci_suspend(struct device *dev=
)
=20
 	bus->mapped_core =3D NULL;
=20
-	return 0;
+	return bcma_bus_suspend(bus);
 }
=20
 static int bcma_host_pci_resume(struct device *dev)
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 10f92b3..b711d9d 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -241,6 +241,11 @@ int __init bcma_bus_early_register(struct bcma_bus=
 *bus,
 }
=20
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus)
+{
+	return 0;
+}
+
 int bcma_bus_resume(struct bcma_bus *bus)
 {
 	struct bcma_device *core;
--=20
1.7.7
