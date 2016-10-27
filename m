From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: fix incorrect receive checksum offloading
Date: Wed, 26 Oct 2016 23:19:42 -0400 (EDT)
Message-ID: <20161026.231942.1795915733192661471.davem@davemloft.net>
References: <20161023213247.75d43c48@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbcJ0DTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 23:19:44 -0400
In-Reply-To: <20161023213247.75d43c48@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 23 Oct 2016 21:32:47 -0700

> From: Stephen Hemminger <sthemmin@microsoft.com>
> 
> The Hyper-V netvsc driver was looking at the incorrect status bits
> in the checksum info. It was setting the receive checksum unnecessary
> flag based on the IP header checksum being correct. The checksum
> flag is skb is about TCP and UDP checksum status. Because of this
> bug, any packet received with bad TCP checksum would be passed
> up the stack and to the application causing data corruption.
> The problem is reproducible via netcat and netem.
> 
> This had a side effect of not doing receive checksum offload
> on IPv6. The driver was also also always doing checksum offload
> independent of the checksum setting done via ethtool.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied and queued up for -stable.
