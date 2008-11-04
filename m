From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] skb_free_datagram() doing something expensive ?
Date: Tue, 04 Nov 2008 15:41:12 -0800 (PST)
Message-ID: <20081104.154112.52727780.davem@davemloft.net>
References: <4910D47E.4030004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, minyard@acm.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757960AbYKDXlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 18:41:37 -0500
In-Reply-To: <4910D47E.4030004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 05 Nov 2008 00:02:22 +0100

> tcp_memory_allocated do not have this problem, since tcp carefully calls sk_mem_reclaim(sk) only on
> selected paths, not on fast path.

I think something similar can be done for UDP.

Otherwise, yes, we'll need to do else something about it.

I guess your per-cpu idea, since we're trying to enforce
global limits, is to cache the available quota on a per-cpu
basis.  But I wonder if that can work properly.  If a
cpu gets overloaded and runs out of it's local quota, it'll
need to grab from another cpu.... hmmm...

