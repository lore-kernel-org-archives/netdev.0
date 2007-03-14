From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Tue, 13 Mar 2007 17:55:08 -0700 (PDT)
Message-ID: <20070314005508.DDC121801C5@magilla.sf.frob.com>
References: <Pine.LNX.4.64.0703131420230.9690@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56815 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbXCNAzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 20:55:16 -0400
In-Reply-To: Linus Torvalds's message of  Tuesday, 13 March 2007 14:28:00 -0700 <Pine.LNX.4.64.0703131420230.9690@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'd actually prefer this as part of the "remove OPEN_MAX" patch.

Ok.  (But now you're going to argue with me about "remove OPEN_MAX",
and you haven't said you have any problem with changing SCM_MAX_FD,
so why make it wait?)

> That said, it actually worries me that you should call "_SC_OPEN_MAX". 
[...]
> For example, I know perfectly well that I should use _SC_PATH_MAX, but a 
> *lot* of code simply doesn't care. In git, I used PATH_MAX, and the reason 
[...]

Ok, fine.  But PATH_MAX is a real constant that has some meaning in the
kernel.  It's perfectly correct to use PATH_MAX as a constant on a system
like Linux that defines it and means what it says.  Conversely, OPEN_MAX
has no useful relationship with anything the kernel is doing at all.

> So, what's the likelihood that this will break some old programs? I 
> realize that modern distributions don't put the kernel headers in their 
> user-visible includes any more, but the breakage is most likely exactly 
> for old programs and older distributions.

Well, I don't know for sure.  It doesn't seem all that likely to me (not
like PATH_MAX), as there has been getdtablesize() since before there was
OPEN_MAX by that name (not to mention before there was Linux).  If things
use OPEN_MAX as a constant for arrays, they're already broken unless they
call setrlimit to constrain themselves.  Getting things fixed has to start
somewhere.


Thanks,
Roland

