From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: __alloc_skb() speedup
Date: Wed, 05 May 2010 01:26:47 -0700 (PDT)
Message-ID: <20100505.012647.260083711.davem@davemloft.net>
References: <1272993054.2245.21.camel@edumazet-laptop>
	<20100505.010658.48498744.davem@davemloft.net>
	<1273047734.2367.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155Ab0EEI0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:26:40 -0400
In-Reply-To: <1273047734.2367.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 May 2010 10:22:14 +0200

> You mean memset() wont be inlined by ompiler to plain memory writes, but
> use the custom kernel memset()  ?

I hope memset() is never inlined for a 202 byte piece of memory on
sparc64 or powerpc.  What happens and makes sense on x86 is x86's
business :-)

Especially since that elides the cache invalidate optimizations, and
for anything >= 64 bytes those are absolutely critical on Niagara.
