From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: send unsolicited NA if enabled for all interfaces
Date: Wed, 19 Apr 2017 12:05:36 -0700
Message-ID: <1492628736-26696-1-git-send-email-dsa@cumulusnetworks.com>
Cc: hannes@stressinduktion.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:35653 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969179AbdDSTFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 15:05:47 -0400
Received: by mail-yb0-f170.google.com with SMTP id 6so11727915ybq.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 12:05:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When arp_notify is set to 1 for either a specific interface or for 'all'
interfaces, gratuitous arp requests are sent. Since ndisc_notify is the
ipv6 equivalent to arp_notify, it should follow the same semantics.
Commit 4a6e3c5def13 sends the NA on admin up. The final piece is checking
devconf_all->ndisc_notify in addition to the per device setting. Add it.

Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/ndisc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b23822e64228..d310dc41209a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1753,7 +1753,8 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 		idev = in6_dev_get(dev);
 		if (!idev)
 			break;
-		if (idev->cnf.ndisc_notify)
+		if (idev->cnf.ndisc_notify ||
+		    net->ipv6.devconf_all->ndisc_notify)
 			ndisc_send_unsol_na(dev);
 		in6_dev_put(idev);
 		break;
-- 
2.1.4
