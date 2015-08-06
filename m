From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 3/6] misc/ss: simplify buffer realloc, fix checking realloc failure
Date: Thu,  6 Aug 2015 14:24:33 +0200
Message-ID: <1438863876-1935-3-git-send-email-phil@nwl.cc>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
 <1438863876-1935-2-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53287 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395AbbHFMYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:38 -0400
In-Reply-To: <1438863876-1935-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index af5a3c2..e77655a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -550,7 +550,7 @@ static int find_entry(unsigned ino, char **buf, int type)
 	struct user_ent *p;
 	int cnt = 0;
 	char *ptr;
-	char **new_buf = buf;
+	char *new_buf;
 	int len, new_buf_len;
 	int buf_used = 0;
 	int buf_len = 0;
@@ -592,12 +592,12 @@ static int find_entry(unsigned ino, char **buf, int type)
 
 			if (len < 0 || len >= buf_len - buf_used) {
 				new_buf_len = buf_len + ENTRY_BUF_SIZE;
-				*new_buf = realloc(*buf, new_buf_len);
+				new_buf = realloc(*buf, new_buf_len);
 				if (!new_buf) {
 					fprintf(stderr, "ss: failed to malloc buffer\n");
 					abort();
 				}
-				*buf = *new_buf;
+				*buf = new_buf;
 				buf_len = new_buf_len;
 				continue;
 			} else {
-- 
2.1.2
