From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 11:47:03 -0500 (EST)
Message-ID: <20161128.114703.154301432767947066.davem@davemloft.net>
References: <20161125055017.7053-1-elicooper@gmx.com>
        <20161127130400.4a69ff1b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elicooper@gmx.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33106 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933245AbcK1QrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:47:12 -0500
In-Reply-To: <20161127130400.4a69ff1b@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sun, 27 Nov 2016 13:04:00 +1100

> [Just for Dave's information]
> 
> On Fri, 25 Nov 2016 13:50:17 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>>
>> Similar to commit ae148b085876
>> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
>> sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
>> might not be properly segmented, which causes the packets being dropped.
>> 
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> Tested-by: Eli Cooper <elicooper@gmx.com>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> 
> I tested this patch and it does *not* solve my problem.

I'm torn on this patch, because it looked exactly like it would solve the
kind of problem Stephen is running into.

Even though it doesn't fix his case, it seems correct to me.

I was wondering if it was also important to set the skb->protocol
before the call to ip_tunnel_encap() but I couldn't find a dependency.

In any event I'd like to see some other people review this change
before I apply it.

My only other guess for Stephen's problem is somehow the SKB headers
aren't set up properly for what the GSO engine expects.
