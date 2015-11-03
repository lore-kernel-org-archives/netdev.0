From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: clean up dev_snmp6 proc entry when we fail to initialize inet6_dev
Date: Tue,  3 Nov 2015 19:09:09 +0100
Message-ID: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Cc: eric.dumazet@gmail.com, dvyukov@google.com,
	hannes@stressinduktion.org, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754175AbbKCSJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 13:09:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
the dev_snmp6 entry that we have already registered for this device.

It is safe to call snmp6_unregister_dev unconditionally from
in6_dev_finish_destroy, so do it.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
Dmitry, I'm not completely sure it's the issue you're triggering, but
it sems likely.

 net/ipv6/addrconf_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index bfa941fc1165..96248a333197 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -168,6 +168,8 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 		pr_warn("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
+
+	snmp6_unregister_dev(idev);
 	call_rcu(&idev->rcu, in6_dev_finish_destroy_rcu);
 }
 EXPORT_SYMBOL(in6_dev_finish_destroy);
-- 
2.6.2
