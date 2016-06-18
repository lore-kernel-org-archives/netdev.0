From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/5] ipv6: better traceroute support in sit and gre
Date: Sat, 18 Jun 2016 16:26:35 -0700
Message-ID: <1466292400-3638-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35790 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcFRX0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:26:50 -0400
Received: by mail-pf0-f169.google.com with SMTP id c2so41875919pfa.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:26:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit ca15a078bd90 ("sit: generate icmpv6 error when receiving icmpv4
error"), Oussama Ghorbel added minimal support for SIT tunnels to
generate ICMPv6 messages when receiving ICMPv4 messages.

This patch series extends this to GRE tunnels.

It also adds support for ICMPV6_TIME_EXCEED.

Partial support for RFC 4884 is added, to forward ICMP Multi-part
extensions eventually found in the ICMPv4 message.

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
