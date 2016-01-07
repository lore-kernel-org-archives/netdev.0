From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 0/5] Local Checksum Offload
Date: Thu, 7 Jan 2016 17:10:17 +0000
Message-ID: <568E9BF9.2050001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:36231 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752189AbcAGRKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:10:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with a VXLAN tunnel over a device that doesn't support inner checksum
 offload (so the checksum will have been done in sw by validate_xmit_skb()).

Changes from v1:
 * Enabled support in more encapsulation protocols.
   I think it now covers everything except GRE.
 * Wrote up some documentation covering TX checksum offload, LCO and RCO.

Edward Cree (5):
  net: local checksum offload for encapsulation
  net: enable LCO for udp_tunnel_handle_offloads() users
  net: vxlan: enable local checksum offload
  fou: enable LCO in FOU and GUE
  Documentation/networking: add tx-offloads.txt to explain LCO

 Documentation/networking/00-INDEX        |   2 +
 Documentation/networking/tx-offloads.txt | 122 +++++++++++++++++++++++++++++++
 drivers/net/vxlan.c                      |   4 +-
 include/linux/skbuff.h                   |  26 +++++++
 include/net/udp_tunnel.h                 |   3 +-
 net/ipv4/fou.c                           |   5 +-
 net/ipv4/ip_tunnel_core.c                |   4 +
 net/ipv4/udp.c                           |  29 +++-----
 net/ipv6/ip6_checksum.c                  |  24 ++----
 9 files changed, 178 insertions(+), 41 deletions(-)
 create mode 100644 Documentation/networking/tx-offloads.txt
