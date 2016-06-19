From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/5] ipv6: better traceroute support in sit and gre
Date: Sat, 18 Jun 2016 21:52:01 -0700
Message-ID: <1466311926-27167-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33422 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbcFSEwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 00:52:14 -0400
Received: by mail-pa0-f51.google.com with SMTP id b13so40403939pat.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 21:52:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit ca15a078bd90 ("sit: generate icmpv6 error when receiving icmpv4
error"), Oussama Ghorbel added minimal support for SIT tunnels to
generate ICMPv6 messages when receiving ICMPv4 messages.

This patch series extends this to GRE tunnels.

It also adds support for ICMPV6_TIME_EXCEED.

Partial support for RFC 4884 is added, to forward ICMP Multi-part
extensions eventually found in the ICMPv4 message.

v2: replaced an overlapping memcpy() by memmove()

Eric Dumazet (5):
  ipv6: icmp: add a force_saddr param to icmp6_send()
  ip6: move ipip6_err_gen_icmpv6_unreach()
  ipv6: translate ICMP_TIME_EXCEEDED to ICMPV6_TIME_EXCEED
  gre: better support for ICMP messages for gre+ipv6
  ipv6: RFC 4884 partial support for SIT/GRE tunnels

 include/linux/icmpv6.h    |  5 +++-
 include/net/ip_tunnels.h  |  1 +
 include/uapi/linux/icmp.h |  1 +
 net/ipv4/gre_demux.c      |  1 +
 net/ipv4/ip_gre.c         |  9 ++++++
 net/ipv6/icmp.c           | 72 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6_icmp.c       |  2 +-
 net/ipv6/sit.c            | 44 ++++-------------------------
 8 files changed, 92 insertions(+), 43 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
