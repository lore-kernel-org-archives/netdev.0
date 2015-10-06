From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] mpls: multipath support
Date: Tue,  6 Oct 2015 11:46:47 -0700
Message-ID: <1444157209-12518-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34194 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbbJFSqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:46:54 -0400
Received: by padhy16 with SMTP id hy16so77619028pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:46:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for MPLS multipath routes.

Includes following changes to support multipath:
- splits struct mpls_route into 'struct mpls_route + struct mpls_nh'.

- struct mpls_nh represents a mpls nexthop label forwarding entry

- Adds support to parse/fill RTA_MULTIPATH netlink attribute for
multipath routes similar to ipv4/v6 fib

- In this series the multipath route nexthop selection
algorithm starts with a simple round robin and is replaced by a hash
based algorithm from Robert Shearman in the last patch

- In the process of restructuring, this patch also consistently changes all
labels to u8

$ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
		nexthop as 700 via inet 10.1.1.6 dev swp2 \
		nexthop as 800 via inet 40.1.1.2 dev swp3

$ip  -f mpls route show
100 
	nexthop as to 200 via inet 10.1.1.2  dev swp1
	nexthop as to 700 via inet 10.1.1.6  dev swp2
	nexthop as to 800 via inet 40.1.1.2  dev swp3

Roopa Prabhu (2):
  mpls: multipath support
  mpls: flow-based multipath selection

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

----
Changes since v1:
	- Incorporate some feedback from Robert:
		use dynamic allocation (list) instead of static allocation
		for nexthops
	- include flow hash based multipath selection from Robert
		

 include/net/mpls_iptunnel.h |   2 +-
 net/mpls/af_mpls.c          | 668 ++++++++++++++++++++++++++++++++++----------
 net/mpls/internal.h         |  57 +++-
 3 files changed, 572 insertions(+), 155 deletions(-)

-- 
1.9.1
