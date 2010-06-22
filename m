From: frank.blaschka@de.ibm.com
Subject: [patch 02/11] [PATCH] qeth: Rework qeth_dbf_longtext
Date: Tue, 22 Jun 2010 10:57:03 +0200
Message-ID: <20100622085807.086142000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:50262 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758947Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=602-qeth-dbf-long.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch decouples qeth_dbf_longtext from qeth's static debug array. The
function only uses one member anyway.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    4 ++--
 drivers/s390/net/qeth_core_main.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:54:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:54:58.000000000 +0200
@@ -71,7 +71,7 @@ struct qeth_dbf_info {
 	debug_sprintf_event(qeth_dbf[QETH_DBF_MSG].id, level, text)
 
 #define QETH_DBF_TEXT_(name, level, text...) \
-	qeth_dbf_longtext(QETH_DBF_##name, level, text)
+	qeth_dbf_longtext(qeth_dbf[QETH_DBF_##name].id, level, text)
 
 #define SENSE_COMMAND_REJECT_BYTE 0
 #define SENSE_COMMAND_REJECT_FLAG 0x80
@@ -857,7 +857,7 @@ void qeth_core_get_ethtool_stats(struct 
 				struct ethtool_stats *, u64 *);
 void qeth_core_get_strings(struct net_device *, u32, u8 *);
 void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
-void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...);
+void qeth_dbf_longtext(debug_info_t *id, int level, char *text, ...);
 int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
 int qeth_set_access_ctrl_online(struct qeth_card *card);
 
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:58.000000000 +0200
@@ -4164,17 +4164,17 @@ static void qeth_unregister_dbf_views(vo
 	}
 }
 
-void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *fmt, ...)
+void qeth_dbf_longtext(debug_info_t *id, int level, char *fmt, ...)
 {
 	char dbf_txt_buf[32];
 	va_list args;
 
-	if (level > (qeth_dbf[dbf_nix].id)->level)
+	if (level > id->level)
 		return;
 	va_start(args, fmt);
 	vsnprintf(dbf_txt_buf, sizeof(dbf_txt_buf), fmt, args);
 	va_end(args);
-	debug_text_event(qeth_dbf[dbf_nix].id, level, dbf_txt_buf);
+	debug_text_event(id, level, dbf_txt_buf);
 }
 EXPORT_SYMBOL_GPL(qeth_dbf_longtext);
 

