From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/5 net-next-2.6] [TIPC]: Fix bug in topology server byte swapping routine
Date: Tue, 13 May 2008 14:17:43 -0400
Message-ID: <1210702665-5012-4-git-send-email-allan.stephens@windriver.com>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35532 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714AbYEMSSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:18:16 -0400
In-Reply-To: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes TIPC's topology server so that it does byte swapping
correctly when endianness conversion is required.  (Note: This bug only
impacted an application if it issues a subscription request to a
topology server on another node, rather than the server on it's own
node; since the topology server is normally not accessible by off-node
applications, most TIPC applications were not impacted by the bug.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/subscr.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index a62e5d3..dde23f1 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -86,9 +86,7 @@ static struct top_srv topsrv = { 0 };
 
 static u32 htohl(u32 in, int swap)
 {
-	char *c = (char *)&in;
-
-	return swap ? ((c[3] << 3) + (c[2] << 2) + (c[1] << 1) + c[0]) : in;
+	return swap ? (u32)___constant_swab32(in) : in;
 }
 
 /**
-- 
1.5.3.2

