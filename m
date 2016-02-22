From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] sctp: Fix port hash table size computation
Date: Sun, 21 Feb 2016 21:53:46 -0500 (EST)
Message-ID: <20160221.215346.18865067787438743.davem@davemloft.net>
References: <20160218.153921.2010668846576353053.davem@davemloft.net>
	<1455829857-15797-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dvyukov@google.com, vyasevich@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034AbcBVCxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 21:53:48 -0500
In-Reply-To: <1455829857-15797-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 18 Feb 2016 16:10:57 -0500

> Dmitry Vyukov noted recently that the sctp_port_hashtable had an error in
> its size computation, observing that the current method never guaranteed
> that the hashsize (measured in number of entries) would be a power of two,
> which the input hash function for that table requires.  The root cause of
> the problem is that two values need to be computed (one, the allocation
> order of the storage requries, as passed to __get_free_pages, and two the
> number of entries for the hash table).  Both need to be ^2, but for
> different reasons, and the existing code is simply computing one order
> value, and using it as the basis for both, which is wrong (i.e. it assumes
> that ((1<<order)*PAGE_SIZE)/sizeof(bucket) is still ^2 when its not).
> 
> To fix this, we change the logic slightly.  We start by computing a goal
> allocation order (which is limited by the maximum size hash table we want
> to support.  Then we attempt to allocate that size table, decreasing the
> order until a successful allocation is made.  Then, with the resultant
> successful order we compute the number of buckets that hash table supports,
> which we then round down to the nearest power of two, giving us the number
> of entries the table actually supports.
> 
> I've tested this locally here, using non-debug and spinlock-debug kernels,
> and the number of entries in the hashtable consistently work out to be
> powers of two in all cases.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks Neil.
