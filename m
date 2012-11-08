From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] netconsole: add oops_only module option
Date: Thu,  8 Nov 2012 21:42:38 +0800
Message-ID: <1352382158-3928-1-git-send-email-amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755582Ab2KHNnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 08:43:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some people wants to log only oops messages via netconsole,
(this is also why netoops was invented)
so add a module option for netconsole. This can be tuned
via /sys/module/netconsole/parameters/oops_only at run time
as well.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index b332112..6989ebe 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -56,6 +56,10 @@ static char config[MAX_PARAM_LENGTH];
 module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]");
 
+static bool oops_only = false;
+module_param(oops_only, bool, 0600);
+MODULE_PARM_DESC(oops_only, "Only log oops messages");
+
 #ifndef	MODULE
 static int __init option_setup(char *opt)
 {
@@ -683,6 +687,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	struct netconsole_target *nt;
 	const char *tmp;
 
+	if (oops_only && !oops_in_progress)
+		return;
 	/* Avoid taking lock and disabling interrupts unnecessarily */
 	if (list_empty(&target_list))
 		return;
