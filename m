From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock'
 and 'bindlock'
Date: Sun, 04 Sep 2016 13:29:47 -0700 (PDT)
Message-ID: <20160904.132947.150095861735514200.davem@davemloft.net>
References: <alpine.LFD.2.20.1609021109340.4072@i7>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, rweikusat@mobileactivedefense.com,
        edumazet@google.com, w@1wt.eu, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753966AbcIDUhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 16:37:23 -0400
In-Reply-To: <alpine.LFD.2.20.1609021109340.4072@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 2 Sep 2016 11:13:09 -0700 (PDT)

> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 1 Sep 2016 14:43:53 -0700
> Subject: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'
> 
> Right now we use the 'readlock' both for protecting some of the af_unix
> IO path and for making the bind be single-threaded.
> 
> The two are independent, but using the same lock makes for a nasty
> deadlock due to ordering with regards to filesystem locking.  The bind
> locking would want to nest outside the VSF pathname locking, but the IO
> locking wants to nest inside some of those same locks.
> 
> We tried to fix this earlier with commit c845acb324aa ("af_unix: Fix
> splice-bind deadlock") which moved the readlock inside the vfs locks,
> but that caused problems with overlayfs that will then call back into
> filesystem routines that take the lock in the wrong order anyway.
> 
> Splitting the locks means that we can go back to having the bind lock be
> the outermost lock, and we don't have any deadlocks with lock ordering.
> 
> Acked-by: Rainer Weikusat <rweikusat@cyberadapt.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Applied.
