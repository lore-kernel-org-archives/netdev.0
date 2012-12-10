From: Jan Synacek <jsynacek@redhat.com>
Subject: Re: [PATCH 2/2 fixed] ping6: Fix -F switch.
Date: Mon, 10 Dec 2012 11:12:54 +0100
Message-ID: <50C5B5A6.7020201@redhat.com>
References: <1354868724-15549-1-git-send-email-jsynacek@redhat.com> <1354868724-15549-3-git-send-email-jsynacek@redhat.com> <50C5B24F.5030900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jsynacek@redhat.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040Ab2LJKM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 05:12:58 -0500
In-Reply-To: <50C5B24F.5030900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even when the flowlabel is set correctly, ping6 exits with a warning. The errno
should be checked only if the previous call returned a negative value. In this
case, there is no need to check errno, checking for a negative value is enough.

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ping6.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ping6.c b/ping6.c
index 358a035..94a24b0 100644
--- a/ping6.c
+++ b/ping6.c
@@ -724,8 +724,9 @@ int main(int argc, char *argv[])
 	while ((ch = getopt(argc, argv, COMMON_OPTSTR "F:N:")) != EOF) {
 		switch(ch) {
 		case 'F':
-			flowlabel = hextoui(optarg);
-			if (errno || (flowlabel & ~IPV6_FLOWINFO_FLOWLABEL)) {
+			err = hextoui(optarg);
+			flowlabel = (__u32)err;
+			if (err < 0 || (flowlabel & ~IPV6_FLOWINFO_FLOWLABEL)) {
 				fprintf(stderr, "ping: Invalid flowinfo %s\n", optarg);
 				exit(2);
 			}
-- 
1.8.0.1
