From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] net: fix feature changes on devices without ndo_set_features
Date: Fri, 13 Nov 2015 14:54:01 +0100
Message-ID: <1447422841-2333-1-git-send-email-razor@blackwall.org>
References: <5645C0A5.2080506@cumulusnetworks.com>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jarod Wilson <jarod@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36136 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbKMNye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 08:54:34 -0500
Received: by wmww144 with SMTP id w144so29613587wmw.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 05:54:33 -0800 (PST)
In-Reply-To: <5645C0A5.2080506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When __netdev_update_features() was updated to ensure some features are
disabled on new lower devices, an error was introduced for devices which
don't have the ndo_set_features() method set. Before we'll just set the
new features, but now we return an error and don't set them. Fix this by
returning the old behaviour and setting err to 0 when ndo_set_features
is not present.

Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
CC: Jarod Wilson <jarod@redhat.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Ido Schimmel <idosch@mellanox.com>
CC: Sander Eikelenboom <linux@eikelenboom.it>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Sander please feel free to give your Tested-by.

 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9b8d0d115e..4a1d198dbbff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6426,6 +6426,8 @@ int __netdev_update_features(struct net_device *dev)
 
 	if (dev->netdev_ops->ndo_set_features)
 		err = dev->netdev_ops->ndo_set_features(dev, features);
+	else
+		err = 0;
 
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
-- 
2.4.3
