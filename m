From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: send unsolicited NA on admin up
Date: Wed, 12 Apr 2017 11:49:04 -0700
Message-ID: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
Cc: hannes@stressinduktion.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33052 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754445AbdDLStK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 14:49:10 -0400
Received: by mail-pf0-f173.google.com with SMTP id s16so17740076pfs.0
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 11:49:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndisc_notify is the ipv6 equivalent to arp_notify. When arp_notify is
set to 1, gratuitous arp requests are sent when the device is brought up.
The same is expected when ndisc_notify is set to 1 (per ndisc_notify in
Documentation/networking/ip-sysctl.txt). The NA is not sent on NETDEV_UP
event; add it.

Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/ndisc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b5812b3f7539..b23822e64228 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1748,6 +1748,8 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);
 		fib6_run_gc(0, net, false);
+		/* fallthrough */
+	case NETDEV_UP:
 		idev = in6_dev_get(dev);
 		if (!idev)
 			break;
-- 
2.1.4
