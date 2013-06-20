From: Zhao Hongjiang <zhaohongjiang@huawei.com>
Subject: [PATCH 4/5] net: irda: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 18:49:44 +0800
Message-ID: <1371725385-11540-4-git-send-email-zhaohongjiang@huawei.com>
References: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, Zhao Hongjiang <zhaohongjiang@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45558 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188Ab3FTKwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 06:52:06 -0400
In-Reply-To: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for NUL terminated string, need alway set '\0' in the end.

Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
---
 net/irda/af_irda.c             |    2 +-
 net/irda/ircomm/ircomm_param.c |    3 ++-
 net/irda/irttp.c               |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 0578d4f..f605d23 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -480,7 +480,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 	notify.udata_indication	     = irda_data_indication;
 	notify.flow_indication       = irda_flow_indication;
 	notify.instance = self;
-	strncpy(notify.name, name, NOTIFY_MAX_NAME);
+	strlcpy(notify.name, name, sizeof(notify.name));
 
 	self->tsap = irttp_open_tsap(tsap_sel, DEFAULT_INITIAL_CREDIT,
 				     &notify);
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 3089391..5b80be8 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -259,7 +259,8 @@ static int ircomm_param_port_name(void *instance, irda_param_t *param, int get)
 		IRDA_DEBUG(0, "%s(), not imp!\n", __func__ );
 	} else {
 		IRDA_DEBUG(0, "%s(), port-name=%s\n", __func__ , param->pv.c);
-		strncpy(self->settings.port_name, param->pv.c, 32);
+		strlcpy(self->settings.port_name, param->pv.c,
+			sizeof(self->settings.port_name));
 	}
 
 	return 0;
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index ae43c62..b6e1c9f 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -430,7 +430,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	if(notify->status_indication != NULL)
 		ttp_notify.status_indication = irttp_status_indication;
 	ttp_notify.instance = self;
-	strncpy(ttp_notify.name, notify->name, NOTIFY_MAX_NAME);
+	strlcpy(ttp_notify.name, notify->name, sizeof(ttp_notify.name));
 
 	self->magic = TTP_TSAP_MAGIC;
 	self->connected = FALSE;
-- 
1.7.1
