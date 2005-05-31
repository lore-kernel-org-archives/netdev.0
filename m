From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] shaper.c: fix locking
Date: Tue, 31 May 2005 14:41:14 -0700 (PDT)
Message-ID: <20050531.144114.78710204.davem@davemloft.net>
References: <20050527115450.GA19469@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20050527115450.GA19469@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] shaper.c: fix locking
Date: Fri, 27 May 2005 13:54:50 +0200

>  o use a semaphore instead of an opencoded and racy lock
>  o move locking out of shaper_kick and into the callers - most just
>    released the lock before calling shaper_kick
>  o remove in_interrupt() tests.  from ->close we can always block, from
>    ->hard_start_xmit and timer context never

Do you really want to use a semaphore for a lock taken
%99 of the time in software IRQ context, which obviously
cannot sleep?
