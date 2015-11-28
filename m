From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/5] get rid of unnecessary fgets() buffer size limitation
Date: Sat, 28 Nov 2015 01:00:05 +0100
Message-ID: <1448668805-28074-6-git-send-email-phil@nwl.cc>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34384 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbK1AAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:31 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fgets() will read at most size-1 bytes into the buffer and add a
terminating null-char at the end. Therefore it is not necessary to pass
a reduced buffer size when calling it.

This change was generated using the following semantic patch:

@@
identifier buf, fp;
@@
- fgets(buf, sizeof(buf) - 1, fp)
+ fgets(buf, sizeof(buf), fp)

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/arpd.c | 2 +-
 misc/ss.c   | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index 7919eb8b36bb7..6bb9bd16bc46c 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -703,7 +703,7 @@ int main(int argc, char **argv)
 		}
 
 		buf[sizeof(buf)-1] = 0;
-		while (fgets(buf, sizeof(buf)-1, fp)) {
+		while (fgets(buf, sizeof(buf), fp)) {
 			__u8 b1[6];
 			char ipbuf[128];
 			char macbuf[128];
diff --git a/misc/ss.c b/misc/ss.c
index d509009429de1..0dab32ceff594 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2729,7 +2729,7 @@ static int unix_show(struct filter *f)
 
 	if ((fp = net_unix_open()) == NULL)
 		return -1;
-	if (!fgets(buf, sizeof(buf)-1, fp)) {
+	if (!fgets(buf, sizeof(buf), fp)) {
 		fclose(fp);
 		return -1;
 	}
@@ -2738,7 +2738,7 @@ static int unix_show(struct filter *f)
 		newformat = 1;
 	cnt = 0;
 
-	while (fgets(buf, sizeof(buf)-1, fp)) {
+	while (fgets(buf, sizeof(buf), fp)) {
 		struct sockstat *u, **insp;
 		int flags;
 
@@ -3217,12 +3217,12 @@ static int netlink_show(struct filter *f)
 
 	if ((fp = net_netlink_open()) == NULL)
 		return -1;
-	if (!fgets(buf, sizeof(buf)-1, fp)) {
+	if (!fgets(buf, sizeof(buf), fp)) {
 		fclose(fp);
 		return -1;
 	}
 
-	while (fgets(buf, sizeof(buf)-1, fp)) {
+	while (fgets(buf, sizeof(buf), fp)) {
 		sscanf(buf, "%llx %d %d %x %d %d %llx %d",
 		       &sk,
 		       &prot, &pid, &groups, &rq, &wq, &cb, &rc);
-- 
2.5.0
