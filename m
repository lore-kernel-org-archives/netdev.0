From: frank.blaschka@de.ibm.com
Subject: [patch 2/6] [PATCH] qeth: Remove unused exports
Date: Mon, 21 Jan 2013 13:30:19 +0100
Message-ID: <20130121123037.315280643@de.ibm.com>
References: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:34367 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab3AUMao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:44 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:28:52 -0000
Content-Disposition: inline; filename=601-qeth-exports.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Remove exports that are not used anywhere else.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    3 ---
 drivers/s390/net/qeth_core_main.c |    6 ++----
 2 files changed, 2 insertions(+), 7 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -909,9 +909,6 @@ struct qeth_cmd_buffer *qeth_wait_for_bu
 int qeth_mdio_read(struct net_device *, int, int);
 int qeth_snmp_command(struct qeth_card *, char __user *);
 int qeth_query_oat_command(struct qeth_card *, char __user *);
-struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *, __u32, __u32);
-int qeth_default_setadapterparms_cb(struct qeth_card *, struct qeth_reply *,
-					unsigned long);
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2868,7 +2868,7 @@ int qeth_send_startlan(struct qeth_card
 }
 EXPORT_SYMBOL_GPL(qeth_send_startlan);
 
-int qeth_default_setadapterparms_cb(struct qeth_card *card,
+static int qeth_default_setadapterparms_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
 {
 	struct qeth_ipa_cmd *cmd;
@@ -2881,7 +2881,6 @@ int qeth_default_setadapterparms_cb(stru
 			cmd->data.setadapterparms.hdr.return_code;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(qeth_default_setadapterparms_cb);
 
 static int qeth_query_setadapterparms_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
@@ -2901,7 +2900,7 @@ static int qeth_query_setadapterparms_cb
 	return qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
 }
 
-struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *card,
+static struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *card,
 		__u32 command, __u32 cmdlen)
 {
 	struct qeth_cmd_buffer *iob;
@@ -2917,7 +2916,6 @@ struct qeth_cmd_buffer *qeth_get_adapter
 
 	return iob;
 }
-EXPORT_SYMBOL_GPL(qeth_get_adapter_cmd);
 
 int qeth_query_setadapterparms(struct qeth_card *card)
 {
