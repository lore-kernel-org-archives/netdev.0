From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 1/2] ipv6: add missing netconf notif when 'all' is updated
Date: Tue, 30 Aug 2016 10:09:21 +0200
Message-ID: <1472544562-22581-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, hideaki.yoshifuji@miraclelinux.com,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:57004 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755504AbcH3IJh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 04:09:37 -0400
In-Reply-To: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'default' value was not advertised.

Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: fix a typo in the variable old_dflt

 net/ipv6/addrconf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f418d2eaeddd..2a688171a188 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -778,7 +778,14 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	}
 
 	if (p == &net->ipv6.devconf_all->forwarding) {
+		int old_dflt = net->ipv6.devconf_dflt->forwarding;
+
 		net->ipv6.devconf_dflt->forwarding = newf;
+		if ((!newf) ^ (!old_dflt))
+			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
+
 		addrconf_forward_change(net, newf);
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
-- 
2.8.1
