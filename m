From: Erik Nordmark <nordmark@arista.com>
Subject: [PATCH net] ipv6: Allow IPv4-mapped address as next-hop
Date: Mon, 28 Nov 2016 15:27:05 -0800
Message-ID: <76e59d76-7905-bb14-43d6-d4aaba51f0f9@arista.com>
References: <20161128181000.CED72D3427AA@us153.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bob Gilligan <gilligan@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32855 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755515AbcK1X1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:27:06 -0500
Received: by mail-pf0-f179.google.com with SMTP id d2so27437620pfd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 15:27:06 -0800 (PST)
In-Reply-To: <20161128181000.CED72D3427AA@us153.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Made kernel accept IPv6 routes with IPv4-mapped address as next-hop.

It is possible to configure IP interfaces with IPv4-mapped addresses, and
one can add IPv6 routes for IPv4-mapped destinations/prefixes, yet prior
to this fix the kernel returned an EINVAL when attempting to add an IPv6
route with an IPv4-mapped address as a nexthop/gateway.

RFC 4798 (a proposed standard RFC) uses IPv4-mapped addresses as nexthops,
thus in order to support that type of address configuration the kernel
needs to allow IPv4-mapped addresses as nexthops.

Signed-off-by: Erik Nordmark <nordmark@arista.com>
Signed-off-by: Bob Gilligan <gilligan@arista.com>"

Index: net/net/ipv6/route.c
===================================================================
--- net.orig/net/ipv6/route.c
+++ net/net/ipv6/route.c
@@ -1995,8 +1995,11 @@ static struct rt6_info *ip6_route_info_c
  			   It is very good, but in some (rare!) circumstances
  			   (SIT, PtP, NBMA NOARP links) it is handy to allow
  			   some exceptions. --ANK
+			   We allow IPv4-mapped nexthops to support RFC4798-type
+			   addressing
  			 */
-			if (!(gwa_type & IPV6_ADDR_UNICAST))
+			if (!(gwa_type & (IPV6_ADDR_UNICAST |
+					  IPV6_ADDR_MAPPED)))
  				goto out;
  
  			if (cfg->fc_table) {
