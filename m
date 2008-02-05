From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Make wrr "no available servers" error message rate-limited
Date: Tue,  5 Feb 2008 21:30:21 +0100
Message-ID: <1202243421-2774-1-git-send-email-sven.wegener@stealer.net>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759668AbYBEUxp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No available servers is more an error message than something informational. It
should also be rate-limited, else we're going to flood our logs on a busy
director, if all real servers are out of order with a weight of zero.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---

Actually, do we need this message at all? The wrr scheduler is the only one
printing an error message in such a case.

 net/ipv4/ipvs/ip_vs_wrr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 749fa04..85c680a 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -22,6 +22,7 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/net.h>
 
 #include <net/ip_vs.h>
 
@@ -169,7 +170,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 				 */
 				if (mark->cw == 0) {
 					mark->cl = &svc->destinations;
-					IP_VS_INFO("ip_vs_wrr_schedule(): "
+					IP_VS_ERR_RL("ip_vs_wrr_schedule(): "
 						   "no available servers\n");
 					dest = NULL;
 					goto out;
-- 
1.5.3.7
