From: Doug Ledford <dledford@redhat.com>
Subject: [PATCH] net/core: Add VF link state control policy
Date: Wed, 11 Jun 2014 10:38:03 -0400
Message-ID: <74ee0f0299e2043de14be353dd7d34fe07ecdf92.1402497459.git.dledford@redhat.com>
Cc: Rony Efraim <ronye@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbaFKOiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 10:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1d8faf48c7 (net/core: Add VF link state control) added VF link state
control to the netlink VF nested structure, but failed to add a proper entry
for the new structure into the VF policy table.  Add the missing entry so
the table and the actual data copied into the netlink nested struct are in
sync.

Signed-off-by: Doug Ledford <dledford@redhat.com>
---
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2d8d8fcfa06..cdccf028171 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1208,6 +1208,8 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_tx_rate) },
 	[IFLA_VF_SPOOFCHK]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_spoofchk) },
+	[IFLA_VF_LINK_STATE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_link_state) },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
-- 
1.9.3
