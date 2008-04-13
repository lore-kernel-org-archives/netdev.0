From: Dan Noe <dpn@isomerica.net>
Subject: [PATCH] cxgb3: Fix __must_check warning with dev_dbg.
Date: Sat, 12 Apr 2008 22:34:38 -0400
Message-ID: <12080540782177-git-send-email-dpn@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Dan Noe <dpn@isomerica.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:50030 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbYDMChL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 22:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the warning:
drivers/net/cxgb3/cxgb3_main.c: In function =E2=80=98offload_open=E2=80=
=99:
drivers/net/cxgb3/cxgb3_main.c:936: warning: ignoring return value of
 =E2=80=98sysfs_create_group=E2=80=99, declared with attribute warn_unu=
sed_result

Now the return value is checked; if sysfs_create_group() returns failur=
e,
a warning is printed using dev_dbg, and the code continues as before.  =
Use
of dev_dbg ensures printk is not needlessly included unless desired for
debugging.

Signed-off-by: Dan Noe <dpn@isomerica.net>
---
 drivers/net/cxgb3/cxgb3_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index fd2e05b..05e5f59 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1014,8 +1014,8 @@ static int offload_open(struct net_device *dev)
 		     adapter->port[0]->mtu : 0xffff);
 	init_smt(adapter);
=20
-	/* Never mind if the next step fails */
-	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
+	if (sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group))
+		dev_dbg(&dev->dev, "cannot create sysfs group\n");
=20
 	/* Call back all registered clients */
 	cxgb3_add_clients(tdev);
--=20
1.5.2.5

