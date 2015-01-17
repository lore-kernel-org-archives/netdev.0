From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/2] vxlan: Don't use UDP socket for transmit
Date: Sat, 17 Jan 2015 10:18:18 -0800
Message-ID: <1421518700-22460-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:48477 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbAQSSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 13:18:36 -0500
Received: by mail-ie0-f170.google.com with SMTP id y20so1235611ier.1
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 10:18:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP socket is not pertinent to transmit for UDP tunnels, checksum
enablement can be done with a socket. This patch set eliminates
reference to a socket in udp_tunnel_xmit functions and in VXLAN
trnasmit.

Also, make GBP, RCO, can CSUM6_RX flags visible to receive socket
and only match these for shareable socket.
Tom Herbert (2):
  udp: Do not require sock in udp_tunnel_xmit_skb
  vxlan: Eliminate dependency on UDP socket in transmit path

 drivers/net/vxlan.c           | 66 +++++++++++++++++++++----------------------
 include/net/udp_tunnel.h      | 16 +++++------
 include/net/vxlan.h           | 13 +++++----
 net/ipv4/udp_tunnel.c         | 12 ++++----
 net/ipv6/ip6_udp_tunnel.c     | 12 ++++----
 net/openvswitch/vport-vxlan.c |  6 ++--
 6 files changed, 62 insertions(+), 63 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
