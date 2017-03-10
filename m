From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v3 0/2] mpls: allow TTL propagation to/from IP packets to be configured
Date: Fri, 10 Mar 2017 20:43:23 +0000
Message-ID: <1489178605-30027-1-git-send-email-rshearma@brocade.com>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:53485 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932372AbdCJUn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 15:43:58 -0500
In-Reply-To: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is sometimes desirable to present an MPLS transport network as a
single hop to traffic transiting it because it prevents confusion when
diagnosing failures. An example of where confusion can be generated is
when addresses used in the provider network overlap with addresses in
the overlay network and the addresses get exposed through ICMP errors
generated as packets transit the provider network.

In addition, RFC 3443 defines two methods of deriving TTL for an
outgoing packet: Uniform Model where the TTL is propagated to/from the
MPLS header and both Pipe Models and Short Pipe Models (with and
without PHP) where the TTL is not propagated to/from the MPLS header.

Changes in v3:
 - decrement ttl on popping last label when not doing ttl propagation,
   as suggested by David Ahern.
 - add comment to describe what the somewhat complex conditionals are
   doing to work out what ttl to use in mpls_iptunnel.c.
 - rearrange fields fields in struct netns_mpls to keep the platform
   label fields together, as suggested by David Ahern.

Changes in v2:
 - add references to RFC 3443 as suggested by David Ahern
 - fix setting of skb->protocol as noticed by David Ahern
 - implement per-route/per-LWT configurability as suggested by Eric
   Biederman
 - split into two patches for ease of review

Robert Shearman (2):
  mpls: allow TTL propagation to IP packets to be configured
  mpls: allow TTL propagation from IP packets to be configured

 Documentation/networking/mpls-sysctl.txt | 19 +++++++
 include/net/mpls_iptunnel.h              |  2 +
 include/net/netns/mpls.h                 |  3 +
 include/uapi/linux/mpls_iptunnel.h       |  2 +
 include/uapi/linux/rtnetlink.h           |  1 +
 net/mpls/af_mpls.c                       | 98 +++++++++++++++++++++++++++++---
 net/mpls/internal.h                      |  7 +++
 net/mpls/mpls_iptunnel.c                 | 73 +++++++++++++++++++-----
 8 files changed, 184 insertions(+), 21 deletions(-)

-- 
2.1.4
