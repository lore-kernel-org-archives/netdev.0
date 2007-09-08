From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 04/16] net: Add a network namespace parameter to tasks
Date: Sat, 08 Sep 2007 15:17:03 -0600
Message-ID: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46388 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbXIHVR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:17:28 -0400
In-Reply-To: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 08 Sep 2007 15:15:34 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the network namespace from which all which all sockets
and anything else under user control ultimately get their network
namespace parameters.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/init_task.h |    2 ++
 include/linux/nsproxy.h   |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index cab741c..685d631 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -9,6 +9,7 @@
 #include <linux/ipc.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <net/net_namespace.h>
 
 #define INIT_FDTABLE \
 {							\
@@ -78,6 +79,7 @@ extern struct nsproxy init_nsproxy;
 	.nslock		= __SPIN_LOCK_UNLOCKED(nsproxy.nslock),		\
 	.uts_ns		= &init_uts_ns,					\
 	.mnt_ns		= NULL,						\
+	.net_ns		= &init_net,					\
 	INIT_IPC_NS(ipc_ns)						\
 	.user_ns	= &init_user_ns,				\
 }
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index ce06188..bec4485 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -29,6 +29,7 @@ struct nsproxy {
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 	struct user_namespace *user_ns;
+	struct net 	     *net_ns;
 };
 extern struct nsproxy init_nsproxy;
 
-- 
1.5.3.rc6.17.g1911

