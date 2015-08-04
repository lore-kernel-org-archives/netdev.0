From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v6] af_mpls: add null dev check in find_outdev
Date: Tue,  4 Aug 2015 06:34:06 -0700
Message-ID: <1438695246-22575-1-git-send-email-roopa@cumulusnetworks.com>
Cc: dan.carpenter@oracle.com, ebiederm@xmission.com,
	rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33959 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933077AbbHDNeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 09:34:10 -0400
Received: by pawu10 with SMTP id u10so8873960paw.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 06:34:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds null dev check for the 'cfg->rc_via_table ==
NEIGH_LINK_TABLE or dev_get_by_index() failed' case

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index b6b9a6c..3ea90ff 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -416,6 +416,9 @@ static struct net_device *find_outdev(struct net *net,
 		dev = dev_get_by_index(net, cfg->rc_ifindex);
 	}
 
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
 	return dev;
 }
 
-- 
1.7.10.4
