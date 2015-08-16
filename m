From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] rhashtable-test: extend to test concurrency
Date: Sun, 16 Aug 2015 23:46:28 +0200
Message-ID: <20150816214555.958D121475@mail.nwl.cc>
References: <1439591835-30357-1-git-send-email-phil@nwl.cc>
 <20150816181234.GC31357@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57960 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbbHPVp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 17:45:57 -0400
Content-Disposition: inline
In-Reply-To: <20150816181234.GC31357@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 16, 2015 at 08:12:35PM +0200, Florian Westphal wrote:
> Phil Sutter <phil@nwl.cc> wrote:
> > After having tested insertion, lookup, table walk and removal, spawn a
> > number of threads running operations on the same rhashtable. Each of
> > them will:
> 
> [..]
> 
> > +	if (down_interruptible(&startup_sem))
> > +		pr_err("  thread[%d]: down_interruptible failed\n", tdata->id);
> 
> Why _interruptible?
> 
> Seems this should use down() instead.

According to the comment in kernel/locking/semaphore.c, down() is
deprecated and one should use down_interruptible() or down_killable()
instead. Apart from that, I don't see any problem with using down()
here. If the call fails, the code is pointless if not even broken
anyway.

Cheers, Phil
