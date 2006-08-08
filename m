From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 08:53:03 +0200
Message-ID: <200608080853.03510.ak@suse.de>
References: <20060807164842.GA3412@ms2.inr.ac.ru> <200608080711.06788.ak@suse.de> <20060807.231834.48498773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:37318 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932357AbWHHGxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 02:53:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.231834.48498773.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> Whereas it should probably go:
> 
> 	if (max == 0) {
> 		max = (flags & HASH_HIGHMEM) ? nr_all_pages : nr_kernel_pages;
> 		max = (max << PAGE_SHIFT) >> 4;
> 		do_div(max, bucketsize);
> 	}
> 
> or something like that.

That's still too big. Consider a 2TB machine, with all memory in LOWMEM.

Or even a smaller system. At some point it doesn't make sense
anymore to go to a larger table, even if you have the memory
and it is actually costly to have a larger table because walking
the table (netstat, route etc.) completely will take longer and longer.

It needs some additional limit. Either a maximum one or something dynamic
like CPU cache sizes (but there is currently no portable way to get that)

-Andi

