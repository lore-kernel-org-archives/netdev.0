From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iproute: extend route get to return matching
 fib route
Date: Mon, 5 Jun 2017 12:34:26 -0700
Message-ID: <20170605123426.3660e8bf@xeon-e3>
References: <1496379208-30573-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33860 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbdFETee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:34:34 -0400
Received: by mail-pg0-f48.google.com with SMTP id v18so14950892pgb.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:34:34 -0700 (PDT)
In-Reply-To: <1496379208-30573-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Jun 2017 21:53:28 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Uses newly introduced RTM_GETROUTE flag RTM_F_FIB_MATCH
> to return a matching fib route. Introduces 'fibmatch'
> keyword to ip route get.
> 
> ipv4:
> ----
> $ip route show
> default via 192.168.0.2 dev eth0
> 10.0.14.0/24
>         nexthop via 172.16.0.3  dev dummy0 weight 1
>         nexthop via 172.16.1.3  dev dummy1 weight 1
> 
> $ip route get 10.0.14.2
> 10.0.14.2 via 172.16.1.3 dev dummy1  src 172.16.1.1
>     cache
> 
> $ip route get fibmatch 10.0.14.2
> 10.0.14.0/24
>         nexthop via 172.16.0.3  dev dummy0 weight 1
>         nexthop via 172.16.1.3  dev dummy1 weight 1
> 
> ipv6:
> ----
> $ip -6 route show
> 2001:db9:100::/120  metric 1024
>         nexthop via 2001:db8:2::2  dev dummy0 weight 1
>         nexthop via 2001:db8:12::2  dev dummy1 weight 1
> 
> $ip -6 route get 2001:db9:100::1
> 2001:db9:100::1 from :: via 2001:db8:12::2 dev dummy1  \
>                 src 2001:db8:12::1  metric 1024  pref medium
> 
> $ip -6 route get fibmatch 2001:db9:100::1
> 2001:db9:100::/120  metric 1024
>         nexthop via 2001:db8:12::2  dev dummy1 weight 1
>         nexthop via 2001:db8:2::2  dev dummy0 weight 1
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied to net-next  branch
