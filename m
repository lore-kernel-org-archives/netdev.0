From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Sun, 13 Aug 2006 15:05:25 -0700
Message-ID: <44DFA225.1020508@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch> <44DBED4C.6040604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:2168 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1751672AbWHMWFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 18:05:54 -0400
To: Rik van Riel <riel@redhat.com>
In-Reply-To: <44DBED4C.6040604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rik van Riel wrote:
> Thomas Graf wrote:
>> skb->dev is not guaranteed to still point to the "allocating" device
>> once the skb is freed again so reserve/unreserve isn't symmetric.
>> You'd need skb->alloc_dev or something.
> 
> There's another consequence of this property of the network
> stack.
> 
> Every network interface must be able to fall back to these
> MEMALLOC allocations, because the memory critical socket
> could be on another network interface.  Hence, we cannot
> know which network interfaces should (not) be marked MEMALLOC.

Good point.  We do however know which interfaces should be marked
capable of carrying block IO traffic: the ones that have been fixed,
audited and tested.  We might then allow the network block device to
specify which interface(s) will actually carry the traffic.

The advantage of being specific about which devices are carrying at
least one block io socket is, we can skip the reserve accounting for
the other interfaces.  But is the extra layer of configuration gack a
better idea than just doing the accounting for every device, provided
the system is in reclaim?

By the way, another way to avoid impact on the normal case is an
experimental option such as CONFIG_PREVENT_NETWORK_BLOCKIO_DEADLOCK.

Regards,

Daniel
