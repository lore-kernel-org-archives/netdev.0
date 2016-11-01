From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Enable support for VRF with ipv4
 multicast
Date: Tue, 01 Nov 2016 11:54:57 -0400 (EDT)
Message-ID: <20161101.115457.1305736308724331371.davem@davemloft.net>
References: <1477954440-12339-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbcKAPy7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:54:59 -0400
In-Reply-To: <1477954440-12339-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 31 Oct 2016 15:54:00 -0700

> Enable support for IPv4 multicast:
> - similar to unicast the flow struct is updated to L3 master device
>   if relevant prior to calling fib_rules_lookup. The table id is saved
>   to the lookup arg so the rule action for ipmr can return the table
>   associated with the device.
> 
> - ip_mr_forward needs to check for master device mismatch as well
>   since the skb->dev is set to it
> 
> - allow multicast address on VRF device for Rx by checking for the
>   daddr in the VRF device as well as the original ingress device
> 
> - on Tx need to drop to __mkroute_output when FIB lookup fails for
>   multicast destination address.
> 
> - if CONFIG_IP_MROUTE_MULTIPLE_TABLES is enabled VRF driver creates
>   IPMR FIB rules on first device create similar to FIB rules. In
>   addition the VRF driver does not divert IPv4 multicast packets:
>   it breaks on Tx since the fib lookup fails on the mcast address.
> 
> With this patch, ipmr forwarding and local rx/tx work.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
