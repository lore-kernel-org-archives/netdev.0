From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Allow IP_MULTICAST_IF to set index to L3
 slave
Date: Fri, 30 Dec 2016 15:25:47 -0500 (EST)
Message-ID: <20161230.152547.1766479809420832083.davem@davemloft.net>
References: <1483054777-11306-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darwin.dingel@alliedtelesis.co.nz,
        Mark.Tomlinson@alliedtelesis.co.nz
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754112AbcL3UZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 15:25:48 -0500
In-Reply-To: <1483054777-11306-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 29 Dec 2016 15:39:37 -0800

> IP_MULTICAST_IF fails if sk_bound_dev_if is already set and the new index
> does not match it. e.g.,
> 
>     ntpd[15381]: setsockopt IP_MULTICAST_IF 192.168.1.23 fails: Invalid argument
> 
> Relax the check in setsockopt to allow setting mc_index to an L3 slave if
> sk_bound_dev_if points to an L3 master.
> 
> Make a similar change for IPv6. In this case change the device lookup to
> take the rcu_read_lock avoiding a refcnt. The rcu lock is also needed for
> the lookup of a potential L3 master device.
> 
> This really only silences a setsockopt failure since uses of mc_index are
> secondary to sk_bound_dev_if if it is set. In both cases, if either index
> is an L3 slave or master, lookups are directed to the same FIB table so
> relaxing the check at setsockopt time causes no harm.
> 
> Patch is based on a suggested change by Darwin for a problem noted in
> their code base.
> 
> Suggested-by: Darwin Dingel <darwin.dingel@alliedtelesis.co.nz>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

This seems ok, applied, thanks.
