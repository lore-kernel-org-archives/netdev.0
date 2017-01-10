From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: vrf: do not allow table id 0
Date: Tue, 10 Jan 2017 15:22:25 -0800
Message-ID: <1484090545-16407-1-git-send-email-dsa@cumulusnetworks.com>
Cc: frank.kellermann@atos.net, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33868 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932982AbdAJXWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 18:22:33 -0500
Received: by mail-pf0-f170.google.com with SMTP id 127so54300613pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 15:22:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank reported that vrf devices can be created with a table id of 0.
This breaks many of the run time table id checks and should not be
allowed. Detect this condition at create time and fail with EINVAL.

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Reported-by: Frank Kellermann <frank.kellermann@atos.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 0a067708aa39..454f907d419a 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1252,6 +1252,8 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 
 	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
+	if (vrf->tb_id == RT_TABLE_UNSPEC)
+		return -EINVAL;
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-- 
2.1.4
