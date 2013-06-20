From: Zhao Hongjiang <zhaohongjiang@huawei.com>
Subject: [PATCH 5/5] net: bluetooth: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 18:49:45 +0800
Message-ID: <1371725385-11540-5-git-send-email-zhaohongjiang@huawei.com>
References: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, Zhao Hongjiang <zhaohongjiang@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45787 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754919Ab3FTKwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 06:52:47 -0400
In-Reply-To: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for NUL terminated string, need alway set '\0' in the end.

Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
---
 net/bluetooth/hidp/core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 940f5ac..828be45 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -85,7 +85,7 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
 		ci->product = session->input->id.product;
 		ci->version = session->input->id.version;
 		if (session->input->name)
-			strncpy(ci->name, session->input->name, 128);
+			strlcpy(ci->name, session->input->name, sizeof(ci->name));
 		else
 			strncpy(ci->name, "HID Boot Device", 128);
 	}
@@ -94,7 +94,7 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
 		ci->vendor  = session->hid->vendor;
 		ci->product = session->hid->product;
 		ci->version = session->hid->version;
-		strncpy(ci->name, session->hid->name, 128);
+		strlcpy(ci->name, session->hid->name, sizeof(ci->name));
 	}
 }
 
-- 
1.7.1
