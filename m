From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] net: fix __netdev_update_features return on ndo_set_features failure
Date: Fri, 13 Nov 2015 15:20:24 +0100
Message-ID: <1447424424-4419-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35420 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbKMOV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 09:21:26 -0500
Received: by wmdw130 with SMTP id w130so30910052wmd.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 06:21:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

If ndo_set_features fails __netdev_update_features() will return -1 but
this is wrong because it is expected to return 0 if no features were
changed (see netdev_update_features()), which will cause a netdev
notifier to be called without any actual changes. Fix this by returning
0 if ndo_set_features fails.

=46ixes: 6cb6a27c45ce ("net: Call netdev_features_change() from netdev_=
update_features()")
CC: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4a1d198dbbff..1974aee005a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6433,7 +6433,7 @@ int __netdev_update_features(struct net_device *d=
ev)
 		netdev_err(dev,
 			"set_features() failed (%d); wanted %pNF, left %pNF\n",
 			err, &features, &dev->features);
-		return -1;
+		return 0;
 	}
=20
 sync_lower:
--=20
2.4.3
