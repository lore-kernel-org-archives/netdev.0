From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 08:54:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008085411.1437f6c8@pirandello>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007150850.7ba2a387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041007150850.7ba2a387.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Oct 2004 at 15h10, David S. Miller wrote:

Hi, 

> > However, it doesn't fix the hang. it looks like this hang is really
> > coming from sungem.
> 
> Is it hanging inside of the ->hard_start_xmit() call 

I think so, but my way of discovering it may not be very good: I tested
by replacing 

status = np->dev->hard_start_xmit(...);

by 
status = NETDEV_TX_OK, then status = NETDEV_TX_BUSY, then status =
NETDEV_TX_LOCKED 

in netpoll.c (avoiding to call hard_start_xmit()), and it didn't hang. 

> or somewhere else?  Do you have a way to determine this without adding
> printk()'s and thus causing recursion as you mentioned earlier? :-)

Well, that's my big problem :-) I can't use the spinlock debugging
neither, because I'm on uniprocessor and on PPC.

I tried removing printk()s from gem_start_xmit() codepath, but it didn't
help either, so I don't think the lock comes from a printk()
recursion... 

(It's really hard to debug that kind of stuff! I'm learning quite a few
things :))

-- 
Colin
