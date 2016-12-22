From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix multicast processing
Date: Thu, 22 Dec 2016 11:20:46 -0500 (EST)
Message-ID: <20161222.112046.1340472049113932122.davem@davemloft.net>
References: <1482370216-14833-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46692 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965757AbcLVQUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:20:48 -0500
In-Reply-To: <1482370216-14833-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 21 Dec 2016 17:30:16 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> In an IPvlan setup when master is set in loopback mode e.g.
> 
>   ethtool -K eth0 set loopback on
> 
>   where eth0 is master device for IPvlan setup.
> 
> The failure is caused by the faulty logic that determines if the
> packet is from TX-path vs. RX-path by just looking at the mac-
> addresses on the packet while processing multicast packets.
> 
> In the loopback-mode where this crash was happening, the packets
> that are sent out are reflected by the NIC and are processed on
> the RX path, but mac-address check tricks into thinking this
> packet is from TX path and falsely uses dev_forward_skb() to pass
> packets to the slave (virtual) devices.
> 
> This patch records the path while queueing packets and eliminates
> logic of looking at mac-addresses for the same decision.
 ...
> Fixes: ba35f8588f47 ("ipvlan: Defer multicast / broadcast processing to a work-queue")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This looks a lot better, applied, thanks.
