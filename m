From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: netdev ioctl & dev_base_lock : bad idea ?
Date: Thu, 09 Dec 2004 17:22:13 +1100
Message-ID: <1102573333.16495.2.camel@gaston>
References: <1101458929.28048.9.camel@gaston>
	 <20041208220642.6984519f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041208220642.6984519f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-08 at 22:06 -0800, David S. Miller wrote:
> On Fri, 26 Nov 2004 19:48:49 +1100
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > I suppose there is a good reason we can't just use the rtnl_sem for
> > these guys, though why isn't dev_base_lock a read/write semaphore
> > instead of a spinlock ? At least on ppc, I don't think there's any
> > overhead in the normal path, and this is not on a very critical path
> > anyway, is it ?
> 
> It can't be a semphore because it is taken in packet processing,
> and thus softint handling, paths.

Right, and I missed the fact that we did indeed take the semaphore and
not the lock in the _set_ functions which is just fine, we can actually
schedule.... except in set_multicast...

Is there any reason we actually _need_ to get the xmit lock in this one
specifically ?

Ben.
