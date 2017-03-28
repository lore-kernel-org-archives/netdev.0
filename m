From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Tue, 28 Mar 2017 10:59:58 +0100
Message-ID: <bffa473b-ffbe-3887-7247-33ee6187487c@brocade.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51925 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753932AbdC1KBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 06:01:03 -0400
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/17 17:03, David Ahern wrote:
> Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
> memory consumption in check the labels array is moved to the end of mpls_nh
> and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
> maximum number of labels across all nexthops in a route for LSR and the
> number of labels configured for LWT.
>
> The mpls_route layout is changed to:
...
> Meaning the via follows its mpls_nh providing better locality as the
> number of labels increases. UDP_RR tests with namespaces shows no impact
> to a modest performance increase with this layout for 1 or 2 labels and
> 1 or 2 nexthops.
>
> The new limit is set to 12 to cover all currently known segment
> routing use cases.
>
> David Ahern (4):
>   mpls: Convert number of nexthops to u8
>   net: mpls: change mpls_route layout
>   net: mpls: bump maximum number of labels
>   net: mpls: Increase max number of labels for lwt encap
>
>  include/net/mpls_iptunnel.h |   4 +-
>  net/mpls/af_mpls.c          | 108 ++++++++++++++++++++++++++------------------
>  net/mpls/internal.h         |  52 ++++++++++++++-------
>  net/mpls/mpls_iptunnel.c    |  13 ++++--
>  4 files changed, 112 insertions(+), 65 deletions(-)
>

Acked-by: Robert Shearman <rshearma@brocade.com>
