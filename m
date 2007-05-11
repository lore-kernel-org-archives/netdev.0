From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Fri, 11 May 2007 16:14:39 +1000
Message-ID: <464409CF.4090203@yahoo.com.au>
References: <46425C55.6050000@yahoo.com.au> <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com> <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com> <27482.1178790992@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.mail.mud.yahoo.com ([209.191.85.218]:40401 "HELO
	smtp108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755100AbXEKGOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:14:53 -0400
In-Reply-To: <27482.1178790992@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Why do you call SetPageUptodate when the page is not up to date?
>>That leaks uninitialised data, AFAIKS.
> 
> 
> It only seems that way.  If afs_prepare_write() is called, but doesn't return
> an error, then afs_commit_write() will be called, and it seems that the copy
> in of the data will be guaranteed not to fail by the caller.

Not only does it seem that way, it is that way :) PG_uptodate is being set
when the page is not uptodate, isn't it?


> Furthermore, afs_prepare_page() will have filled in the missing bits.
> 
> And whilst all that is going on, the page lock will be help by the caller, so
> that no-one else can access the partially complete page.

When a page is uptodate in pagecache, the generic read and nopage functions
do not take the page lock. So how are you excluding those?

-- 
SUSE Labs, Novell Inc.
