From: Sohny Thomas <sthomas@linux.vnet.ibm.com>
Subject: [PATCH] iproute2: xfrm state add abort issue
Date: Fri, 27 Sep 2013 00:02:12 +0530
Message-ID: <52447DAC.2060701@linux.vnet.ibm.com>
References: <524411AE.7000404@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:42187 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999Ab3IZScT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:32:19 -0400
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sthomas@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 00:02:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7D7D9125803F
	for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 00:02:27 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QIYUKr39190664
	for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 00:04:30 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QIWDYa022528
	for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 00:02:13 +0530
In-Reply-To: <524411AE.7000404@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip xfrm state add causes a SIGABRT due to a strncpy_chk .
This happens since strncpy doesn't account for the '\0' .
I have fixed this using sizeof  instead of strlen .

There is a redhat bug which documents this issue

https://bugzilla.redhat.com/show_bug.cgi?id=982761

Signed-off-by: Sohny Thomas <sohthoma@in.ibm.com>

--------------

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 389942c..7dd8799 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -117,7 +117,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, 
enum xfrm_attr_type_t type,
                             char *name, char *key, char *buf, int max)
   {
          int len;
-       int slen = strlen(key);
+       int slen = sizeof(key);

   #if 0
          /* XXX: verifying both name and key is required! */
