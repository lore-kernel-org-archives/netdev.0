From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge: reserve space for IFLA_BRPORT_FAST_LEAVE
Date: Mon, 11 Mar 2013 16:52:17 -0700
Message-ID: <20130311165217.760e80fe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:42822 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab3CKXwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 19:52:25 -0400
Received: by mail-ie0-f179.google.com with SMTP id k11so5534671iea.38
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 16:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge multicast fast leave feature was added sufficient space
was not reserved in the netlink message. This means the flag may be
lost in netlink events and results of queries.

Found by observation while looking up some netlink stuff for discussion with Vlad.
Problem introduced by commit c2d3babfafbb9f6629cfb47139758e59a5eb0d80
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Dec 5 16:24:45 2012 -0500

    bridge: implement multicast fast leave

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Should go to net and stable for 3.8.X

--- a/net/bridge/br_netlink.c	2013-03-07 18:12:53.885287247 -0800
+++ b/net/bridge/br_netlink.c	2013-03-11 16:44:34.759166273 -0700
@@ -29,6 +29,7 @@ static inline size_t br_port_info_size(v
 		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
+		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
 		+ 0;
 }
 
