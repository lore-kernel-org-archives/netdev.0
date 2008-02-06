From: Chris Caputo <ccaputo@alt.net>
Subject: Re: [PATCH] iputils/ping_common.c: avoid gethostbyaddr during ping
	flood
Date: Wed, 6 Feb 2008 14:02:14 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0802061401370.31285@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([207.14.113.18]:38926 "HELO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750713AbYBFOIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 09:08:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend with whitespace preserved.]

Unless a destination is specified by IP address, a ping flood results in a 
gethostbyaddr() for every echo reply.  Thus a DNS flood can accompany a 
ping flood.
 
This patch makes it so a gethostbyaddr() is not performed with each echo 
reply during a ping flood.

Signed-off-by: Chris Caputo <ccaputo@alt.net>
---
 ping_common.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

===================================================================
diff -ur iputils-s20071127/ping_common.c iputils/ping_common.c
--- iputils-s20071127/ping_common.c	2007-11-27 00:57:27.000000000 +0000
+++ iputils/ping_common.c	2008-02-06 12:38:01.000000000 +0000
@@ -114,10 +114,6 @@
 	case 'd':
 		options |= F_SO_DEBUG;
 		break;
-	case 'f':
-		options |= F_FLOOD;
-		setbuf(stdout, (char *)NULL);
-		break;
 	case 'i':		/* wait between sending packets */
 	{
 		if (strchr(optarg, '.')) {
@@ -168,6 +164,10 @@
 			exit(2);
 		}
 		break;
+	case 'f':
+		options |= F_FLOOD;
+		setbuf(stdout, (char *)NULL);
+		/* fallthrough to numeric - avoid gethostbyaddr during flood */
 	case 'n':
 		options |= F_NUMERIC;
 		break;
