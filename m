From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next] ipv6: fib: Provide offload indication using
 nexthop flags
Date: Tue, 15 Aug 2017 08:18:36 -0600
Message-ID: <36964869-b0d4-1b03-ca28-654ac3727283@gmail.com>
References: <20170815070949.1363-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34746 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHOOSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:18:40 -0400
Received: by mail-pg0-f65.google.com with SMTP id y192so1706775pgd.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:18:40 -0700 (PDT)
In-Reply-To: <20170815070949.1363-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/17 1:09 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> IPv6 routes currently lack nexthop flags as in IPv4. This has several
> implications.
> 
> In the forwarding path, it requires us to check the carrier state of the
> nexthop device and potentially ignore a linkdown route, instead of
> checking for RTNH_F_LINKDOWN.
> 
> It also requires capable drivers to use the user facing IPv6-specific
> route flags to provide offload indication, instead of using the nexthop
> flags as in IPv4.
> 
> Add nexthop flags to IPv6 routes in the 40 bytes hole and use it to
> provide offload indication instead of the RTF_OFFLOAD flag, which is
> removed while it's still not part of any official kernel release.
> 
> In the near future we would like to use the field for the
> RTNH_F_{LINKDOWN,DEAD} flags, but this change is more involved and might
> not be ready in time for the current cycle.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++++----
>  include/net/ip6_fib.h                                 | 2 ++
>  include/uapi/linux/ipv6_route.h                       | 1 -
>  net/ipv6/route.c                                      | 7 +------
>  4 files changed, 7 insertions(+), 11 deletions(-)

LGTM.

Acked-by: David Ahern <dsahern@gmail.com>
