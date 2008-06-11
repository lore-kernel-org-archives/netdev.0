From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 11 Jun 2008 19:06:55 +0400
Message-ID: <20080611150655.GA17562@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, mcmanus@ducksong.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:60520 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1760196AbYFKPHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 11:07:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> On Tue, 2008-06-10 at 15:32 -0700, David Miller wrote:
> 
> I took a close look at this, it seems this patch adds
> an ABBA deadlock.  But I might be wrong.

Yes, this is not a real deadlock. But also it is not even a lock.
bh_lock_sock on listening socket is not enough to lock it.

Seems, the solution would be forcing bh_lock_sock() to protect accept_queue,
which is a mess. Or adding a separate spinlock, like it was done with
syn_wait_lock. Also not good.

Alexey
