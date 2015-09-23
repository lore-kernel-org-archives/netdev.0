From: sfeldma@gmail.com
Subject: [PATCH net-next v3 6/7] bridge: don't age externally added FDB entries
Date: Wed, 23 Sep 2015 08:39:19 -0700
Message-ID: <1443022760-21301-7-git-send-email-sfeldma@gmail.com>
References: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33593 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629AbbIWPgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:36:16 -0400
Received: by pacex6 with SMTP id ex6so43639743pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:36:15 -0700 (PDT)
In-Reply-To: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Premkumar Jonnala <pjonnala@broadcom.com>
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
