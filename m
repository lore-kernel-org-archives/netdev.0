From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: make skb_set_owner_w() more robust
Date: Mon, 02 Nov 2015 15:26:10 -0500 (EST)
Message-ID: <20151102.152610.2091248201809813226.davem@davemloft.net>
References: <1446421015.6254.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<BN1PR0301MB0770C038C9E0F34EBCCB605FCA2C0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<1446494965.23275.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org, kys@microsoft.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbbKBU0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:26:13 -0500
In-Reply-To: <1446494965.23275.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2015 12:09:25 -0800

> On Mon, 2015-11-02 at 20:05 +0000, Haiyang Zhang wrote:
> 
>> Thanks for the fix!
>> For some driver, like ours, this condition may not be "unlikely".
>> So could you remove the "unlikely"?
> 
> No, I wont remove the unlikely.
> 
> Look, your main issue is about reallocating skbs, because of excessive
> dev->needed_headroom.
> 
> An unlikely() mismatch is 1000 times less expensive, why would you
> care ?
> 
> If you really care, fix your driver to not abuse skb->head to store 220
> bytes of private data.

+1

And I've been saying this from the beginning.  This driver must place
it's private per-packet data in another location if it wants optimal
behavior inside of the Linux networking stack.
