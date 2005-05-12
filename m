From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 12:26:57 -0700 (PDT)
Message-ID: <20050512.122657.50069962.davem@davemloft.net>
References: <20050511.223036.39664020.davem@davemloft.net>
	<m1sm0sttvy.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <m1sm0sttvy.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 16:13:05 +0200

> Are you sure a few atomic_inc/dec are really causing noticeable
> slowdown? That would surprise me unless you have lots of cache line
> bouncing on a MP system.

It's about 7 or 8 times as many atomic gets and puts on pages compared
to the older code (with an 8K page size).

Some of it we can't get rid of, because we keep a normal write queue
segmented set of SKBs around.

But the TSO part we can eliminate.
