From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sun, 11 Jun 2017 18:15:56 -0400 (EDT)
Message-ID: <20170611.181556.1883936192698112580.davem@davemloft.net>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
To: sharpd@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdFKWP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 18:15:58 -0400
In-Reply-To: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Donald Sharp <sharpd@cumulusnetworks.com>
Date: Sat, 10 Jun 2017 16:30:17 -0400

> This patch fixes two issues:
> 
> 1) When forwarding on *,G mroutes that are in a vrf, the
> kernel was dropping information about the actual incoming
> interface when calling ip_mr_forward from ip_mr_input.
> This caused ip_mr_forward to send the multicast packet
> back out the incoming interface.  Fix this by
> modifying ip_mr_forward to be handed the correctly
> resolved dev.
> 
> 2) When a unresolved cache entry is created we store
> the incoming skb on the unresolved cache entry and
> upon mroute resolution from the user space daemon,
> we attempt to forward the packet.  Again we were
> not resolving to the correct incoming device for
> a vrf scenario, before calling ip_mr_forward.
> Fix this by resolving to the correct interface
> and calling ip_mr_forward with the result.
> 
> Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> ---
> v2: Fixed title
> v3: Addressed Review comments by Andrew Lunn and David Ahern

Applied and queued up for -stable, thank you.
