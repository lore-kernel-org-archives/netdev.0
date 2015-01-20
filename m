From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/2] vxlan: Don't use UDP socket for transmit
Date: Tue, 20 Jan 2015 11:23:03 -0800
Message-ID: <1421781785-24557-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, tgraf@suug.ch, jesse@nicira.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33238 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbATTXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 14:23:18 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so14205014iec.0
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 11:23:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP socket is not pertinent to transmit for UDP tunnels, checksum
enablement can be done without a socket. This patch set eliminates
reference to a socket in udp_tunnel_xmit functions and in VXLAN
transmit.

Also, make GBP, RCO, can CSUM6_RX flags visible to receive socket
and only match these for shareable socket.

v2: Fix geneve to call udp_tunnel_xmit with good arguments.

Tom Herbert (2):
  udp: Do not require sock in udp_tunnel_xmit_skb
  vxlan: Eliminate dependency on UDP socket in transmit path

 drivers/net/vxlan.c           | 66 +++++++++++++++++++++----------------------
 include/net/udp_tunnel.h      | 16 +++++------
 include/net/vxlan.h           | 13 +++++----
 net/ipv4/geneve.c             |  5 ++--
 net/ipv4/udp_tunnel.c         | 12 ++++----
 net/ipv6/ip6_udp_tunnel.c     | 12 ++++----
 net/openvswitch/vport-vxlan.c |  6 ++--
 7 files changed, 65 insertions(+), 65 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
