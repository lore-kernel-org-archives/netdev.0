From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Tue, 06 Dec 2016 11:43:56 -0500 (EST)
Message-ID: <20161206.114356.2137355703606265376.davem@davemloft.net>
References: <20161206110946.734344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753187AbcLFQn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:43:58 -0500
In-Reply-To: <20161206110946.734344-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salil Mehta <salil.mehta@huawei.com>
Date: Tue, 6 Dec 2016 11:09:46 +0000

> This patch introduces the RX checksum function to check the
> status of the hardware calculated checksum and its error and
> appropriately convey status to the upper stack in skb->ip_summed
> field.
> 
> In hardware, we only support checksum for the following
> protocols:
> 1) IPv4,
> 2) TCP(over IPv4 or IPv6),
> 3) UDP(over IPv4 or IPv6),
> 4) SCTP(over IPv4 or IPv6)
> but we support many L3(IPv4, IPv6, MPLS, PPPoE etc) and
> L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.) protocols.
> 
> Hardware limitation:
> Our present hardware RX Descriptor lacks L3/L4 checksum
> "Status & Error" bit (which usually can be used to indicate whether
> checksum was calculated by the hardware and if there was any error
> encountered during checksum calculation).
> 
> Software workaround:
> We do get info within the RX descriptor about the kind of
> L3/L4 protocol coming in the packet and the error status. These
> errors might not just be checksum errors but could be related to
> version, length of IPv4, UDP, TCP etc.
> Because there is no-way of knowing if it is a L3/L4 error due
> to bad checksum or any other L3/L4 error, we will not (cannot)
> convey hardware checksum status(CHECKSUM_UNNECESSARY) for such
> cases to upper stack and will not maintain the RX L3/L4 checksum
> counters as well.
> 
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>

Applied.
