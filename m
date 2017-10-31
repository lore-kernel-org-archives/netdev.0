From: Stefano Brivio <sbrivio@redhat.com>
Subject: [iproute PATCH v2 1/3] ss: Remove useless width specifier in process context print
Date: Tue, 31 Oct 2017 18:47:54 +0100
Message-ID: <163c37d7aa5230112e1e332467090a92d5836332.1509471878.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60009 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932381AbdJaRsk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:48:40 -0400
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
In-Reply-To: <cover.1509471877.git.sbrivio@redhat.com>
References: <cover.1509471877.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both local address and service, and remote address and service
fields are already printed out in netlink_show_one() before we
start printing process context, by calling sock_addr_print()
twice.

At this point, sock_addr_print() has already forced the remote
service field to be 'serv_width' wide -- that is, 'serv_width'
width has already been consumed, before we print process
context.

Hence, it makes no sense to force the display width of process
context to be 'serv_width' wide again: previous prints have
filled up the line already. Remove the width specifier and
prefix with a space instead, to keep this consistent with fields
which are displayed after the first output line.

Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 misc/ss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index dfb438f9162c..fa026eb0934b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3594,10 +3594,10 @@ static int netlink_show_one(struct filter *f,
 			getpidcon(pid, &pid_context);
 
 		if (pid_context != NULL) {
-			printf("proc_ctx=%-*s ", serv_width, pid_context);
+			printf(" proc_ctx=%s", pid_context);
 			free(pid_context);
 		} else {
-			printf("proc_ctx=%-*s ", serv_width, "unavailable");
+			printf(" proc_ctx=unavailable");
 		}
 	}
 
-- 
2.9.4
