From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/17] fib_trie: Reduce time spent in
 fib_table_lookup by 35 to 75%
Date: Mon, 22 Dec 2014 13:35:19 -0500 (EST)
Message-ID: <20141222.133519.275110312547429947.davem@davemloft.net>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754233AbaLVSfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:35:21 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 22 Dec 2014 09:40:52 -0800

> These patches are meant to address several performance issues I have seen 
> in the fib_trie implementation, and fib_table_lookup specifically.  With 
> these changes in place I have seen a reduction of up to 35 to 75% for the 
> total time spent in fib_table_lookup depending on the type of search being 
> performed.

Fantastic work Alexander.

I had a patch series, just for micro-benchmarking, that got rid of the
local table and just put everything in the global one.

Everything works and we always only do one probe into the FIB.

That speeds things up a lot.

The only problem is that we have to take into consideration cases
where userspace tries to directly modify and do things to the local
table.  Also we might have to pretend we have a local table in
dumps too.
