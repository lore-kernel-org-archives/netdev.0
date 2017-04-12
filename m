From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 20:03:47 -0400 (EDT)
Message-ID: <20170411.200347.823503315758200310.davem@davemloft.net>
References: <20170411.112733.1412982560568816717.davem@davemloft.net>
        <1491948401.7236.20.camel@kernel.crashing.org>
        <1491953765.7236.28.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752523AbdDLAEK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:04:10 -0400
In-Reply-To: <1491953765.7236.28.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Apr 2017 09:36:05 +1000

> I should call the helper when I don't recognize the protocol type in
> the IP header, not just when the main skb protocol type is not IP.

That's correct.

> BTW. I'm not too familiar with how encapsulation works these days. I
> wouldn't throw at that HW anything other than unencapsulated packets
> for HW checksumming. Is checking skb->protocol to be IP and
> ip_hdr(skb)->protocol to be IP, UDP or TCP enough ? IE. Will the latter
> especially return the outer header ?

If skb->protocol is IP then yes ip_hdr() will point at the outermost
header.
