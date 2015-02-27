From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] fib_trie: Remove leaf_info structure
Date: Fri, 27 Feb 2015 17:06:03 -0500 (EST)
Message-ID: <20150227.170603.1872259963520922972.davem@davemloft.net>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbbB0WGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:06:08 -0500
In-Reply-To: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 25 Feb 2015 11:05:55 -0800

> This patch set removes the leaf_info structure from the IPv4 fib_trie.  The
> general idea is that the leaf_info structure itself only held about 6
> actual bits of data, beyond that it was mostly just waste.  As such we can
> drop the structure, move the 1 byte representing the prefix/suffix length
> into the fib_alias and just link it all into one list.
> 
> My testing shows that this saves somewhere between 4 to 10ns depending on
> the type of test performed.  I'm suspecting that this represents 1 to 2 L1
> cache misses saved per look-up.
> 
> One side effect of this change is that semantic_match_miss will now only
> increment once per leaf instead of once per leaf_info miss.  However the
> stat is already skewed now that we perform a preliminary check on the leaf
> as a part of the look-up.
> 
> I also have gone through and addressed a number of ordering issues in the
> first patch since I had misread the behavior of list_add_tail.
> 
> I have since run some additional testing and verified the resulting lists
> are in the same order when combining multiple prefix length and tos values
> in a single leaf.

Series applied, thanks Alexander.
