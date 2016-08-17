From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next 0/3] net: mpls: fragmentation and gso fixes for locally originated traffic
Date: Wed, 17 Aug 2016 14:49:44 -0700
Message-ID: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com,
	alexander.duyck@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33000 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbcHQVvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 17:51:05 -0400
Received: by mail-pa0-f41.google.com with SMTP id ti13so244197pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:51:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes mtu and fragmentation for tunnels using lwtunnel
output redirect, and fixes GSO for MPLS for locally originated traffic
reported by Lennert Buytenhek.

A follow on series will address fragmentation and GSO for forwarded
MPLS traffic. Hardware offload of GSO with MPLS also needs to be
addressed.

v2
- consistent use of network_header in skb to fix GSO for MPLS
- update MPLS code in OVS to network_header and inner_network_header

David Ahern (2):
  net: mpls: Fixups for GSO
  net: veth: Set features for MPLS

Roopa Prabhu (1):
  net: lwtunnel: Handle fragmentation

 drivers/net/veth.c        |  1 +
 include/net/lwtunnel.h    | 44 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c       | 35 +++++++++++++++++++++++++++++++++++
 net/ipv4/ip_output.c      |  8 ++++++++
 net/ipv4/route.c          |  4 +++-
 net/ipv6/ip6_output.c     |  8 ++++++++
 net/ipv6/route.c          |  4 +++-
 net/mpls/mpls_gso.c       | 24 +++++++++++++-----------
 net/mpls/mpls_iptunnel.c  | 14 ++++++++++----
 net/openvswitch/actions.c |  6 ++++++
 10 files changed, 131 insertions(+), 17 deletions(-)

-- 
2.1.4
