From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH]NET:PCNET32: poll method return 0 when done
Date: Thu, 12 Nov 2009 08:13:21 -0800
Message-ID: <1258042401.7727.3.camel@localhost.localdomain>
References: <1257952296.1920.3.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173011pub.verizon.net ([206.46.173.11]:57796 "EHLO
	vms173011pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbZKLQNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 11:13:40 -0500
Received: from [192.168.1.3] ([173.50.157.101]) by vms173011.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KT0007OP7Q9KFR0@vms173011.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 12 Nov 2009 10:13:23 -0600 (CST)
In-reply-to: <1257952296.1920.3.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do not understand why you are suggesting this change.  With NAPI
the amount of work done is returned on exit, not zero.  All other
drivers I have looked at do not force a zero on exit.

NAK

Don

-----Original Message-----
From: Figo.zhang <figo1802@gmail.com>
To: David S. Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>
Subject: [PATCH]NET:PCNET32: poll method return 0 when done
Date: Wed, 11 Nov 2009 23:11:36 +0800

Poll method return 0 when it is done.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/pcnet32.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index c1b3f09..58894a3 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1396,6 +1396,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (work_done < budget) {
+		work_done = 0;
 		spin_lock_irqsave(&lp->lock, flags);
 
 		__napi_complete(napi);


--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

