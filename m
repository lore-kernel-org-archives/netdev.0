From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netdev ioctl & dev_base_lock : bad idea ?
Date: Wed, 8 Dec 2004 22:06:42 -0800
Message-ID: <20041208220642.6984519f.davem@davemloft.net>
References: <1101458929.28048.9.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1101458929.28048.9.camel@gaston>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 26 Nov 2004 19:48:49 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> I suppose there is a good reason we can't just use the rtnl_sem for
> these guys, though why isn't dev_base_lock a read/write semaphore
> instead of a spinlock ? At least on ppc, I don't think there's any
> overhead in the normal path, and this is not on a very critical path
> anyway, is it ?

It can't be a semphore because it is taken in packet processing,
and thus softint handling, paths.
