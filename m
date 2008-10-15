From: Steven Whitehouse <swhiteho@redhat.com>
Subject: decnet: Fix complier warning
Date: Wed, 15 Oct 2008 13:19:19 +0100
Message-ID: <1224073160.25004.85.camel@quoit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christine Caulfield <ccaulfie@redhat.com>
To: davem@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45909 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549AbYJOMUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 08:20:48 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id m9FCKmYY015119
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2008 08:20:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a warning seen during compiling dn_dev.c. The warning is harmless
since we know that the structure length in question is less than 2^32 bytes, but
this fixes it anyway.

Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
Cc: Christine Caulfield <ccaulfie@redhat.com>

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 2f0ac3c..d9bc69c 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -152,7 +152,7 @@ static struct dn_dev_parms dn_dev_list[] =  {
 
 #define DN_DEV_LIST_SIZE ARRAY_SIZE(dn_dev_list)
 
-#define DN_DEV_PARMS_OFFSET(x) ((int) ((char *) &((struct dn_dev_parms *)0)->x))
+#define DN_DEV_PARMS_OFFSET(x) ((long) ((char *) &((struct dn_dev_parms *)0)->x))
 
 #ifdef CONFIG_SYSCTL
 


