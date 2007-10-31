From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 28/33] nfs: teach the NFS client how to treat PG_swapcache pages
Date: Wed, 31 Oct 2007 08:52:37 +0000
Message-ID: <20071031085237.GB4362@infradead.org>
References: <20071030160401.296770000@chello.nl> <20071030160915.377778000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37987 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbXJaIwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 04:52:38 -0400
Content-Disposition: inline
In-Reply-To: <20071030160915.377778000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 05:04:29PM +0100, Peter Zijlstra wrote:
> Replace all relevant occurences of page->index and page->mapping in the NFS
> client with the new page_file_index() and page_file_mapping() functions.

As discussed personally and on the list a strong NACK for this.  Swapcache
pages have no business at all ever coming through ->writepage(s).  If you
really want to support swap over NFS that can only be done properly by
adding separate methods to write out and read in pages separated from the
pagecache.  Incidentally that would also clean up the mess we have with
swap files on "normal" filesystems using ->bmap and bypassing the filesystem
later on.

