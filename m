From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] udp: fix early demux for mcast packets
Date: Sun, 01 Oct 2017 03:56:48 +0100 (WEST)
Message-ID: <20171001.035648.1725548048341244839.davem@davemloft.net>
References: <cover.1506606381.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdJAC4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 22:56:49 -0400
In-Reply-To: <cover.1506606381.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 28 Sep 2017 15:51:35 +0200

> Currently the early demux callbacks do not perform source address validation.
> This is not an issue for TCP or UDP unicast, where the early demux
> is only allowed for connected sockets and the source address is validated
> for the first packet and never change.
> 
> The UDP protocol currently allows early demux also for unconnected multicast
> sockets, and we are not currently doing any validation for them, after that
> the first packet lands on the socket: beyond ignoring the rp_filter - if 
> enabled - any kind of martian sources are also allowed.
> 
> This series addresses the issue allowing the early demux callback to return an
> error code, and performing the proper checks for unconnected UDP multicast
> sockets before leveraging the rx dst cache.
> 
> Alternatively we could disable the early demux for unconnected mcast sockets,
> but that would cause relevant performance regression - around 50% - while with
> this series, with full rp_filter in place, we keep the regression to a more 
> moderate level.

Series applied and queued up for -stable, thanks.
