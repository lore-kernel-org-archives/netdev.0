From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/5] netlink: rename netlink_unbind() to netlink_undo_bind()
Date: Mon, 22 Dec 2014 18:56:35 +0100
Message-ID: <1419270999-22165-2-git-send-email-johannes@sipsolutions.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35030 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbaLVR4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:45 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The new name is more expressive - this isn't a generic unbind
function but rather only a little undo helper for use only in
netlink_bind().

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ef5f77b44ec7..1117a2cc7c28 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1430,8 +1430,8 @@ static int netlink_realloc_groups(struct sock *sk)
 	return err;
 }
 
-static void netlink_unbind(int group, long unsigned int groups,
-			   struct netlink_sock *nlk)
+static void netlink_undo_bind(int group, long unsigned int groups,
+			      struct netlink_sock *nlk)
 {
 	int undo;
 
@@ -1481,7 +1481,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			err = nlk->netlink_bind(group);
 			if (!err)
 				continue;
-			netlink_unbind(group, groups, nlk);
+			netlink_undo_bind(group, groups, nlk);
 			return err;
 		}
 	}
@@ -1491,7 +1491,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			netlink_insert(sk, net, nladdr->nl_pid) :
 			netlink_autobind(sock);
 		if (err) {
-			netlink_unbind(nlk->ngroups, groups, nlk);
+			netlink_undo_bind(nlk->ngroups, groups, nlk);
 			return err;
 		}
 	}
-- 
2.1.1
