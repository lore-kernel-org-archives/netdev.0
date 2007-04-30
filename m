From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 12:22:57 -0700 (PDT)
Message-ID: <20070430.122257.68157976.davem@davemloft.net>
References: <463618DB.7020309@hp.com>
	<20070430.115937.104035556.davem@davemloft.net>
	<46363EBD.1020102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55735
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946713AbXD3TWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 15:22:45 -0400
In-Reply-To: <46363EBD.1020102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 30 Apr 2007 21:08:45 +0200

> Maybe we could at least define a 'struct in6_addr_k' for internal
> structures only, to speedup some parts of IPV6 stack.

I think it's better to put this on the backburner for now :-)

We could achieve all of this if we start from the bottom
and work our way up.

Although there are many variations, the logic drivers use to use
skb_reserve() to align the receive header tends to take on a certain
pattern.  We could pull that out into a common piece of code and then
make it ensure 64-bit alignment without a lot of pain.

The hard part of the work will be handling the cases that don't
fit the pattern, and don't forget about NET_IP_ALIGN :-)

