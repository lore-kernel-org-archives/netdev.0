From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH][IPv6]: Fix incorrect length check in rawv6_sendmsg()
Date: Thu, 29 Mar 2007 14:17:28 -0700
Message-ID: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53143 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030738AbXC2VRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 17:17:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2TLHWGp028083
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 17:17:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2TLHWgZ257932
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 17:17:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2TLHVAY030667
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 17:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check for length in rawv6_sendmsg() is incorrect.
As len is an unsigned int, (len < 0) will never be TRUE.
I think checking for IPV6_MAXPLEN(65535) is better.

Is it possible to send ipv6 jumbo packets using raw
sockets? If so, we can remove this check.

Thanks
Sridhar

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 306d5d8..dc11ec3 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -686,10 +686,7 @@ static int rawv6_sendmsg(struct kiocb *i
 	u16 proto;
 	int err;
 
-	/* Rough check on arithmetic overflow,
-	   better check is made in ip6_build_xmit
-	 */
-	if (len < 0)
+	if (len > IPV6_MAXPLEN)
 		return -EMSGSIZE;
 
 	/* Mirror BSD error message compatibility */


