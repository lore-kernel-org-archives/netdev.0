From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] mlxsw: spectrum_router: Add extack
 messages for RIF and VRF overflow
Date: Fri, 20 Oct 2017 13:15:27 +0100 (WEST)
Message-ID: <20171020.131527.985111293556777030.davem@davemloft.net>
References: <1508345816-25678-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com, yoshfuji@linux-ipv6.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752745AbdJTMPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:15:32 -0400
In-Reply-To: <1508345816-25678-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 18 Oct 2017 09:56:51 -0700

> Currently, exceeding the number of VRF instances or the number of router
> interfaces either fails with a non-intuitive EBUSY:
>     $ ip li set swp1s1.6 vrf vrf-1s1-6 up
>     RTNETLINK answers: Device or resource busy
> 
> or fails silently (IPv6) since the checks are done in a work queue. This
> set adds support for the address validator notifier to spectrum which
> allows ext-ack based messages to be returned on failure.
> 
> To make that happen the IPv6 version needs to be converted from atomic
> to blocking (patch 2), and then support for extack needs to be added
> to the notifier (patch 3). Patch 1 reworks the locking in ipv6_add_addr
> to work better in the atomic and non-atomic code paths. Patches 4 and 5
> add the validator notifier to spectrum and then plumb the extack argument
> through spectrum_router.
> 
> With this set, VRF overflows fail with:
>    $ ip li set swp1s1.6 vrf vrf-1s1-6 up
>    Error: spectrum: Exceeded number of supported VRF.
> 
> and RIF overflows fail with:
>    $ ip addr add dev swp1s2.191 10.12.191.1/24
>    Error: spectrum: Exceeded number of supported router interfaces.

Series applied.
