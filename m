From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: Release route when device is unregistering
Date: Wed, 7 Jun 2017 13:14:20 -0700
Message-ID: <CAJieiUjseMsEp-u5h1YoDAqRO4WcbEHg3KoEHpxQ84ERXn9jfw@mail.gmail.com>
References: <20170607182623.20734-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:36024 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751405AbdFGUOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 16:14:21 -0400
Received: by mail-vk0-f48.google.com with SMTP id p85so9571612vkd.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 13:14:21 -0700 (PDT)
In-Reply-To: <20170607182623.20734-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 7, 2017 at 11:26 AM, David Ahern <dsahern@gmail.com> wrote:
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
> ---

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes the issue for me. Thanks David.
