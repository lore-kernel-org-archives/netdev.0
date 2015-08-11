From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] mpls: multipath support
Date: Tue, 11 Aug 2015 14:45:45 -0700
Message-ID: <1439329548-50935-1-git-send-email-roopa@cumulusnetworks.com>
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35845 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbbHKVpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 17:45:55 -0400
Received: by pdco4 with SMTP id o4so87924036pdc.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 14:45:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series adds multipath support to mpls routes.

resembles ipv4 multipath support. The multipath route nexthop
selection algorithm is the same code as in ipv4 fib code.

I understand that the multipath algorithm in ipv4 is undergoing
some changes and will move mpls to similar algo if applicable once
those get merged.

mpls multipath support can be moved under CONFIG_MPLS_ROUTE_MULTIPATH if
needed similar to CONFIG_IP_ROUTE_MULTIPATH. I started with that
but that resulted in too many #ifdef CONFIG_MPLS_ROUTE_MULTIPATH
throughout the af_mpls code. If there is a strong reason
to introduce a config option, I will respin v2 with
CONFIG_MPLS_ROUTE_MULTIPATH. These multipath patches do not introduce
any UAPI changes.

example iproute2 usage:
$ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
	nexthop as 300 via inet 10.1.1.6 dev swp2

$ip -f mpls route show
100 
	nexthop as to 200 via inet 10.1.1.2  dev swp1
	nexthop as to 300 via inet 10.1.1.6  dev swp2


Roopa Prabhu (3):
  mpls: move mpls_route nexthop fields to a new nhlfe struct
  mpls: consistently use u8 to store number of labels
  mpls: add multipath route support

 include/net/mpls_iptunnel.h |    2 +-
 net/mpls/af_mpls.c          |  519 ++++++++++++++++++++++++++++++++-----------
 net/mpls/internal.h         |   44 +++-
 3 files changed, 437 insertions(+), 128 deletions(-)

-- 
1.7.10.4
