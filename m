From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v4 2/3] macvtap: Correctly set tap features when IFF_VNET_HDR is disabled.
Date: Fri, 16 Aug 2013 15:25:01 -0400
Message-ID: <1376681102-19753-3-git-send-email-vyasevic@redhat.com>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab3HPW0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 18:26:50 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7GJP8cS018579
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:25:08 -0400
In-Reply-To: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user turns off IFF_VNET_HDR flag, attempts to change
offload features via TUNSETOFFLOAD do not work.  This could cause
GSO packets to be delivered to the user when the user is
not prepared to handle them.

To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
disabled.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 448f8a5..4acfbce 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1163,10 +1163,6 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			    TUN_F_TSO_ECN | TUN_F_UFO))
 			return -EINVAL;
 
-		/* TODO: only accept frames with the features that
-			 got enabled for forwarded frames */
-		if (!(q->flags & IFF_VNET_HDR))
-			return  -EINVAL;
 		rtnl_lock();
 		ret = set_offload(q, arg);
 		rtnl_unlock();
-- 
1.8.1.4
