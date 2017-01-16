From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] vxlan: fix byte order of vxlan-gpe port number
Date: Mon, 16 Jan 2017 18:37:58 -0500
Message-ID: <1484609878-7288-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46310 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750990AbdAPXiA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 18:38:00 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E9388C0099FE
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 23:38:00 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan->cfg.dst_port is in network byte order, so an htons()
is needed here. Also reduced comment length to stay closer
to 80 column width (still slightly over, however).

Fixes: e1e5314de08b ("vxlan: implement GPE")
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca7196c..8a79cfc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2890,7 +2890,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
 	if (!vxlan->cfg.dst_port) {
 		if (conf->flags & VXLAN_F_GPE)
-			vxlan->cfg.dst_port = 4790; /* IANA assigned VXLAN-GPE port */
+			vxlan->cfg.dst_port = htons(4790); /* IANA VXLAN-GPE port */
 		else
 			vxlan->cfg.dst_port = default_port;
 	}
-- 
2.5.5
