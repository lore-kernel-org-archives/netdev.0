From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Thu, 24 Oct 2013 15:45:55 +0200
Message-ID: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:56910 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709Ab3JXNsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 09:48:07 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so930967eei.27
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 06:48:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed in order to implement userspace address configuration,
namely ip6-privacy (rfc4941) in NetworkManager.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/addrconf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd3fb30..962c7c9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -ENODEV;
 
 	/* We ignore other flags so far. */
-	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
+	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
+				      IFA_F_TEMPORARY);
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
-- 
1.8.3.1
