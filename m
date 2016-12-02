From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next] ss: initialise variables outside of for loop
Date: Fri,  2 Dec 2016 12:56:05 +0100
Message-ID: <1480679765-9014-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f169.google.com ([209.85.210.169]:36422 "EHLO
        mail-wj0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753298AbcLBL4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 06:56:11 -0500
Received: by mail-wj0-f169.google.com with SMTP id qp4so230118741wjc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 03:56:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialise for loops outside of for loops. GCC flags this as being
out of spec unless C99 or C11 mode is used.

With this change the entire tree appears to compile cleanly with -Wall.

$ gcc --version
gcc (Debian 4.9.2-10) 4.9.2
...
$ make
...
ss.c: In function ‘unix_show_sock’:
ss.c:3128:4: error: ‘for’ loop initial declarations are only allowed in C99 or C11 mode
...

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 misc/ss.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 839781ee29bc..ce0b9d3d993d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3124,10 +3124,12 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 
 		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
 		name[len] = '\0';
-		if (name[0] == '\0')
-			for (int i = 0; i < len; i++)
+		if (name[0] == '\0') {
+			int i;
+			for (i = 0; i < len; i++)
 				if (name[i] == '\0')
 					name[i] = '@';
+		}
 		stat.name = &name[0];
 		memcpy(stat.local.data, &stat.name, sizeof(stat.name));
 	}
-- 
2.7.0.rc3.207.g0ac5344
