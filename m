From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] net: centralize net_device MTU bounds
 checking
Date: Thu, 13 Oct 2016 09:37:36 -0400 (EDT)
Message-ID: <20161013.093736.2110253872628350396.davem@davemloft.net>
References: <20161002.224322.740109807229746275.davem@davemloft.net>
        <20161008020434.9691-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752682AbcJMNij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:38:39 -0400
In-Reply-To: <20161008020434.9691-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Fri,  7 Oct 2016 22:04:32 -0400

> While looking into an MTU issue with sfc, I started noticing that almost
> every NIC driver with an ndo_change_mtu function implemented almost
> exactly the same range checks, and in many cases, that was the only
> practical thing their ndo_change_mtu function was doing. Quite a few
> drivers have either 68, 64, 60 or 46 as their minimum MTU value checked,
> and then various sizes from 1500 to 65535 for their maximum MTU value. We
> can remove a whole lot of redundant code here if we simple store min_mtu
> and max_mtu in net_device, and check against those in net/core/dev.c's
> dev_set_mtu().
> 
> This pair of patches looks to introduce centralized MTU range checking
> infrastructure, while maintaining compatibility with all existing drivers,
> and start to make use of it, converting all eth_change_mtu/ether_setup users
> over to this new infra.
> 
> Assuming these pass review muster, I've got a ton of follow-on patches to
> clean up MTU settings for everything in the kernel with an ndo_change_mtu.
> 
> This work is all staged in a (rebasing) git tree here:
> 
> https://github.com/jarodwilson/linux-muck
> 
> The master branch is based on net-next from Oct 7, and carries these two
> patches, plus a ton of follow-on patches to eliminate MTU range checks
> and change_mtu functions where possible. All patches were successfully
> built across 160 various arch and config combos by the 0-day folks.
> (Thanks to Andrew Lunn for the suggestion to get that going).

Looks great, series applied, thanks Jarod!
