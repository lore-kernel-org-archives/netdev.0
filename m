From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 3 Feb 2010 21:51:53 +0200
Message-ID: <20100203195153.GA5576@x200>
References: <1265129192.2861.141.camel@tonnant>
 <4B685756.8010107@trash.net>
 <1265130426.2861.158.camel@tonnant>
 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
 <1265134598.2861.191.camel@tonnant>
 <4B6870AF.6060109@trash.net>
 <4B6967BC.600@trash.net>
 <1265222289.2861.290.camel@tonnant>
 <20100203190948.GA5182@x200>
 <1265226227.2861.302.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1265226227.2861.302.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 03, 2010 at 02:43:47PM -0500, Jon Masters wrote:
> On Wed, 2010-02-03 at 21:09 +0200, Alexey Dobriyan wrote:
> > On Wed, Feb 03, 2010 at 01:38:09PM -0500, Jon Masters wrote:
> > > *). Per namespace hashsize tracking. Existing code corrupts hashtables
> > > if the global size is changed when there is more than one netns
> > 
> > I think, no.
> > Changing hash size will change hashsize for all netns, current and future.
> 
> Nope. Look at the logic in nf_conntrack_set_hashsize where you iterate
> over init_net.ct.hash but don't touch other namespaces. So then you go
> setting nf_conntrack_htable_size and will deference that in accessing
> other per-namespace hashtables using the wrong size information.

> > > I also think it is necessary to expose net namespace layout
> > 
> > Not necessary. Why?
> 
> How am I as a sysadmin supposed to figure out which net namespaces exist
> on my system, and as a developer, supposed to debug these situations?

We don't expose many relations to userspace, and it's generally fine.

As a developer you fire a debugger and look at net_namespace_list.
