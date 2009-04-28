From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Avoid extra wakeups of threads blocked in
 wait_for_packet()
Date: Tue, 28 Apr 2009 02:26:02 -0700 (PDT)
Message-ID: <20090428.022602.99712872.davem@davemloft.net>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
	<49F3308B.1030507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux.com, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753905AbZD1J0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:26:09 -0400
In-Reply-To: <49F3308B.1030507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 25 Apr 2009 17:47:23 +0200

> In 2.6.25 we added UDP mem accounting.
> 
> This unfortunatly added a penalty when a frame is transmitted, since
> we have at TX completion time to call sock_wfree() to perform necessary
> memory accounting. This calls sock_def_write_space() and utimately
> scheduler if any thread is waiting on the socket.
> Thread(s) waiting for an incoming frame was scheduled, then had to sleep
> again as event was meaningless.
 ...
> This patch introduces new DEFINE_WAIT_FUNC() helper and uses it
> in wait_for_packet(), so that only relevant event can wakeup a thread
> blocked in this function.

Ok, I was going to give some time towards considering the
alternative implementation of using 2 wait queues and what
it would look like.

It didn't take long for me to figure out that this is so much
simpler that it's not even worth trying the dual wait queue
approach.

So I've applied this to net-2.6, thanks!

Now, if we want to fix this up in -stable we'll need to scratch
our heads if we can't get the keyed wakeup patch in too. :-/

