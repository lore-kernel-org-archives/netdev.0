From: Stefano Brivio <sbrivio@redhat.com>
Subject: [iproute PATCH v2 2/3] ss: Streamline process context printing in netlink_show_one()
Date: Tue, 31 Oct 2017 18:47:55 +0100
Message-ID: <e09c1c3ce34d932e10299bd4a41380d43a5a1a8d.1509471878.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932501AbdJaRsl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:48:41 -0400
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to check 'pid_context' before calling free().

Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 misc/ss.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index fa026eb0934b..fb80d84122fc 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3593,12 +3593,8 @@ static int netlink_show_one(struct filter *f,
 		else if (pid > 0)
 			getpidcon(pid, &pid_context);
 
-		if (pid_context != NULL) {
-			printf(" proc_ctx=%s", pid_context);
-			free(pid_context);
-		} else {
-			printf(" proc_ctx=unavailable");
-		}
+		printf(" proc_ctx=%s", pid_context ? : "unavailable");
+		free(pid_context);
 	}
 
 	if (show_details) {
-- 
2.9.4
