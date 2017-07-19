From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] iproute: extend route get for mpls
 routes
Date: Tue, 18 Jul 2017 17:15:02 -0700
Message-ID: <20170718171502.2e60581e@xeon-e3>
References: <1499465291-2199-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36679 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdGSAPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:15:04 -0400
Received: by mail-pg0-f43.google.com with SMTP id u5so20965574pgq.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:15:04 -0700 (PDT)
In-Reply-To: <1499465291-2199-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Jul 2017 15:08:11 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch extends route get to support mpls specific
> route attributes like RTA_NEWDST.
> 
> Input:
> RTA_DST - input label
> RTA_NEWDST - labels in packet for multipath selection
> 
> By default the getroute handler returns matched
> nexthop label, via and oif
> 
> With fibmatch keyword (RTM_F_FIB_MATCH flag), full matched
> route is returned.
> 
> example:
> $ip -f mpls route show
> 101
>         nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
>         nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12
> 201
>         nexthop as to 202/203 via inet6 2001:db8:2::2 dev virt1-2
>         nexthop as to 402/403 via inet6 2001:db8:12::2 dev virt1-12
> 
> $ip -f mpls route get 103
> RTNETLINK answers: Network is unreachable
> 
> $ip -f mpls route get 101
> 101 as to 102/103 via inet 172.16.2.2 dev virt1-2
> 
> $ip -f mpls route get as to 302/303 101
> 101 as to 302/303 via inet 172.16.12.2 dev virt1-12
> 
> $ip -f mpls route get fibmatch 103
> RTNETLINK answers: Network is unreachable
> 
> $ip -f mpls route get fibmatch 101
> 101
>         nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
>         nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
