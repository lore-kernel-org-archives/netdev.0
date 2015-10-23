From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v5 1/2] mpls: multipath route support
Date: Fri, 23 Oct 2015 12:46:28 +0100
Message-ID: <562A1E14.50908@brocade.com>
References: <1445559403-15258-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ebiederm@xmission.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:64251 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751721AbbJWLqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 07:46:44 -0400
In-Reply-To: <1445559403-15258-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/15 01:16, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds support for MPLS multipath routes.
>
> Includes following changes to support multipath:
> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'
>
> - 'struct mpls_nh' represents a mpls nexthop label forwarding entry
>
> - moves mpls route and nexthop structures into internal.h
>
> - A mpls_route can point to multiple mpls_nh structs
>
> - the nexthops are maintained as a array (similar to ipv4 fib)
>
> - In the process of restructuring, this patch also consistently changes
>    all labels to u8
>
> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
> multipath routes similar to ipv4/v6 fib
>
> - In this patch, the multipath route nexthop selection algorithm
> simply returns the first nexthop. It is replaced by a
> hash based algorithm from Robert Shearman in the next patch
>
> - mpls_route_update cleanup: remove 'dev' handling in mpls_route_update.
> mpls_route_update though implemented to update based on dev, it was
> never used that way. And the dev handling gets tricky with multiple nexthops.
> Cannot match against any single nexthops dev. So, this patch removes the unused
> 'dev' handling in mpls_route_update.
>
> Example:
>
> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
>                  nexthop as 700 via inet 10.1.1.6 dev swp2 \
>                  nexthop as 800 via inet 40.1.1.2 dev swp3
>
> $ip  -f mpls route show
> 100
>          nexthop as to 200 via inet 10.1.1.2  dev swp1
>          nexthop as to 700 via inet 10.1.1.6  dev swp2
>          nexthop as to 800 via inet 40.1.1.2  dev swp3
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Robert Shearman <rshearma@brocade.com>

I think that find_outdev could be simplified, but as it's now clear what 
the expectations are with dev refcounts are during route update I'm 
happy with this latest patch.
