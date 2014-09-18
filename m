From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 1/2] genetlink: add function genl_has_listeners()
Date: Thu, 18 Sep 2014 10:31:03 +0200
Message-ID: <1411029064-15376-1-git-send-email-nicolas.dichtel@6wind.com>
References: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
Cc: davem@davemloft.net, dev@openvswitch.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36091 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbaIRIbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 04:31:17 -0400
In-Reply-To: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is the counterpart of the function netlink_has_listeners().

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: add patch 1/2

 include/net/genetlink.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 93695f0e22a5..af10c2cf8a1d 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -394,4 +394,12 @@ static inline int genl_set_err(struct genl_family *family, struct net *net,
 	return netlink_set_err(net->genl_sock, portid, group, code);
 }
 
+static inline int genl_has_listeners(struct genl_family *family,
+				     struct sock *sk, unsigned int group)
+{
+	if (WARN_ON_ONCE(group >= family->n_mcgrps))
+		return -EINVAL;
+	group = family->mcgrp_offset + group;
+	return netlink_has_listeners(sk, group);
+}
 #endif	/* __NET_GENERIC_NETLINK_H */
-- 
2.1.0
