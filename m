From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6]: Fix RTNLGRP_IPV6_IFINFO netlink notifications
Date: Fri, 09 Jun 2006 00:56:46 +0200
Message-ID: <4488AB2E.3030301@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080505080200010706080303"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42183 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965036AbWFHW5S
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 18:57:18 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080505080200010706080303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080505080200010706080303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV6]: Fix RTNLGRP_IPV6_IFINFO netlink notifications

The allocated skb is too small for the message, which results in an EINVAL
getting reported to the (innocent) multicast listeners.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f71bc8ace692302ad3a80d84b8cbccbb14e88fe5
tree 21ccfa89e911ff8e6bda04ab817367f2ac4e3173
parent 1def630a6a49dda5bc89dfbd86656293640456f0
author Patrick McHardy <kaber@trash.net> Wed, 07 Jun 2006 09:25:26 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 07 Jun 2006 09:25:26 +0200

 net/ipv6/addrconf.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 445006e..cc81cab 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3235,8 +3235,7 @@ static int inet6_dump_ifinfo(struct sk_b
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
-	/* 128 bytes ?? */
-	int size = NLMSG_SPACE(sizeof(struct ifinfomsg)+128);
+	int size = NLMSG_SPACE(sizeof(struct ifinfomsg)+172);
 	
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb) {

--------------080505080200010706080303--
