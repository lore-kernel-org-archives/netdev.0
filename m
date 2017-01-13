From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/2] mpls: Packet stats
Date: Fri, 13 Jan 2017 18:14:11 +0000
Message-ID: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, <ebiederm@xmission.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51011 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750713AbdAMSPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:15:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset records per-interface packet stats in the MPLS
forwarding path and exports them using a nest of attributes root at a
new IFLA_STATS_AF_SPEC attribute as part of RTM_GETSTATS messages:

[IFLA_STATS_AF_SPEC]
 -> [AF_MPLS]
  -> [MPLS_STATS_LINK]
   -> struct mpls_link_stats

The first patch adds the rtnl infrastructure for this, including a new
callbacks to per-AF ops of fill_stats_af and get_stats_af_size. The
second patch records MPLS stats and makes use of the infrastructure to
export them. The rtnl infrastructure could also be used to export IPv6
stats in the future.

Robert Shearman (2):
  net: AF-specific RTM_GETSTATS attributes
  mpls: Packet stats

 include/net/rtnetlink.h      |   4 +
 include/uapi/linux/if_link.h |   1 +
 include/uapi/linux/mpls.h    |  30 ++++++++
 net/core/rtnetlink.c         |  50 ++++++++++++
 net/mpls/af_mpls.c           | 179 +++++++++++++++++++++++++++++++++++++------
 net/mpls/internal.h          |  58 +++++++++++++-
 net/mpls/mpls_iptunnel.c     |  11 ++-
 7 files changed, 305 insertions(+), 28 deletions(-)

-- 
2.1.4
