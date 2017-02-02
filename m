From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: Set protocol to kernel for local routes
Date: Thu,  2 Feb 2017 08:52:21 -0800
Message-ID: <1486054341-22589-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33552 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbdBBQw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:52:27 -0500
Received: by mail-pg0-f51.google.com with SMTP id 204so7110829pge.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:52:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 stack does not set the protocol for local routes, so those routes show
up with proto "none":
    $ ip -6 ro ls table local
    local ::1 dev lo proto none metric 0  pref medium
    local 2100:3:: dev lo proto none metric 0  pref medium
    local 2100:3::4 dev lo proto none metric 0  pref medium
    local fe80:: dev lo proto none metric 0  pref medium
    ...

Set rt6i_protocol to RTPROT_KERNEL for consistency with IPv4. Now routes
show up with proto "kernel":
    $ ip -6 ro ls table local
    local ::1 dev lo proto kernel metric 0  pref medium
    local 2100:3:: dev lo proto kernel metric 0  pref medium
    local 2100:3::4 dev lo proto kernel metric 0  pref medium
    local fe80:: dev lo proto kernel metric 0  pref medium
    ...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2563331b0532..91eb3f7782dd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2634,6 +2634,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.output = ip6_output;
 	rt->rt6i_idev = idev;
 
+	rt->rt6i_protocol = RTPROT_KERNEL;
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
 		rt->rt6i_flags |= RTF_ANYCAST;
-- 
2.1.4
