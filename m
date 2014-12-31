From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/17] fib_trie: Reduce time spent in
 fib_table_lookup by 35 to 75%
Date: Wed, 31 Dec 2014 18:46:10 -0500 (EST)
Message-ID: <20141231.184610.1802958694945952516.davem@davemloft.net>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaLaXqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:46:12 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 31 Dec 2014 10:55:23 -0800

> These patches are meant to address several performance issues I have seen 
> in the fib_trie implementation, and fib_table_lookup specifically.  With 
> these changes in place I have seen a reduction of up to 35 to 75% for the 
> total time spent in fib_table_lookup depending on the type of search being 
> performed.
 ...
> Changes since RFC:
>   Replaced this_cpu_ptr with correct call to this_cpu_inc in patch 1
>   Changed test for leaf_info mismatch to (key ^ n->key) & li->mask_plen in patch 10

As before, this looks awesome.

All applied to net-next, thanks!

This knocks about 35 cpu cycles off of a lookup that ends up using the
default route on sparc64.  From about ~438 cycles to ~403.
