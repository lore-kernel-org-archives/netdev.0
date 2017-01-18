From: David Arcari <darcari@redhat.com>
Subject: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Wed, 18 Jan 2017 08:34:05 -0500
Message-ID: <1484746445-97920-1-git-send-email-darcari@redhat.com>
Cc: David Arcari <darcari@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51200 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752125AbdARNec (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 08:34:32 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3CFCC270F39
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 13:34:33 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user executes 'ethtool -d' for an interface and the associated
get_regs_len() function returns 0, the user will see a call trace from
the vmalloc() call in ethtool_get_regs().  This patch modifies
ethtool_get_regs() to avoid the call to vmalloc when the size is zero.

Signed-off-by: David Arcari <darcari@redhat.com>
---
 net/core/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e23766c..47acd6f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1405,7 +1405,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	if (regs.len > reglen)
 		regs.len = reglen;
 
-	regbuf = vzalloc(reglen);
+	regbuf = reglen ? vzalloc(reglen) : NULL;
 	if (reglen && !regbuf)
 		return -ENOMEM;
 
