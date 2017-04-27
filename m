From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] net: Initialise init_net.count to 1
Date: Thu, 27 Apr 2017 22:40:23 +0100
Message-ID: <149332922378.28919.11614036268701178135.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialise init_net.count to 1 for its pointer from init_nsproxy lest
someone tries to do a get_net() and a put_net() in a process in which
current->ns_proxy->net_ns points to the initial network namespace.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/core/net_namespace.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 652468ff65b7..adb97ca141b7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -35,7 +35,8 @@ LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
 
 struct net init_net = {
-	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
+	.count		= ATOMIC_INIT(1),
+	.dev_base_head	= LIST_HEAD_INIT(init_net.dev_base_head),
 };
 EXPORT_SYMBOL(init_net);
 
