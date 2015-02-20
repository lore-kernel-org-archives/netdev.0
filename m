From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 5/5] rocker: explicitly set SW ageing for rocker
Date: Thu, 19 Feb 2015 23:09:55 -0800
Message-ID: <1424416195-19098-6-git-send-email-sfeldma@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36826 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbbBTHJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:33 -0500
Received: by pabkq14 with SMTP id kq14so5994207pab.3
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:33 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker (for now) will rely on SW (bridge) ageing.  Other drivers/devices may
wish to set NTF_EXT_AGED to turn off SW (bridge) ageing.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34389b6a..7b55934 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3026,10 +3026,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		container_of(work, struct rocker_fdb_learn_work, work);
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
-	struct netdev_switch_notifier_fdb_info info;
-
-	info.addr = lw->addr;
-	info.vid = lw->vid;
+	struct netdev_switch_notifier_fdb_info info = {
+		.addr = lw->addr,
+		.vid = lw->vid,
+		.ntf_flags = NTF_EXT_LEARNED,
+	};
 
 	if (learned && removing)
 		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
-- 
1.7.10.4
