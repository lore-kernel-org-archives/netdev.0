From: sfeldma@gmail.com
Subject: [PATCH net-next v2 6/7] bridge: don't age externally added FDB entries
Date: Sun, 20 Sep 2015 08:48:28 -0700
Message-ID: <1442764109-11110-7-git-send-email-sfeldma@gmail.com>
References: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36562 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbbITPpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 11:45:51 -0400
Received: by padhk3 with SMTP id hk3so93505710pad.3
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 08:45:50 -0700 (PDT)
In-Reply-To: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_fdb.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875d..6663cc0 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -299,6 +299,8 @@ void br_fdb_cleanup(unsigned long _data)
 			unsigned long this_timer;
 			if (f->is_static)
 				continue;
+			if (f->added_by_external_learn)
+				continue;
 			this_timer = f->updated + delay;
 			if (time_before_eq(this_timer, jiffies))
 				fdb_delete(br, f);
-- 
1.7.10.4
