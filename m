From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression
 with tbench
Date: Tue, 13 Nov 2007 22:37:26 -0800 (PST)
Message-ID: <20071113.223726.40898879.davem@davemloft.net>
References: <200711140436.24492.nickpiggin@yahoo.com.au>
	<20071113.221242.153352652.davem@davemloft.net>
	<200711140514.28159.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org
To: nickpiggin@yahoo.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764157AbXKNGh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:37:26 -0500
In-Reply-To: <200711140514.28159.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 14 Nov 2007 05:14:27 +1100

> On Wednesday 14 November 2007 17:12, David Miller wrote:
> > Is your test system using HIGHMEM?
> >
> > That's one thing the page vector in the sk_buff can do a lot,
> > kmaps.
> 
> No, it's an x86-64, so no highmem.

Ok.

> What's also interesting is that SLAB apparently doesn't have this
> condition. The first thing that sprung to mind is that SLAB caches
> order > 0 allocations, while SLUB does not. However if anything,
> that should actually favour the SLUB numbers if network is avoiding
> order > 0 allocations.
> 
> I'm doing some oprofile runs now to see if I can get any more info.

Here are some other things you can play around with:

1) Monitor the values of skb->len and skb->data_len for packets
   going over loopback.

2) Try removing NETIF_F_SG in drivers/net/loopback.c's dev->feastures
   setting.
