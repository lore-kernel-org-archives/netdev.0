From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: GRE: Offload decap without encap
Date: Mon, 16 Oct 2017 21:30:45 +0100 (WEST)
Message-ID: <20171016.213045.2192579343279686077.davem@davemloft.net>
References: <20171016142639.2453-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753724AbdJPUas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:30:48 -0400
In-Reply-To: <20171016142639.2453-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 16 Oct 2017 16:26:34 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Petr says:
> 
> The current code doesn't offload GRE decapsulation unless there's a
> corresponding encapsulation route as well. While not strictly incorrect (when
> encap route is absent, the decap route traps traffic to CPU and the kernel
> handles it), it's a missed optimization opportunity.
> 
> With this patchset, IPIP entries are created as soon as offloadable tunneling
> netdevice is created. This then leads to offloading of decap route, if one
> exists, or is added afterwards, even when no encap route is present.
> 
> In Linux, when there is a decap route, matching IP-in-IP packets are always
> decapsulated. However, with IPv4 overlays in particular, whether the inner
> packet is then forwarded depends on setting of net.ipv4.conf.*.rp_filter. When
> RP filtering is turned on, inner packets aren't forwarded unless there's a
> matching encap route. The mlxsw driver doesn't reflect this behavior in other
> router interfaces, and thus it's not implemented for tunnel types either. A
> better support for this will be subject of follow-up work.

Series applied.
