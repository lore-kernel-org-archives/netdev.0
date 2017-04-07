From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: fix multipath RTM_GETROUTE
 behavior when iif is given
Date: Fri, 07 Apr 2017 07:56:40 -0700 (PDT)
Message-ID: <20170407.075640.2048912684209051827.davem@davemloft.net>
References: <20170407124220.17483-1-fl@n621.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fl@n621.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933874AbdDGO4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:56:54 -0400
In-Reply-To: <20170407124220.17483-1-fl@n621.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Larysch <fl@n621.de>
Date: Fri,  7 Apr 2017 14:42:20 +0200

> inet_rtm_getroute synthesizes a skeletal ICMP skb, which is passed to
> ip_route_input when iif is given. If a multipath route is present for
> the designated destination, fib_multipath_hash ends up being called with
> that skb. However, as that skb contains no information beyond the
> protocol type, the calculated hash does not match the one we would see
> for a real packet.
> 
> There is currently no way to fix this for layer 4 hashing, as
> RTM_GETROUTE doesn't have the necessary information to create layer 4
> headers. To fix this for layer 3 hashing, set appropriate saddr/daddrs
> in the skb and also change the protocol to UDP to avoid special
> treatment for ICMP.
> 
> Signed-off-by: Florian Larysch <fl@n621.de>

Applied, thanks for following up on this.
