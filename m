From: "liping.zhang" <zlpwmdx@163.com>
Subject: [PATCH] net: socket: use pr_info_once to tip the obsolete usage of PF_PACKET
Date: Fri, 11 Mar 2016 23:08:36 +0800
Message-ID: <1457708916-4462-1-git-send-email-zlpwmdx@163.com>
Cc: "liping.zhang" <liping.zhang@spreadtrum.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "liping.zhang" <liping.zhang@spreadtrum.com>

There is no need to use the static variable here, pr_info_once is more
concise.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 net/socket.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index c044d1e..c499784 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1106,12 +1106,8 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 	   deadlock in module load.
 	 */
 	if (family == PF_INET && type == SOCK_PACKET) {
-		static int warned;
-		if (!warned) {
-			warned = 1;
-			pr_info("%s uses obsolete (PF_INET,SOCK_PACKET)\n",
-				current->comm);
-		}
+		pr_info_once("%s uses obsolete (PF_INET,SOCK_PACKET)\n",
+			     current->comm);
 		family = PF_PACKET;
 	}
 
-- 
1.7.9.5
