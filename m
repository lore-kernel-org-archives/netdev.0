From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v2 1/4] net/core: revert "net: fix __netdev_update_features return.." and add comment
Date: Wed, 18 Nov 2015 13:24:31 +0900
Message-ID: <1447820674-5481-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35564 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbbKREYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 23:24:45 -0500
Received: by pacej9 with SMTP id ej9so31108875pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 20:24:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This reverts commit 00ee59271777 ("net: fix __netdev_update_features re=
turn
on ndo_set_features failure")
and adds a comment explaining why it's okay to return a value other tha=
n
0 upon error. Some drivers might actually change flags and return an
error so it's better to fire a spurious notification rather than miss
these.

CC: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5dbc86e..ae00b89 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6436,7 +6436,10 @@ int __netdev_update_features(struct net_device *=
dev)
 		netdev_err(dev,
 			"set_features() failed (%d); wanted %pNF, left %pNF\n",
 			err, &features, &dev->features);
-		return 0;
+		/* return non-0 since some features might have changed and
+		 * it's better to fire a spurious notification than miss it
+		 */
+		return -1;
 	}
=20
 sync_lower:
--=20
2.6.0.rc2.230.g3dd15c0
