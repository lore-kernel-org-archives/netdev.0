From: Chris Caputo <ccaputo@alt.net>
Subject: Re: [PATCH] iputils/ping_common.c: avoid gethostbyaddr during ping
	flood
Date: Thu, 17 Jun 2010 01:08:43 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1006170104000.26819@nacho.alt.net>
References: <Pine.LNX.4.64.0802061401370.31285@nacho.alt.net>
Reply-To: Chris Caputo <ccaputo-dated-1287104923.1c8263@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, Yoshifuji Hideaki <yoshfuji@skbuff.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:33897 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab0FQBPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 21:15:25 -0400
In-Reply-To: <Pine.LNX.4.64.0802061401370.31285@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Feb 2008, Chris Caputo wrote:
> Unless a destination is specified by IP address, a ping flood results in a 
> gethostbyaddr() for every echo reply.  Thus a DNS flood can accompany a 
> ping flood.

Updated for iputils-s20100418...  Can someone review and work into next 
release?

Thanks,
Chris

---
Unless a destination is specified by IP address, a ping flood results in a
gethostbyaddr() for every echo reply.  Thus a DNS flood can accompany a
ping flood.

This patch makes it so a gethostbyaddr() is not performed with each echo
reply during a ping flood.

Signed-off-by: Chris Caputo <ccaputo@alt.net>
-------
--- iputils-s20100418/ping_common.c	2010-04-18 04:45:45.000000000 +0000
+++ iputils-dev/ping_common.c	2010-06-17 01:00:59.000000000 +0000
@@ -118,10 +118,6 @@ void common_options(int ch)
 	case 'D':
 		options |= F_PTIMEOFDAY;
 		break;
-	case 'f':
-		options |= F_FLOOD;
-		setbuf(stdout, (char *)NULL);
-		break;
 	case 'i':		/* wait between sending packets */
 	{
 		if (strchr(optarg, '.')) {
@@ -183,6 +179,10 @@ void common_options(int ch)
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
