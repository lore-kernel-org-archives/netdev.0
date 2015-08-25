From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 2/5] net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
Date: Tue, 25 Aug 2015 15:50:12 -0700
Message-ID: <1440543015-14693-3-git-send-email-f.fainelli@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34022 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbbHYWxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:50 -0400
Received: by pabzx8 with SMTP id zx8so47371820pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:50 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_L2_ONLY interfaces are Layer-2 only and do not support configuration
of IPv4 addresses, nor the full IPv4 protocol stack. Do nothing for
these interfaces.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/ipv4/devinet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2d9cb1748f81..30068754e821 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1383,6 +1383,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	ASSERT_RTNL();
 
 	if (!in_dev) {
+		if (dev->flags & IFF_L2_ONLY)
+			goto out;
+
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
 			if (IS_ERR(in_dev))
-- 
2.1.0
