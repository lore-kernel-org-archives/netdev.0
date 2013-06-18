From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vxlan: fix check for migration of static entry
Date: Tue, 18 Jun 2013 14:27:01 -0700
Message-ID: <1371590821-1125-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:45250 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932799Ab3FRV1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 17:27:06 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so4331575pbc.4
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 14:27:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check introduced by:
	commit 26a41ae604381c5cc0caf1c3261ca6b298b5fe69
	Author: stephen hemminger <stephen@networkplumber.org>
	Date:   Mon Jun 17 12:09:58 2013 -0700

	    vxlan: only migrate dynamic FDB entries

was not correct because it is checking flag about type of FDB
entry, rather than the state (dynamic versus static). The confusion
arises because vxlan is reusing values from bridge, and bridge is
reusing values from neighbour table, and easy to get lost in translation.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index dda997a..57325f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -579,7 +579,7 @@ static bool vxlan_snoop(struct net_device *dev,
 			return false;
 
 		/* Don't migrate static entries, drop packets */
-		if (!(f->flags & NTF_SELF))
+		if (f->state & NUD_NOARP)
 			return true;
 
 		if (net_ratelimit())
-- 
1.7.10.4
