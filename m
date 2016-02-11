From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 0/8] Local Checksum Offload
Date: Thu, 11 Feb 2016 20:46:00 +0000
Message-ID: <alpine.LFD.2.20.1602112024140.14893@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:35664 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067AbcBKUqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 15:46:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-tested VxLAN; everything else is unchanged from v4.

Changes from v4:
 * Rebased series to fix conflicts with vxlan/vxlan6 merge.

Changes from v3:
 * Fixed inverted checksum values introduced in v3.
 * Don't mangle zero checksums in GRE.
 * Clear skb->encapsulation in iptunnel_handle_offloads when not using
   CHECKSUM_PARTIAL, lest drivers incorrectly interpret that as a request
   for inner checksum offload.

Changes from v2:
 * Added support for IPv4 GRE.
 * Split out 'always set up for checksum offload' into its own patch.
 * Removed csum_help from iptunnel_handle_offloads.
 * Rewrote LCO callers to only fold once.
 * Simplified nocheck handling.

Changes from v1:
 * Enabled support in more encapsulation protocols.
   I think it now covers everything except GRE.
 * Wrote up some documentation covering TX checksum offload, LCO and RCO.

Edward Cree (8):
  net: local checksum offload for encapsulation
  net: udp: always set up for CHECKSUM_PARTIAL offload
  net: enable LCO for udp_tunnel_handle_offloads() users
  net: vxlan: enable local checksum offload
  fou: enable LCO in FOU and GUE
  net: gre: Implement LCO for GRE over IPv4
  net: ip_tunnel: remove 'csum_help' argument to iptunnel_handle_offloads
  Documentation/networking: add checksum-offloads.txt to explain LCO

 Documentation/networking/00-INDEX              |   2 +
 Documentation/networking/checksum-offloads.txt | 119 +++++++++++++++++++++++++
 drivers/net/vxlan.c                            |   6 +-
 include/linux/skbuff.h                         |  26 ++++++
 include/net/ip_tunnels.h                       |   3 +-
 include/net/udp_tunnel.h                       |   2 +-
 net/ipv4/fou.c                                 |  14 ++-
 net/ipv4/ip_gre.c                              |  17 +++-
 net/ipv4/ip_tunnel_core.c                      |  22 ++---
 net/ipv4/ipip.c                                |   2 +-
 net/ipv4/udp.c                                 |  28 ++----
 net/ipv6/ip6_checksum.c                        |  23 ++---
 net/ipv6/sit.c                                 |   4 +-
 net/netfilter/ipvs/ip_vs_xmit.c                |   6 +-
 14 files changed, 197 insertions(+), 77 deletions(-)
 create mode 100644 Documentation/networking/checksum-offloads.txt
