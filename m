From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] Add skb_free_frag to replace
 put_page(virt_to_head_page(ptr))
Date: Tue, 05 May 2015 19:28:51 -0400 (EDT)
Message-ID: <20150505.192851.1294286421369630011.davem@davemloft.net>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbbEEX2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:28:53 -0400
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:14:42 -0700

> This patch set cleans up some of the handling of page frags used in the skb
> allocation.  The issue was we were having to use a number of calls to
> virt_to_head_page in a number of places and then following that up with
> put_page.  Both calls end up being expensive, the first due to size, and
> the second due to the fact that we end up having to call a number of other
> functions before we finally see the page freed in the case of compound
> pages.
> 
> The skb_free_frag function is meant to resolve that by providing a
> centralized location for the virt_to_head_page call and by coalesing
> several checks such as the check for PageHead into a single check so that
> we can keep the instruction cound minimal when freeing the page frag.
> 
> With this change I am seeing an improvement of about 5% in a simple
> receive/drop test.

I'm going to need to see some buyin from the mm folks on this series.
