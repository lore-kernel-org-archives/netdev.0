From: "David S. Miller" <davem@davemloft.net>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 11:02:10 -0800
Message-ID: <20050112110210.18ccda02.davem@davemloft.net>
References: <20050112122300.GA12155@xi.wantstofly.org>
	<20050112125336.GH26856@postel.suug.ch>
	<20050112130940.GA12547@xi.wantstofly.org>
	<20050112122300.GA12155@xi.wantstofly.org>
	<20050112125336.GH26856@postel.suug.ch>
	<20050112.220816.56650893.yoshfuji@linux-ipv6.org>
	<20050112132126.GI26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050112132126.GI26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Jan 2005 14:21:26 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050112.220816.56650893.yoshfuji@linux-ipv6.org> 2005-01-12 22:08
> > How about adding multiple tunnels (with same ipip_bucket(t))
> > concurrently? :-)
> > 
> 
> * Lennert Buytenhek <20050112130940.GA12547@xi.wantstofly.org> 2005-01-12 14:09
> > What if you add two tunnels at the same time?  (Or is that perhaps
> > synchronised on a higher level?)
> 
> Not possible, protected via rtnl semaphore acquired in default
> handler of dev_ioctl.

Yeah.  Alexey does this trick everywhere, when we have the RTNL semaphore
held we only need to lock for the actual linkage operation that adds the
new object to the tree.
