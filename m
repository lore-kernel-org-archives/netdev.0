From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 0/2] mpls: allow TTL propagation to/from IP packets to be configured
Date: Wed, 8 Mar 2017 00:46:28 +0000
Message-ID: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59163 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756532AbdCHAsl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 19:48:41 -0500
In-Reply-To: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
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

Changes in v2:
 - add references to RFC 3443 as suggested by David Ahern
 - fix setting of skb->protocol as noticed by David Ahern
 - implement per-route/per-LWT configurability as suggested by Eric
   Biederman
 - split into two patches for ease of review

Robert Shearman (2):
  mpls: allow TTL propagation to IP packets to be configured
  mpls: allow TTL propagation from IP packets to be configured

 Documentation/networking/mpls-sysctl.txt | 19 ++++++
 include/net/mpls_iptunnel.h              |  2 +
 include/net/netns/mpls.h                 |  3 +
 include/uapi/linux/mpls_iptunnel.h       |  2 +
 include/uapi/linux/rtnetlink.h           |  1 +
 net/mpls/af_mpls.c                       | 99 ++++++++++++++++++++++++++------
 net/mpls/internal.h                      |  7 +++
 net/mpls/mpls_iptunnel.c                 | 64 ++++++++++++++++-----
 8 files changed, 168 insertions(+), 29 deletions(-)

-- 
2.1.4
