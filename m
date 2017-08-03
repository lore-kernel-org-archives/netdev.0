From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/6] ipv4: fib: Provide per-nexthop offload
 indication
Date: Wed, 02 Aug 2017 17:00:40 -0700 (PDT)
Message-ID: <20170802.170040.1522837897155424725.davem@davemloft.net>
References: <20170802075606.1090-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdHCAAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 20:00:43 -0400
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  2 Aug 2017 09:56:00 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> Offload indication for IPv4 routes is currently set in the FIB info's
> flags. When multipath routes are employed, this can lead to a route being
> marked as offloaded although only one of its nexthops is actually
> offloaded.
> 
> Instead, this patchset aims to proivde a higher resolution for the offload
> indication and report it on a per-nexthop basis.
> 
> Example output from patched iproute:
> 
> $ ip route show 192.168.200.0/24
> 192.168.200.0/24
>         nexthop via 192.168.100.2 dev enp3s0np7 weight 1 offload
>         nexthop via 192.168.101.3 dev enp3s0np8 weight 1
> 
> And once the second gateway is resolved:
> 
> $ ip route show 192.168.200.0/24
> 192.168.200.0/24
>         nexthop via 192.168.100.2 dev enp3s0np7 weight 1 offload
>         nexthop via 192.168.101.3 dev enp3s0np8 weight 1 offload
> 
> First patch teaches the kernel to look for the offload indication in the
> nexthop flags. Patches 2-5 adjust current capable drivers to provide
> offload indication on a per-nexthop basis. Last patch removes no longer
> used functions to set offload indication in the FIB info's flags.

Series applied, thanks Jiri.
