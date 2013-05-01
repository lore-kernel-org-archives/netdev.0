From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] net: sctp: attribute printl with __printf for gcc fmt checks
Date: Wed,  1 May 2013 14:59:23 +0200
Message-ID: <1367413163-2817-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468Ab3EAM70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 08:59:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let GCC check for format string errors in sctp's probe printl
function. This patch fixes the warning when compiled with W=1:

net/sctp/probe.c:73:2: warning: function might be possible candidate
for 'gnu_printf' format attribute [-Wmissing-format-attribute]

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index ad0dba8..e62c225 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -63,7 +63,7 @@ static struct {
 	struct timespec	  tstart;
 } sctpw;
 
-static void printl(const char *fmt, ...)
+static __printf(1, 2) void printl(const char *fmt, ...)
 {
 	va_list args;
 	int len;
-- 
1.7.11.7
