From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/3] mpls: multipath support
Date: Wed, 12 Aug 2015 18:30:14 +0100
Message-ID: <55CB82A6.8070800@brocade.com>
References: <1439329548-50935-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:1806 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932437AbbHLRab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 13:30:31 -0400
In-Reply-To: <1439329548-50935-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/15 22:45, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch series adds multipath support to mpls routes.
>
> resembles ipv4 multipath support. The multipath route nexthop
> selection algorithm is the same code as in ipv4 fib code.
>
> I understand that the multipath algorithm in ipv4 is undergoing
> some changes and will move mpls to similar algo if applicable once
> those get merged.

Is it necessary for the mpls patch selection algorithm to closely 
resemble the ipv4 one? A flow based algorithm would be much better for 
traffic that is sensitive to re-ordering (e.g TCP, L2VPN) and IMHO we 
should do this from the start for MPLS.

I've also been looking at implementing this functionality. I've got a 
set of patches for this that I can send if you'd like.

>
> mpls multipath support can be moved under CONFIG_MPLS_ROUTE_MULTIPATH if
> needed similar to CONFIG_IP_ROUTE_MULTIPATH. I started with that
> but that resulted in too many #ifdef CONFIG_MPLS_ROUTE_MULTIPATH
> throughout the af_mpls code. If there is a strong reason
> to introduce a config option, I will respin v2 with
> CONFIG_MPLS_ROUTE_MULTIPATH. These multipath patches do not introduce
> any UAPI changes.

I agree with not having such a config option - I can't see a strong 
reason for it.

Thanks,
Rob

>
> example iproute2 usage:
> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
> 	nexthop as 300 via inet 10.1.1.6 dev swp2
>
> $ip -f mpls route show
> 100
> 	nexthop as to 200 via inet 10.1.1.2  dev swp1
> 	nexthop as to 300 via inet 10.1.1.6  dev swp2
>
>
> Roopa Prabhu (3):
>    mpls: move mpls_route nexthop fields to a new nhlfe struct
>    mpls: consistently use u8 to store number of labels
>    mpls: add multipath route support
>
>   include/net/mpls_iptunnel.h |    2 +-
>   net/mpls/af_mpls.c          |  519 ++++++++++++++++++++++++++++++++-----------
>   net/mpls/internal.h         |   44 +++-
>   3 files changed, 437 insertions(+), 128 deletions(-)
>
