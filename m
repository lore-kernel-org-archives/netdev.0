From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-next-2.6 v4 03/14] ppp: Add ppp_dev_name() exported
	function
Date: Fri, 02 Apr 2010 17:18:39 +0100
Message-ID: <20100402161838.11367.55438.stgit@bert.katalix.com>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:33906 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884Ab0DBQSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 12:18:14 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 31CE0A620A3
	for <netdev@vger.kernel.org>; Fri,  2 Apr 2010 17:18:39 +0100 (BST)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7dMKzVF7fu1g for <netdev@vger.kernel.org>;
	Fri,  2 Apr 2010 17:18:39 +0100 (BST)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 0FA00A62087
	for <netdev@vger.kernel.org>; Fri,  2 Apr 2010 17:18:39 +0100 (BST)
In-Reply-To: <20100402161822.11367.70454.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp_dev_name() gives PPP users visibility of a ppp channel's device
name. This can be used by L2TP drivers to dump the assigned PPP
interface name.

Signed-off-by: James Chapman <jchapman@katalix.com>
Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/ppp_generic.c   |   19 +++++++++++++++++++
 include/linux/ppp_channel.h |    3 +++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 6d61602..8a0dd8a 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2163,6 +2163,24 @@ int ppp_unit_number(struct ppp_channel *chan)
 }
 
 /*
+ * Return the PPP device interface name of a channel.
+ */
+char *ppp_dev_name(struct ppp_channel *chan)
+{
+	struct channel *pch = chan->ppp;
+	char *name = NULL;
+
+	if (pch) {
+		read_lock_bh(&pch->upl);
+		if (pch->ppp && pch->ppp->dev)
+			name = pch->ppp->dev->name;
+		read_unlock_bh(&pch->upl);
+	}
+	return name;
+}
+
+
+/*
  * Disconnect a channel from the generic layer.
  * This must be called in process context.
  */
@@ -2890,6 +2908,7 @@ EXPORT_SYMBOL(ppp_register_channel);
 EXPORT_SYMBOL(ppp_unregister_channel);
 EXPORT_SYMBOL(ppp_channel_index);
 EXPORT_SYMBOL(ppp_unit_number);
+EXPORT_SYMBOL(ppp_dev_name);
 EXPORT_SYMBOL(ppp_input);
 EXPORT_SYMBOL(ppp_input_error);
 EXPORT_SYMBOL(ppp_output_wakeup);
diff --git a/include/linux/ppp_channel.h b/include/linux/ppp_channel.h
index 0d3fa63..bff98ec 100644
--- a/include/linux/ppp_channel.h
+++ b/include/linux/ppp_channel.h
@@ -72,6 +72,9 @@ extern int ppp_channel_index(struct ppp_channel *);
 /* Get the unit number associated with a channel, or -1 if none */
 extern int ppp_unit_number(struct ppp_channel *);
 
+/* Get the device name associated with a channel, or NULL if none */
+extern char *ppp_dev_name(struct ppp_channel *);
+
 /*
  * SMP locking notes:
  * The channel code must ensure that when it calls ppp_unregister_channel,

