From: Robert Shearman <rshearma@brocade.com>
Subject: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Mon, 1 Jun 2015 17:46:12 +0100
Message-ID: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>, Thomas Graf <tgraf@suug.ch>,
	Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41214 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbbFAQsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 12:48:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to function as a Label Edge Router in an MPLS
network, it is necessary to be able to take IP packets and impose an
MPLS encap and forward them out. The traditional approach of setting
up an interface for each "tunnel" endpoint doesn't scale for the
common MPLS use-cases where each IP route tends to be assigned a
different label as encap.

The solution suggested here for further discussion is to provide the
facility to define encap data on a per-nexthop basis using a new
netlink attribue, RTA_ENCAP, which would be opaque to the IPv4/IPv6
forwarding code, but interpreted by the virtual interface assigned to
the nexthop.

A new ipmpls interface type is defined to show the use of this
facility to allow IP packets to be imposed with an MPLS
encap. However, the facility is designed to be general enough to be
used by any encapsulation/tunneling mechanism that has similar
requirements of high-scale, high-variation-of-encap.

RFC because:
 - IPv6 side not implemented
 - struct rtable shouldn't be bloated by pointer+uint
 - Hasn't been thoroughly tested yet

Robert Shearman (3):
  net: infra for per-nexthop encap data
  ipv4: storing and retrieval of per-nexthop encap
  mpls: new ipmpls device for encapsulating IP packets as mpls

 include/linux/rtnetlink.h      |   7 +
 include/net/dst.h              |  11 ++
 include/net/dst_ops.h          |   2 +
 include/net/ip_fib.h           |   2 +
 include/net/route.h            |   3 +
 include/net/rtnetlink.h        |  11 ++
 include/uapi/linux/if_arp.h    |   1 +
 include/uapi/linux/rtnetlink.h |   1 +
 net/core/rtnetlink.c           |  36 ++++++
 net/ipv4/fib_frontend.c        |   3 +
 net/ipv4/fib_lookup.h          |   2 +
 net/ipv4/fib_semantics.c       | 179 +++++++++++++++++++++++++-
 net/ipv4/route.c               |  24 ++++
 net/mpls/Kconfig               |   5 +
 net/mpls/Makefile              |   1 +
 net/mpls/af_mpls.c             |   2 +
 net/mpls/ipmpls.c              | 284 +++++++++++++++++++++++++++++++++++++++++
 17 files changed, 572 insertions(+), 2 deletions(-)
 create mode 100644 net/mpls/ipmpls.c

-- 
2.1.4
