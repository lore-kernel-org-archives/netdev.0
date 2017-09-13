From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Prevent mirred-related crash on
 removal
Date: Tue, 12 Sep 2017 20:43:52 -0700 (PDT)
Message-ID: <20170912.204352.635555901606355156.davem@davemloft.net>
References: <20170912065053.1392-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yuvalm@mellanox.com, idosch@mellanox.com,
        flokli@flokli.de, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdIMDnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:43:53 -0400
In-Reply-To: <20170912065053.1392-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Sep 2017 08:50:53 +0200

> From: Yuval Mintz <yuvalm@mellanox.com>
> 
> When removing the offloading of mirred actions under
> matchall classifiers, mlxsw would find the destination port
> associated with the offloaded action and utilize it for undoing
> the configuration.
> 
> Depending on the order by which ports are removed, it's possible that
> the destination port would get removed before the source port.
> In such a scenario, when actions would be flushed for the source port
> mlxsw would perform an illegal dereference as the destination port is
> no longer listed.
> 
> Since the only item necessary for undoing the configuration on the
> destination side is the port-id and that in turn is already maintained
> by mlxsw on the source-port, simply stop trying to access the
> destination port and use the port-id directly instead.
> 
> Fixes: 763b4b70af ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
> Signed-off-by: Yuval Mintz <yuvalm@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks.
