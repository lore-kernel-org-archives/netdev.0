From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Fri, 7 Dec 2012 10:58:09 +0000
Message-ID: <20121207105809.GC2996@casper.infradead.org>
References: <50BE56D3.2030704@6wind.com>
 <50BF29DA.7020903@6wind.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
 <20121205.125453.1457654258131828976.davem@davemloft.net>
 <50C05AC2.1050504@6wind.com>
 <20121206174905.GC16122@casper.infradead.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70E4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46775 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756029Ab2LGK6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 05:58:12 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70E4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/12 at 10:38am, David Laight wrote:
> What are you going to align the data with respect to?
> I doubt you can assume that the start of the netlink
> message itself is 8 byte aligned - so any attempt
> to 8 byte align an item is probably doomed to failure.

Correct me if I'm wrong but skb->head will be aligned to
SKB_DATA_ALIGN() which as I understand is guaranted to
be 8 bytse aligned. So we can just add needed padding if
skb->data would not be aligned correctly after the next
netlink attribute header was added.

All user space needs to do is use a receive buffer that
is 8 byte aligned as well and we are good to go.
