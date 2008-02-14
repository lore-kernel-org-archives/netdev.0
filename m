From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH][IPROUTE2]Add missing prefix bit length for addrlabel
Date: Thu, 14 Feb 2008 15:21:08 +0530
Message-ID: <20080214152108.96f45614.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44253 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765448AbYBNJrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 04:47:25 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1E9lN8F023986
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 04:47:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1E9lPEJ170974
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 02:47:25 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1E9lOPU018918
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 02:47:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The prefix bit lenght value was not updated, resulting in incorrect addrlabel
entry. This patch fixes that issue.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 ip/ipaddrlabel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 1c873e9..a4cdece 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -173,6 +173,7 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 
 	addattr32(&req.n, sizeof(req), IFAL_LABEL, label);
 	addattr_l(&req.n, sizeof(req), IFAL_ADDRESS, &prefix.data, prefix.bytelen);
+	req.ifal.ifal_prefixlen = prefix.bitlen;
 
 	if (req.ifal.ifal_family == AF_UNSPEC)
 		req.ifal.ifal_family = AF_INET6;
-- 
1.5.0.6

