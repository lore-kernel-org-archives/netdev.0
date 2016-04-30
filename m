From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 0/7]  net: Cleanup IPv6 ip tunnels
Date: Fri, 29 Apr 2016 17:12:14 -0700
Message-ID: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17854 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbcD3AOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:39 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3U0Aemc004700
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22ktssq743-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:37 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 852a3ed60e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IPv6 tunnel code is very different from IPv4 code. There is a lot
of redundancy with the IPv4 code, particularly in the GRE tunneling.

This patch set cleans up the tunnel code to make the IPv6 code look
more like the IPv4 code and use common functions between the two
stacks where possible.

This work should make it easier to maintain and extend the IPv6 ip
tunnels.

Items in this patch set:
  - Cleanup IPv6 tunnel receive path (ip6_tnl_rcv). Includes using
    gro_cells and exporting ip6_tnl_rcv so the ip6_gre can call it
  - Move GRE functions to common header file (tx functions) or
    gre_demux.c (rx functions like gre_parse_header)
  - Call common GRE functions from IPv6 GRE
  - Create ip6_tnl_xmit (to be like ip_tunnel_xmit)

Tested:
  Ran super_netperf tests for TCP_RR and TCP_STREAM for:
    - IPv4 over gre, gretap, gre6, gre6tap
    - IPv6 over gre, gretap, gre6, gre6tap
    - ipip
    - ip6ip6
    - ipip/gue
    - IPv6 over gre/gue
    - IPv4 over gre/gue

Tom Herbert (7):
  ipv6: Cleanup IPv6 tunnel receive path
  gre: Move utility functions to common headers
  gre6: Cleanup GREv6 receive path, call common GRE functions
  ipv6: Create ip6_tnl_xmit
  gre: Create common functions for transmit
  ipv6: Generic tunnel cleanup
  gre6: Cleanup GREv6 transmit path, call common GRE functions

 include/net/gre.h        | 104 +++++++++++++
 include/net/ip6_tunnel.h |  11 +-
 net/ipv4/gre_demux.c     |  64 ++++++++
 net/ipv4/ip_gre.c        | 199 +++---------------------
 net/ipv6/ip6_gre.c       | 392 +++++++++--------------------------------------
 net/ipv6/ip6_tunnel.c    | 266 +++++++++++++++++++++-----------
 6 files changed, 452 insertions(+), 584 deletions(-)

-- 
2.8.0.rc2
