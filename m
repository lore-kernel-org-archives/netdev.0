From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v4 0/2] mpls: multipath support
Date: Wed, 21 Oct 2015 23:04:32 -0500
Message-ID: <87zizbczvz.fsf@x220.int.ebiederm.org>
References: <1445217645-42885-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49218 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbJVEMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 00:12:44 -0400
In-Reply-To: <1445217645-42885-1-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Sun, 18 Oct 2015 18:20:43 -0700")
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
> Roopa Prabhu (1):
>   mpls: multipath support
>
> Robert Shearman (1):
>   mpls: flow-based multipath selection
>
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
> v4:
> 	- address a few comments from Eric Biederman
> 	Plan to address the following pending comments in incremental patches after this
> 	infrastructure changes go in.
> 	- Move VIA size to 16 bytes
> 	- use ipv6 flow label in ecmp calculations
> 	- dead route handling during multipath route selection (I had planned this in
> 	an incremental patch initially).

I don't see anything problematic in the patches the worst
I found is dead code and we can delete that later so
for purposes of moving forward I say:

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

That said we really need dead path handling.  Without handling paths
that go dead this functionality really is pretty much broken.  So if you
can't get that by the merge window we will need to apply a patch to
disable processing of the RTA_MULTIPATH netlink attribute.

Eric
