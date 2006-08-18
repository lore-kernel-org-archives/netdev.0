From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Thu, 17 Aug 2006 18:29:45 -0700 (PDT)
Message-ID: <20060817.182945.08318827.davem@davemloft.net>
References: <20060817093615.GA25553@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44929
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932315AbWHRB3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 21:29:37 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060817093615.GA25553@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Thu, 17 Aug 2006 13:36:15 +0400

> Found in 2.4 by Yixin Pan <yxpan@hotmail.com>. Why do we need lockdep,
> when sharp-sighted eyes are available? :-)

Lockdep can only tell us about code paths which actually have been
run, so it shows that nobody running lockdep has had a redirect arrive
on a non-shared-media device marked for secure redirects :)

But such a code path would only need to run once for lockdep to catch
it.

> > When I read fib_semantics.c of Linux-2.4.32, write_lock(&fib_info_lock) =
> > is used in fib_release_info() instead of write_lock_bh(&fib_info_lock).  =
> > Is the following case possible: a BH interrupts fib_release_info() while =
> > holding the write lock, and calls ip_check_fib_default() which calls =
> > read_lock(&fib_info_lock), and spin forever.
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Good spotting.  Patch applied, and I'll push this to -stable too.

Thanks a lot.
