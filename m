From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv4: loopback device: ignore value changes after device is upped
Date: Tue,  7 Jan 2014 15:55:45 +0100
Message-ID: <1389106545-7940-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:53599 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaAGOzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 09:55:50 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so100595eek.41
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 06:55:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When lo is brought up, new ifa is created. Then, devconf and neigh values
bitfield should be set so later changes of default values would not
affect lo values.

Note that the same behaviour is in ipv6. Also note that this is likely
not an issue in many distros (for example Fedora 19) because userspace
sets address to lo manually before bringing it up.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/devinet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0feebd5..9809f7b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1385,6 +1385,8 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 				set_ifa_lifetime(ifa, INFINITY_LIFE_TIME,
 						 INFINITY_LIFE_TIME);
+				ipv4_devconf_setall(in_dev);
+				neigh_parms_data_state_setall(in_dev->arp_parms);
 				inet_insert_ifa(ifa);
 			}
 		}
-- 
1.8.3.1
