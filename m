From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH V2 net] ipv4:correct description for tcp_max_syn_backlog
Date: Tue,  6 Dec 2011 15:39:41 +0800
Message-ID: <ed04712f4f61e291ac784a8a77e2831981cfb9c1.1323156956.git.panweiping3@gmail.com>
References: <4EDDC1D6.6000708@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net> (maintainer:DOCUMENTATION),
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[GENERAL],commit_signer:11/16=69%),
	Eric Dumazet <eric.dumazet@gmail.com> (commit_signer:3/16=19%),
	Shan Wei <shanwei@cn.fujitsu.com> (commit_signer:3/16=19%),
	Neil Horman <nhorman@tuxdriver.com> (commit_signer:2/16=12%),
	Max Matveev <makc@redhat.com> (commit_signer:2/16=12%),
	linux-doc@vger.kernel.org (open list:DOCUMENTATION),
	linux-kernel@vger.kernel.org (open list),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
To: shanwei88@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4EDDC1D6.6000708@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit c5ed63d66f24(tcp: fix three tcp sysctls tuning),
sysctl_max_syn_backlog is determined by tcp_hashinfo->ehash_mask,
and the minimal value is 128, and it will increase in proportion to the
memory of machine.
The original description for tcp_max_syn_backlog and sysctl_max_syn_backlog
are out of date.

Changelog:
V2: update description for sysctl_max_syn_backlog

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   10 +++++-----
 net/core/request_sock.c                |    7 ++++---
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f049a1c..589f2da 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -282,11 +282,11 @@ tcp_max_ssthresh - INTEGER
 	Default: 0 (off)
 
 tcp_max_syn_backlog - INTEGER
-	Maximal number of remembered connection requests, which are
-	still did not receive an acknowledgment from connecting client.
-	Default value is 1024 for systems with more than 128Mb of memory,
-	and 128 for low memory machines. If server suffers of overload,
-	try to increase this number.
+	Maximal number of remembered connection requests, which have not
+	received an acknowledgment from connecting client.
+	The minimal value is 128 for low memory machines, and it will
+	increase in proportion to the memory of machine.
+	If server suffers from overload, try increasing this number.
 
 tcp_max_tw_buckets - INTEGER
 	Maximal number of timewait sockets held by system simultaneously.
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 182236b..9b570a6 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -26,10 +26,11 @@
  * but then some measure against one socket starving all other sockets
  * would be needed.
  *
- * It was 128 by default. Experiments with real servers show, that
+ * The minimum value of it is 128. Experiments with real servers show that
  * it is absolutely not enough even at 100conn/sec. 256 cures most
- * of problems. This value is adjusted to 128 for very small machines
- * (<=32Mb of memory) and to 1024 on normal or better ones (>=256Mb).
+ * of problems.
+ * This value is adjusted to 128 for low memory machines,
+ * and it will increase in proportion to the memory of machine.
  * Note : Dont forget somaxconn that may limit backlog too.
  */
 int sysctl_max_syn_backlog = 256;
-- 
1.7.4.4

