From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 0/5] iproute: Add FOU and GUE configuration in ip
Date: Fri,  3 Oct 2014 08:55:13 -0700
Message-ID: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47311 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbaJCPzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:55:40 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so1702581pad.36
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:55:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support in iproute2 to configure FOU and GUE ports
for receive, and using FOU or GUE with ip tunnels (IPIP, GRE, sit) on
transmit.

A new ip subcommand "fou" has been added to configure FOU/GUE ports.
For example:

  ip fou add port 5555 gue 
  ip fou add port 9999 ipproto 4

The first command creates a GUE port, the second creates a direct FOU
port for IPIP (receive payload is a assumed to be an IP packet).

To configure an IP tunnel to use FOU or GUE encap parameters have
been added. For example:

  ip link add name tun1 type ipip remote 192.168.1.1 local 192.168.1.2 \
     ttl 225 encap gue encap-sport auto encap-dport 7777 encap-csum
  ip link add name tun2 type gre remote 192.168.1.1 local 192.168.1.2 \
     ttl 225 encap fou encap-sport auto encap-dport 8888 encap-csum

The first command configures an IPIP tunnel to use GUE on transmit. The
peer might be configured to receive GUE packets with the
"ip fou add port 7777 gue" command.

The second configures a GRE tunnel to use FOU encapsulation. The
peer might be configured to receive these packets with the
"ip fou add port 8888 ipproto 47" command.

Tom Herbert (5):
  iplink: Fix setting of -1 as ifindex
  ip fou: Support to configure foo-over-udp RX
  ip tunnel: Kernel uapi definitions for fou and gue
  ip link ipip: Add support to configure FOU and GUE
  ip link gre: Add support to configure FOU and GUE

 include/linux/fou.h       |  41 ++++++++++++
 include/linux/if_tunnel.h |  17 +++++
 ip/Makefile               |   3 +-
 ip/ip.c                   |   3 +-
 ip/ip_common.h            |   1 +
 ip/ipfou.c                | 158 ++++++++++++++++++++++++++++++++++++++++++++++
 ip/iplink.c               |   2 +-
 ip/link_gre.c             |  89 ++++++++++++++++++++++++++
 ip/link_iptnl.c           |  89 ++++++++++++++++++++++++++
 9 files changed, 400 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/fou.h
 create mode 100644 ip/ipfou.c

-- 
2.1.0.rc2.206.gedb03e5
