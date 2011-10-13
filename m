From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH] Fix unterminated readlink() buffer usage
Date: Thu, 13 Oct 2011 10:30:21 +0200
Message-ID: <201110131030.21723.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:50276 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab1JMIaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 04:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 misc/ss.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index b00841b..1353620 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -273,13 +273,19 @@ static void user_ent_hash_build(void)
 			unsigned int ino;
 			char lnk[64];
 			int fd;
+			ssize_t link_len;
 
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;
 
 			sprintf(name+pos, "%d", fd);
-			if (readlink(name, lnk, sizeof(lnk)-1) < 0 ||
-			    strncmp(lnk, pattern, strlen(pattern)))
+
+			link_len = readlink(name, lnk, sizeof(lnk)-1);
+			if (link_len == -1)
+				continue;
+			lnk[link_len] = '\0';
+
+			if (strncmp(lnk, pattern, strlen(pattern)))
 				continue;
 
 			sscanf(lnk, "socket:[%u]", &ino);
-- 
1.7.4.4
