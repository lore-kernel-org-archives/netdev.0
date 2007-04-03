From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/2] [iputils] Re-probe at same TTL after MTU reduction.
Date: Tue,  3 Apr 2007 14:20:35 -0400
Message-ID: <11756244353377-git-send-email-jheffner@psc.edu>
References: <1175624435275-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:58796 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbXDCTSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 15:18:25 -0400
In-Reply-To: <1175624435275-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a bug that would miss a hop after an ICMP packet too big message,
since it would continue increase the TTL without probing again.
---
 tracepath.c  |    6 ++++++
 tracepath6.c |    6 ++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index d035a1e..19b2c6b 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -352,8 +352,14 @@ main(int argc, char **argv)
 			exit(1);
 		}
 
+restart:
 		for (i=0; i<3; i++) {
+			int old_mtu;
+			
+			old_mtu = mtu;
 			res = probe_ttl(fd, ttl);
+			if (mtu != old_mtu)
+				goto restart;
 			if (res == 0)
 				goto done;
 			if (res > 0)
diff --git a/tracepath6.c b/tracepath6.c
index a010218..65c4a4a 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -422,8 +422,14 @@ int main(int argc, char **argv)
 			exit(1);
 		}
 
+restart:
 		for (i=0; i<3; i++) {
+			int old_mtu;
+			
+			old_mtu = mtu;
 			res = probe_ttl(fd, ttl);
+			if (mtu != old_mtu)
+				goto restart;
 			if (res == 0)
 				goto done;
 			if (res > 0)
-- 
1.5.0.2.gc260-dirty

