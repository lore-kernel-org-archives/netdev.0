From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 2/2] bnx2/bnx2x: Unsupported Ethtool operations should return -EINVAL.
Date: Thu, 21 Oct 2010 14:30:43 -0700
Message-ID: <1287696643-9695-2-git-send-email-jesse@nicira.com>
References: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60093 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758404Ab0JUVay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:30:54 -0400
Received: by fxm16 with SMTP id 16so79870fxm.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:30:52 -0700 (PDT)
In-Reply-To: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cards don't support changing vlan offloading settings.  Make
Ethtool set_flags return -EINVAL in those cases.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/bnx2.c                |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index bf3c830..062600b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7528,7 +7528,7 @@ bnx2_set_flags(struct net_device *dev, u32 data)
 
 	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN) &&
 	    !(data & ETH_FLAG_RXVLAN))
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH | ETH_FLAG_RXVLAN |
 				  ETH_FLAG_TXVLAN);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index daefef6..d02ffbd 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1123,7 +1123,7 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 	}
 
 	if (!(data & ETH_FLAG_RXVLAN))
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if ((data & ETH_FLAG_LRO) && bp->rx_csum && bp->disable_tpa)
 		return -EINVAL;
-- 
1.7.1

