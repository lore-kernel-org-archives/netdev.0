From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv6: lower ndisc notifier priority below addrconf
Date: Tue,  8 Aug 2017 15:51:02 -0600
Message-ID: <20170808215102.33798-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33769 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751931AbdHHVvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:51:08 -0400
Received: by mail-pg0-f65.google.com with SMTP id u185so4185199pgb.0
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 14:51:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndisc_notify is used to send unsolicited neighbor advertisements
(e.g., on a link up). Currently, the ndisc notifier is run before the
addrconf notifer which means NA's are not sent for link-local addresses
which are added by the addrconf notifier.

Fix by lowering the priority of the ndisc notifier. Setting the priority
to ADDRCONF_NOTIFY_PRIORITY - 5 means it runs after addrconf and before
the route notifier which is ADDRCONF_NOTIFY_PRIORITY - 10.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/ndisc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0327c1f2e6fc..5e338eb89509 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1779,6 +1779,7 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 
 static struct notifier_block ndisc_netdev_notifier = {
 	.notifier_call = ndisc_netdev_event,
+	.priority = ADDRCONF_NOTIFY_PRIORITY - 5,
 };
 
 #ifdef CONFIG_SYSCTL
-- 
2.9.3
