From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v5 0/2] mpls: multipath support
Date: Thu, 22 Oct 2015 17:16:41 -0700
Message-ID: <1445559403-15258-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35357 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757217AbbJWAQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 20:16:48 -0400
Received: by pasz6 with SMTP id z6so100353084pas.2
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 17:16:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for MPLS multipath routes.

Includes following changes to support multipath:
- splits struct mpls_route into 'struct mpls_route + struct mpls_nh'.

- struct mpls_nh represents a mpls nexthop label forwarding entry

- Adds support to parse/fill RTA_MULTIPATH netlink attribute for
multipath routes similar to ipv4/v6 fib

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

Roopa Prabhu (1):
  mpls: multipath support

Robert Shearman (1):
  mpls: flow-based multipath selection

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

----
v2:
	- Incorporate some feedback from Robert:
		use dynamic allocation (list) instead of static allocation
		for nexthops
v3:
	- Move back to arrays (same as v1), also suggested by Eric Biederman

v4:
	- address a few comments from Eric Biederman
	Plan to address the following pending comments in incremental patches after this
	infrastructure changes go in.
	- Move VIA size to 16 bytes
	- use ipv6 flow label in ecmp calculations
	- dead route handling during multipath route selection (I had planned this in
	an incremental patch initially).

v5:
	feedback from Eric Biederman
		- Removed some dead code
	feedback from Robert
		- Moved dev_put into find_outdev to make it clear that we dont need
		a hold on the dev because we are under rtnl
		- move the unused variable fix into the correct patch file

 include/net/mpls_iptunnel.h |   2 +-
 net/mpls/af_mpls.c          | 668 ++++++++++++++++++++++++++++++++++----------
 net/mpls/internal.h         |  57 +++-
 3 files changed, 572 insertions(+), 155 deletions(-)

-- 
1.9.1
