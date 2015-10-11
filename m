From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 0/2] mpls: multipath support
Date: Sun, 11 Oct 2015 14:20:27 -0500
Message-ID: <87y4f9w6tg.fsf@x220.int.ebiederm.org>
References: <1444588174-44663-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:35769 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbbJKT2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 15:28:45 -0400
In-Reply-To: <1444588174-44663-1-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Sun, 11 Oct 2015 11:29:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds support for MPLS multipath routes.
>
> Includes following changes to support multipath:
> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'.
>
> - struct mpls_nh represents a mpls nexthop label forwarding entry
>
> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
> multipath routes similar to ipv4/v6 fib
>
> - In the process of restructuring, this patch also consistently changes all
> labels to u8
>
> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
> 		nexthop as 700 via inet 10.1.1.6 dev swp2 \
> 		nexthop as 800 via inet 40.1.1.2 dev swp3
>
> $ip  -f mpls route show
> 100 
> 	nexthop as to 200 via inet 10.1.1.2  dev swp1
> 	nexthop as to 700 via inet 10.1.1.6  dev swp2
> 	nexthop as to 800 via inet 40.1.1.2  dev swp3
>
> Roopa Prabhu (2):
>   mpls: multipath support
>   mpls: flow-based multipath selection

Overall this looks good, very reviewable and maintainable.

I have a couple of minor nits that can probably be best addressed by
follow on patches.

Eric


> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> ----
> v2:
> 	- Incorporate some feedback from Robert:
> 		use dynamic allocation (list) instead of static allocation
> 		for nexthops
> v3:
> 	- Move back to arrays (same as v1), also suggested by Eric Biederman
>
>
>  include/net/mpls_iptunnel.h |   2 +-
>  net/mpls/af_mpls.c          | 668 ++++++++++++++++++++++++++++++++++----------
>  net/mpls/internal.h         |  57 +++-
>  3 files changed, 572 insertions(+), 155 deletions(-)
