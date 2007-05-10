From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Thu, 10 May 2007 10:56:32 +0100
Message-ID: <27482.1178790992@warthog.cambridge.redhat.com>
References: <46425C55.6050000@yahoo.com.au> <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com> <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Cc: David Howells <dhowells@redhat.com>, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147AbXEJJ4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 05:56:49 -0400
In-Reply-To: <46425C55.6050000@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Why do you call SetPageUptodate when the page is not up to date?
> That leaks uninitialised data, AFAIKS.

It only seems that way.  If afs_prepare_write() is called, but doesn't return
an error, then afs_commit_write() will be called, and it seems that the copy
in of the data will be guaranteed not to fail by the caller.

Furthermore, afs_prepare_page() will have filled in the missing bits.

And whilst all that is going on, the page lock will be help by the caller, so
that no-one else can access the partially complete page.

I suppose I could call SetPageUptodate() in afs_commit_write() instead.

David
