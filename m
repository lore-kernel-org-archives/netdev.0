From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] net/core: revert "net: fix __netdev_update_features return.." and add comment
Date: Tue, 17 Nov 2015 15:49:06 +0100
Message-ID: <1447771746-17943-1-git-send-email-razor@blackwall.org>
References: <564B3A3E.50905@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:32942 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbbKQOti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:49:38 -0500
Received: by wmec201 with SMTP id c201so231460624wme.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 06:49:37 -0800 (PST)
In-Reply-To: <564B3A3E.50905@cumulusnetworks.com>
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
---
Thanks to Michal for the explanation on why it was made to act like tha=
t.
Also sorry for the noise, unfortunately I missed this. IMO this should'=
ve
been an all or nothing op from the beginning.

 net/core/dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5dbc86ea6b58..ae00b894e675 100644
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
2.4.3
