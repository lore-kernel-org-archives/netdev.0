From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is updated
Date: Mon, 29 Aug 2016 12:05:48 +0200
Message-ID: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56067 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756136AbcH2KLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 06:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'default' value was not advertised.

Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f418d2eaeddd..299f0656e87f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -778,7 +778,14 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	}
 
 	if (p == &net->ipv6.devconf_all->forwarding) {
+		int old_dftl = net->ipv6.devconf_dflt->forwarding;
+
 		net->ipv6.devconf_dflt->forwarding = newf;
+		if ((!newf) ^ (!old_dftl))
+			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
+
 		addrconf_forward_change(net, newf);
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
-- 
2.8.1
