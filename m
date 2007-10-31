From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/5] Mark the setup_net as __net_init
Date: Wed, 31 Oct 2007 22:31:46 +0300
Message-ID: <4728D822.30906@openvz.org>
References: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40036 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbXJaS3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 14:29:30 -0400
In-Reply-To: <4728D54F.2080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The setup_net is called for the init net namespace
only (int the CONFIG_NET_NS=n of course) from the __init
function, so mark it as __net_init to disappear with the
caller after the boot.

Yet again, in the perfect world this has to be under
#ifdef CONFIG_NET_NS, but it isn't guaranteed that every
subsystem is registered *after* the init_net_ns is set
up. After we are sure, that we don't start registering
them before the init net setup, we'll be able to move
this code under the ifdef.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index d5bf8b2..a044e2d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -25,7 +25,7 @@ EXPORT_SYMBOL_GPL(init_net);
 /*
  * setup_net runs the initializers for the network namespace object.
  */
-static int setup_net(struct net *net)
+static __net_init int setup_net(struct net *net)
 {
 	/* Must be called with net_mutex held */
 	struct pernet_operations *ops;
-- 
1.5.3.4

