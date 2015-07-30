From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v6 0/2] af_mpls: fix undefined reference to ip6_route_output with CONFIG_IPV6=n
Date: Thu, 30 Jul 2015 13:34:52 -0700
Message-ID: <1438288494-32581-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, hannes@stressinduktion.org,
	rshearma@brocade.com, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34338 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbG3Ue7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:34:59 -0400
Received: by pacan13 with SMTP id an13so29187477pac.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 13:34:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series uses ipv6_stub_impl.ipv6_dst_lookup instead of 
ip6_route_output. Follows the vxlan drivers usage of
ipv6_stub_impl.ipv6_dst_lookup.

There is no sk in the af_mpls context from where
ipv6_stub_impl.ipv6_dst_lookup is used. sk appears to be needed
to get the namespace 'net' and is optional otherwise. This patch series
changes ipv6_stub_impl.ipv6_dst_lookup to take net argument. sk remains
optional.

v1 - v2: use IS_BUILTIN

v2 - v3: Use new Kconfig option that depends on (IPV6 || IPV6=n) as
	 suggested by Dave. Also uses IS_ERR as suggested by Thomas.

v3 - v4: Include missed case of (MPLS_ROUTING=y && IPV6=m) reported by
         Dave.

v4 - v5: Use ipv6_stub_impl.ipv6_dst_lookup as suggested by Hannes

v5 - v6: protect against null ipv6_stub by statically declaring
	 a ipv6_dst_lookup NOP func

Roopa Prabhu (2):
  ipv6: change ipv6_stub_impl.ipv6_dst_lookup to take net argument
  af_mpls: fix undefined reference to ip6_route_output

 drivers/net/vxlan.c    |    2 +-
 include/net/addrconf.h |    4 ++--
 include/net/ipv6.h     |    3 ++-
 net/ipv6/icmp.c        |    6 +++---
 net/ipv6/ip6_output.c  |   15 ++++++++-------
 net/mpls/af_mpls.c     |   39 +++++++++++++++++++++++++++++++--------
 net/tipc/udp_media.c   |    3 ++-
 7 files changed, 49 insertions(+), 23 deletions(-)

-- 
1.7.10.4
