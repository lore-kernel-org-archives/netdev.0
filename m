From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: put host and anycast routes on
 device with address
Date: Mon, 21 Aug 2017 10:41:22 -0700 (PDT)
Message-ID: <20170821.104122.296287714831109265.davem@davemloft.net>
References: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
        hannes@stressinduktion.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbdHURlX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:41:23 -0400
In-Reply-To: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 17 Aug 2017 12:17:20 -0700

> One nagging difference between ipv4 and ipv6 is host routes for ipv6
> addresses are installed using the loopback device or VRF / L3 Master
> device. e.g.,
> 
>     2001:db8:1::/120 dev veth0 proto kernel metric 256 pref medium
>     local 2001:db8:1::1 dev lo table local proto kernel metric 0 pref medium
> 
> Using the loopback device is convenient -- necessary for local tx, but
> has some nasty side effects, most notably setting the 'lo' device down
> causes all host routes for all local IPv6 address to be removed from the
> FIB and completely breaks IPv6 networking across all interfaces.
> 
> This patch puts FIB entries for IPv6 routes against the device. This
> simplifies the routes in the FIB, for example by making dst->dev and
> rt6i_idev->dev the same (a future patch can look at removing the device
> reference taken for rt6i_idev for FIB entries).
> 
> When copies are made on FIB lookups, the cloned route has dst->dev
> set to loopback (or the L3 master device). This is needed for the
> local Tx of packets to local addresses.
> 
> With fib entries allocated against the real network device, the addrconf
> code that reinserts host routes on admin up of 'lo' is no longer needed.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

I've applied this.

I'm unlikely to revert this just for java, given the kinds of things
they are doing.
