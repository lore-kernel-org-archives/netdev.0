From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] pptp: fix sparse pointer warning
Date: Thu, 8 Aug 2013 10:27:14 -0700
Message-ID: <20130808102714.6f16ff43@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:63689 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965673Ab3HHR1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 13:27:17 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so3574069pbc.1
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 10:27:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

callid_sock array is referenced via rcu_dereference and
sparse rcu checks complains about address space mismatch.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ppp/pptp.c	2013-05-11 15:58:52.472353116 -0700
+++ b/drivers/net/ppp/pptp.c	2013-07-30 14:40:52.602172742 -0700
@@ -47,7 +47,7 @@
 #define MAX_CALLID 65535
 
 static DECLARE_BITMAP(callid_bitmap, MAX_CALLID + 1);
-static struct pppox_sock **callid_sock;
+static struct pppox_sock __rcu **callid_sock;
 
 static DEFINE_SPINLOCK(chan_lock);
 
