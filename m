From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 16:40:03 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030713164003.21839eb4.davem@redhat.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
	<52u19qwg53.fsf@topspin.com>
	<20030713160200.571716cf.davem@redhat.com>
	<20030713233503.GA31793@work.bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@topspin.com, alan@storlinksemi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Larry McVoy <lm@bitmover.com>
In-Reply-To: <20030713233503.GA31793@work.bitmover.com>
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 16:35:03 -0700
Larry McVoy <lm@bitmover.com> wrote:

> On Sun, Jul 13, 2003 at 04:02:00PM -0700, David S. Miller wrote:
> > On send this doesn't matter, on receive you use my clever receive
> > buffer handling + flow cache idea to accumulate the data portion of
> > packets into page sized chunks for the networking to flip.
> 
> Please don't.  I think page flipping was a bad idea.  I think you'd be 
> better off to try and make the data flow up the stack in small enough 
> windows that it all sits in the cache.

At 10GB/sec nothing fits in the cache :-)

> One thing SGI taught me (not that they wanted to do so) is that infinitely
> large packets are infinitely stupid, for lots of reasons.  One is that
> you have to buffer them somewhere and another is that the bigger they 
> are the bigger your cache needs to be to go fast.

The whole point is to not touch any of this data.

The idea is to push the pages directly into the page cache
of the filesystem.

I'm not talking about doing this for userspace normal sys_recvmsg()
type reads, that's an entirely different topic but if we ever did
all agree to do something like that we'd have the network level
infrastructure to do it already.
