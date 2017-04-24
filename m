From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv4: Avoid caching l3mdev dst on mismatched
 local route
Date: Mon, 24 Apr 2017 12:52:52 -0400 (EDT)
Message-ID: <20170424.125252.1943124382341210457.davem@davemloft.net>
References: <f3a3ab2d-4a32-a3ec-6a72-071e56577017@brocade.com>
        <1492806899-6215-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975060AbdDXQwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:52:54 -0400
In-Reply-To: <1492806899-6215-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 21 Apr 2017 21:34:59 +0100

> David reported that doing the following:
> 
>     ip li add red type vrf table 10
>     ip link set dev eth1 vrf red
>     ip addr add 127.0.0.1/8 dev red
>     ip link set dev eth1 up
>     ip li set red up
>     ping -c1 -w1 -I red 127.0.0.1
>     ip li del red
> 
> when either policy routing IP rules are present or the local table
> lookup ip rule is before the l3mdev lookup results in a hang with
> these messages:
> 
>     unregister_netdevice: waiting for red to become free. Usage count = 1
> 
> The problem is caused by caching the dst used for sending the packet
> out of the specified interface on a local route with a different
> nexthop interface. Thus the dst could stay around until the route in
> the table the lookup was done is deleted which may be never.
> 
> Address the problem by not forcing output device to be the l3mdev in
> the flow's output interface if the lookup didn't use the l3mdev. This
> then results in the dst using the right device according to the route.
> 
> Changes in v2:
>  - make the dev_out passed in by __ip_route_output_key_hash correct
>    instead of checking the nh dev if FLOWI_FLAG_SKIP_NH_OIF is set as
>    suggested by David.
> 
> Fixes: 5f02ce24c2696 ("net: l3mdev: Allow the l3mdev to be a loopback")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Suggested-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thanks.
