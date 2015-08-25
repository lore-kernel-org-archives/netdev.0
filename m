From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 3/5] net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
Date: Tue, 25 Aug 2015 15:50:13 -0700
Message-ID: <1440543015-14693-4-git-send-email-f.fainelli@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33475 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659AbbHYWxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:51 -0400
Received: by pacti10 with SMTP id ti10so65117697pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:51 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_L2_ONLY interfaces are Layer-2 only network devices and do not
support configuration of IPv6 addresses, nor the full IPv6 protocol
stack. Do nothing for these interfaces.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/ipv6/addrconf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0f08d3b9e238..0365b5ffe339 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3161,6 +3161,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	int run_pending = 0;
 	int err;
 
+	if (dev->flags & IFF_L2_ONLY)
+		goto out;
+
 	switch (event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
@@ -3304,6 +3307,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		addrconf_type_change(dev, event);
 		break;
 	}
+out:
 
 	return NOTIFY_OK;
 }
-- 
2.1.0
