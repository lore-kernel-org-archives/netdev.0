From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 0/3] net: mpls: fragmentation and gso fixes for locally originated traffic
Date: Wed, 24 Aug 2016 20:10:42 -0700
Message-ID: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
        ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
        tgraf@suug.ch, olivier.dugeon@orange.com,
        alexander.duyck@gmail.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35222 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752013AbcHYFEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 01:04:47 -0400
Received: by mail-pf0-f169.google.com with SMTP id x72so14037647pfd.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 22:03:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes mtu and fragmentation for tunnels using lwtunnel
output redirect, and fixes GSO for MPLS for locally originated traffic
reported by Lennert Buytenhek.

A follow on series will address fragmentation and GSO for forwarded
MPLS traffic. Hardware offload of GSO with MPLS also needs to be
addressed.

Simon: Can you verify this works with OVS for single and multiple
       labels?

v4
- more updates to mpls_gso_segment per Alex's comments (thanks, Alex)
- updates to teaching OVS about marking MPLS labels as the network header
 
v3
- updates to mpls_gso_segment per Alex's comments
- dropped skb->encapsulation = 1 from mpls_xmit per Alex's comment

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
 net/mpls/mpls_gso.c       | 40 +++++++++++++++++++++++++++++-----------
 net/mpls/mpls_iptunnel.c  | 13 +++++++++----
 net/openvswitch/actions.c |  9 +++++++--
 10 files changed, 147 insertions(+), 19 deletions(-)

-- 
2.1.4
