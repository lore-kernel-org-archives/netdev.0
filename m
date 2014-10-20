From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 0/3] net: minor gso encapsulation fixes
Date: Mon, 20 Oct 2014 13:49:15 +0200
Message-ID: <1413805758-30026-1-git-send-email-fw@strlen.de>
Cc: edumazet@google.com, therbert@google.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42239 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751109AbaJTLuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 07:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series fixes a minor bug in the gso segmentation handlers
when encapsulation offload is used.

Theoretically this could cause kernel panic when the stack tries
to software-segment such a GRE offload packet, but it looks like there
is only one affected call site (tbf scheduler) and it handles NULL
return value.

I've included a followup patch to add IS_ERR_OR_NULL checks where needed.

While looking into this, I also found that size computation of the individual
segments is incorrect if skb->encapsulation is set.

Please see individual patches for delta vs. v1.

 core/skbuff.c                    |   13 ++++++++++---
 ipv4/af_inet.c                   |    2 +-
 ipv4/gre_offload.c               |    2 +-
 ipv4/ip_output.c                 |    2 +-
 ipv4/udp_offload.c               |    2 +-
 ipv6/ip6_offload.c               |    2 +-
 mpls/mpls_gso.c                  |    2 +-
 netfilter/nfnetlink_queue_core.c |    2 +-
 openvswitch/datapath.c           |    2 ++
 xfrm/xfrm_output.c               |    2 ++
 10 files changed, 21 insertions(+), 10 deletions(-)
