From: Sachin Sant <sachinp@in.ibm.com>
Subject: [Patch -next] Fix net/3c503.c build break
Date: Fri, 04 Sep 2009 16:06:02 +0530
Message-ID: <4AA0ED92.6070306@in.ibm.com>
References: <20090904182309.dbb05c96.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090602070800010308000501"
Cc: linux-next@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:35889 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbZIDKgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 06:36:02 -0400
In-Reply-To: <20090904182309.dbb05c96.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090602070800010308000501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Today's Next failed to build on a x86 box with following error.

drivers/net/3c503.c: In function 'el2_open':
drivers/net/3c503.c:406: error: 'reval' undeclared (first use in this function)
drivers/net/3c503.c:406: error: (Each undeclared identifier is reported only once
drivers/net/3c503.c:406: error: for each function it appears in.)

Most probably because of commit ab08999d6029bb2c79c16be5405d63d2bedbdfea
The patch had a typo in it. Below patch fixes the issue for me.

Thanks
-Sachin



--------------090602070800010308000501
Content-Type: text/x-patch;
 name="net-3c503-typo-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net-3c503-typo-fix.patch"

Fix a build break because of a typo in drivers/net/3c503.c

Signed-off-by: Sachin Sant <sachinp@in.ibm.com>
---
diff -Naurp a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	2009-09-04 15:50:06.000000000 +0530
+++ b/drivers/net/3c503.c	2009-09-04 15:50:41.000000000 +0530
@@ -403,7 +403,7 @@ el2_open(struct net_device *dev)
 		    break;
 	    } else {
 		    if (retval != -EBUSY)
-			    return reval;
+			    return retval;
 	    }
 	} while (*++irqp);
 	if (*irqp == 0) {

--------------090602070800010308000501--
