From: Dan Noe <dpn@isomerica.net>
Subject: [PATCH] cxgb3: Fix __must_check warning.
Date: Tue,  1 Apr 2008 23:35:42 -0400
Message-ID: <1207107342276-git-send-email-dpn@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Noe <dpn@isomerica.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:57190 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbYDBDkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 23:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the warning:
drivers/net/cxgb3/cxgb3_main.c: In function =E2=80=98offload_open=E2=80=
=99:
drivers/net/cxgb3/cxgb3_main.c:936: warning: ignoring return value of =E2=
=80=98sysfs_create_group=E2=80=99, declared with attribute warn_unused_=
result

Now the return value is checked; if sysfs_create_group() returns failur=
e,
a warning is printed, and the code continues as before.

Signed-off-by: Dan Noe <dpn@isomerica.net>
---
 drivers/net/cxgb3/cxgb3_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

My first patch - feedback is appreciated, please be gentle.  Thanks!

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index fd2e05b..3007fe1 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1015,7 +1015,8 @@ static int offload_open(struct net_device *dev)
 	init_smt(adapter);
=20
 	/* Never mind if the next step fails */
-	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
+	if (sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group))
+		printk(KERN_WARNING DRV_NAME ": cannot create sysfs group\n");
=20
 	/* Call back all registered clients */
 	cxgb3_add_clients(tdev);
--=20
1.5.2.5

