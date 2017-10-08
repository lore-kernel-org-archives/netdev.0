From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Avoid expensive lookup
 during route removal
Date: Sun, 08 Oct 2017 10:06:19 -0700 (PDT)
Message-ID: <20171008.100619.2061046192338628062.davem@davemloft.net>
References: <20171008095326.1238-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbdJHRGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 13:06:20 -0400
In-Reply-To: <20171008095326.1238-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  8 Oct 2017 11:53:26 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> In commit fc922bb0dd94 ("mlxsw: spectrum_router: Use one LPM tree for
> all virtual routers") I increased the scale of supported VRFs by having
> all of them share the same LPM tree.
> 
> In order to avoid look-ups for prefix lengths that don't exist, each
> route removal would trigger an aggregation across all the active virtual
> routers to see which prefix lengths are in use and which aren't and
> structure the tree accordingly.
> 
> With the way the data structures are currently laid out, this is a very
> expensive operation. When preformed repeatedly - due to the invocation
> of the abort mechanism - and with enough VRFs, this can result in a hung
> task.
> 
> For now, avoid this optimization until it can be properly re-added in
> net-next.
> 
> Fixes: fc922bb0dd94 ("mlxsw: spectrum_router: Use one LPM tree for all virtual routers")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Tested-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
