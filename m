From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 17/17] fib_trie: Add tracking value for suffix
 length
Date: Mon, 22 Dec 2014 13:32:55 -0500 (EST)
Message-ID: <20141222.133255.250370768177880358.davem@davemloft.net>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<20141222174238.1119.68562.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419AbaLVSc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:32:58 -0500
In-Reply-To: <20141222174238.1119.68562.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 22 Dec 2014 09:42:38 -0800

> This change adds a tracking value for the maximum suffix length of all
> prefixes stored in any given tnode.  With this value we can determine if we
> need to backtrace or not based on if the suffix is greater than the pos
> value.
> 
> By doing this we can reduce the CPU overhead for lookups in the local table
> as many of the prefixes there are 32b long and have a suffix length of 0
> meaning we can immediately backtrace to the root node without needing to
> test any of the nodes between it and where we ended up.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

This is a really nice optimization.
