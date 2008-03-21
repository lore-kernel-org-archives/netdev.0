From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] fib_trie: RCU optimizations
Date: Fri, 21 Mar 2008 15:49:33 -0700 (PDT)
Message-ID: <20080321.154933.81125723.davem@davemloft.net>
References: <47E3EF70.6080000@cosmosbay.com>
	<20080321103156.1f0d06aa@extreme>
	<47E3F401.3070707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763477AbYCUWtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:49:18 -0400
In-Reply-To: <47E3F401.3070707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Mar 2008 18:44:33 +0100

> Loop is so small that prefetches hints are throwed away by CPU, or the 
> cost to setup the prefetch(register + offset) is too expensive...

That's been my experience as well.

For this reason I consider the unconditional prefetches in the
linux/list.h list iteration macros troublesome.

Most loops are small so by default those macros should not prefetch,
and when you know you have a large enough loop (and thus enough work
to make the prefetch actually matter) you use a specific specially
named variant of the list traversal macro.

Oh yes, and you have to provide performance improvement proof before
submitting a patch that uses the prefetch-using list macro variants.
:-)

