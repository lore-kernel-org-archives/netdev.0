From: dmitry.krivoschekov@gmail.com
Subject: [PATCH 1/3] ipconfig: use same time units for CONF_{PRE,POST}_OPEN delays
Date: Thu, 16 Apr 2009 13:37:37 +0400
Message-ID: <1239874659-19273-2-git-send-email-dmitry.krivoschekov@gmail.com>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Cc: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:10136 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752395AbZDPJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:36:11 -0400
In-Reply-To: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>

It's confusing that the delay before opening is measured in msecs
while after opening the delay is in seconds. Lets use the same
time units for both.

Signed-off-by: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
---
 net/ipv4/ipconfig.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index da134aa..4c6e38f 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -87,7 +87,7 @@
 
 /* Define the friendly delay before and after opening net devices */
 #define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
-#define CONF_POST_OPEN		1	/* After opening: 1 second */
+#define CONF_POST_OPEN		1000	/* After opening: 1 second */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
@@ -1291,7 +1291,7 @@ static int __init ip_auto_config(void)
 		return -1;
 
 	/* Give drivers a chance to settle */
-	ssleep(CONF_POST_OPEN);
+	msleep(CONF_POST_OPEN);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
-- 
1.6.1.2.MVISTA.5.ga9f3b

