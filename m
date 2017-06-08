From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Release route when device is
 unregistering
Date: Thu, 08 Jun 2017 11:13:06 -0400 (EDT)
Message-ID: <20170608.111306.987099708536491352.davem@davemloft.net>
References: <20170607182623.20734-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdFHPNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:13:09 -0400
In-Reply-To: <20170607182623.20734-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed,  7 Jun 2017 12:26:23 -0600

> Roopa reported attempts to delete a bond device that is referenced in a
> multipath route is hanging:
> 
> $ ifdown bond2    # ifupdown2 command that deletes virtual devices
> unregister_netdevice: waiting for bond2 to become free. Usage count = 2
> 
> Steps to reproduce:
>     echo 1 > /proc/sys/net/ipv6/conf/all/ignore_routes_with_linkdown
>     ip link add dev bond12 type bond
>     ip link add dev bond13 type bond
>     ip addr add 2001:db8:2::0/64 dev bond12
>     ip addr add 2001:db8:3::0/64 dev bond13
>     ip route add 2001:db8:33::0/64 nexthop via 2001:db8:2::2 nexthop via 2001:db8:3::2
>     ip link del dev bond12
>     ip link del dev bond13
> 
> The root cause is the recent change to keep routes on a linkdown. Update
> the check to detect when the device is unregistering and release the
> route for that case.
> 
> Fixes: a1a22c12060e4 ("net: ipv6: Keep nexthop of multipath route on admin down")
> Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied and queued up for -stable, thanks David.
