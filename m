From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/7] [PKT_SCHED] Fix dsmark to count ignored indices while walking
Date: Fri, 27 May 2005 16:50:58 +0200
Message-ID: <20050527145058.GS15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Unused indices which are ignored while walking must still
be counted to avoid dumping the same index twice.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 99ed2eb92cc035b223e2d383446f7f183600ba27
tree 127116412eeedf62fcda0acc882500cd981cbab1
parent e66646bb6686bb1be24e25b3743028f762544de2
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:29:52 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:29:52 +0200

 net/sched/sch_dsmark.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- 735126283c38e22995f5da71b2e90a9d71ac4b1e/net/sched/sch_dsmark.c  (mode:100644)
+++ 127116412eeedf62fcda0acc882500cd981cbab1/net/sched/sch_dsmark.c  (mode:100644)
@@ -163,14 +163,15 @@
 		return;
 	for (i = 0; i < p->indices; i++) {
 		if (p->mask[i] == 0xff && !p->value[i])
-			continue;
+			goto ignore;
 		if (walker->count >= walker->skip) {
 			if (walker->fn(sch, i+1, walker) < 0) {
 				walker->stop = 1;
 				break;
 			}
 		}
-                walker->count++;
+ignore:		
+		walker->count++;
         }
 }
 
