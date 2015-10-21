From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix incorrect type use.
Date: Tue, 20 Oct 2015 20:47:46 -0700
Message-ID: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35780 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbbJUDrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 23:47:52 -0400
Received: by pasz6 with SMTP id z6so41149888pas.2
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 20:47:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch fixes following sparse warning.
net/openvswitch/flow_netlink.c:583:30: warning: incorrect type in assignment (different base types)
net/openvswitch/flow_netlink.c:583:30:    expected restricted __be16 [usertype] ipv4
net/openvswitch/flow_netlink.c:583:30:    got int

Fixes: 6b26ba3a7d ("openvswitch: netlink attributes for IPv6 tunneling")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 6799c8d..80e1f09 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -548,11 +548,11 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
 			      struct sw_flow_match *match, bool is_mask,
 			      bool log)
 {
+	bool ttl = false, ipv4 = false, ipv6 = false;
+	__be16 tun_flags = 0;
+	int opts_type = 0;
 	struct nlattr *a;
 	int rem;
-	bool ttl = false;
-	__be16 tun_flags = 0, ipv4 = false, ipv6 = false;
-	int opts_type = 0;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
-- 
1.7.1
