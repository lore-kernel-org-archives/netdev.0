From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 6/31] net: Add a helper to get a reference to the initial network namespace.
Date: Thu, 25 Jan 2007 12:00:08 -0700
Message-ID: <11697516344043-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35788 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030352AbXAYTBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:34 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

The initial network namespace is special and we need to use it for various
things.  Probably the biggest initial use will be to ensure code that
can't cope with multiple namespaces only sees the initial network namespace.

For that reason and because getting at the initial network namespace is just
a little clumsy add a helper function.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 06a9ba1..9208e2e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -27,6 +27,12 @@ struct net_namespace_head {
 	struct work_struct work;
 };
 
+/* Get the initial network namespace */
+static inline net_t init_net(void)
+{
+	return init_nsproxy.net_ns;
+}
+
 static inline net_t get_net(net_t net) { return net; }
 static inline void put_net(net_t net) {}
 static inline net_t hold_net(net_t net) { return net; }
-- 
1.4.4.1.g278f

