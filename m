From: sjur.brandeland@stericsson.com
Subject: [PATCH 1/2] caif: Bugfix use for_each_safe when removing list nodes.
Date: Mon, 11 Apr 2011 22:11:29 +0200
Message-ID: <1302552691-11874-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:53720 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878Ab1DKULg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:11:36 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0096883BEF90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:35 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI007NQ83ANZZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:35 +0200 (CEST)
In-reply-to: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfmuxl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 6bb338d..fc24974 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -205,9 +205,9 @@ static void cfmuxl_ctrlcmd(struct cflayer *layr, en=
um caif_ctrlcmd ctrl,
 				int phyid)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
-	struct list_head *node;
+	struct list_head *node, *next;
 	struct cflayer *layer;
-	list_for_each(node, &muxl->srvl_list) {
+	list_for_each_safe(node, next, &muxl->srvl_list) {
 		layer =3D list_entry(node, struct cflayer, node);
 		if (cfsrvl_phyid_match(layer, phyid))
 			layer->ctrlcmd(layer, ctrl, phyid);
--=20
1.7.0.4

