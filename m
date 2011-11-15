From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH net-next] IPv6: Removing unnecessary NULL checks introduced
 in 4a287eba2de395713d8b2b2aeaa69fa086832d34.
Date: Tue, 15 Nov 2011 12:58:59 +0200
Message-ID: <1321354739.1858.72.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:12834 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959Ab1KOKrK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 05:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch removes unnecessary NULL checks noticed by Dan Carpenter.
Checks were introduced in commit
4a287eba2de395713d8b2b2aeaa69fa086832d34 to net-next.


Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
--
diff -uNr commit4a287eba2de395713d8b2b2aeaa69fa086832d34.orig/net/ipv6/ip6_fib.c commit4a287eba2de395713d8b2b2aeaa69fa086832d34.new/net/ipv6/ip6_fib.c
--- commit4a287eba2de395713d8b2b2aeaa69fa086832d34.orig/net/ipv6/ip6_fib.c	2011-11-15 12:17:37.000000000 +0200
+++ commit4a287eba2de395713d8b2b2aeaa69fa086832d34.new/net/ipv6/ip6_fib.c	2011-11-15 12:25:59.000000000 +0200
@@ -635,10 +635,9 @@
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
-	int replace = (NULL != info &&
-	    NULL != info->nlh &&
+	int replace = (NULL != info->nlh &&
 	    (info->nlh->nlmsg_flags&NLM_F_REPLACE));
-	int add = ((NULL == info || NULL == info->nlh) ||
+	int add = (NULL == info->nlh ||
 	    (info->nlh->nlmsg_flags&NLM_F_CREATE));
 	int found = 0;
 
@@ -755,7 +754,7 @@
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	if (NULL != info && NULL != info->nlh) {
+	if (NULL != info->nlh) {
 		if (!(info->nlh->nlmsg_flags&NLM_F_CREATE))
 			allow_create = 0;
 		if ((info->nlh->nlmsg_flags&NLM_F_REPLACE))





-- 
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
...but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
