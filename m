From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Thu, 10 Aug 2006 22:37:00 -0400
Message-ID: <44DBED4C.6040604@redhat.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26269 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750783AbWHKChK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 22:37:10 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060808211731.GR14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

> skb->dev is not guaranteed to still point to the "allocating" device
> once the skb is freed again so reserve/unreserve isn't symmetric.
> You'd need skb->alloc_dev or something.

There's another consequence of this property of the network
stack.

Every network interface must be able to fall back to these
MEMALLOC allocations, because the memory critical socket
could be on another network interface.  Hence, we cannot
know which network interfaces should (not) be marked MEMALLOC.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
