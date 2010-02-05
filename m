From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize
 modifications
Date: Fri, 05 Feb 2010 06:51:02 -0500
Message-ID: <1265370662.2861.769.camel@tonnant>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>
	 <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>
	 <4B6BEC23.8020101@trash.net> <4B6BFE29.1040204@trash.net>
	 <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com>
	 <4B6BFF69.6050503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6BFF69.6050503@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-02-05 at 12:22 +0100, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
> > On Fri, Feb 5, 2010 at 1:16 PM, Patrick McHardy <kaber@trash.net> wrote:
> >> OK testing looks fine, although I'm quite surprised that its actually
> >> possible to change module parameters from within non-init namespaces.
> >> How is this supposed to work at all? I don't see how sysfs could
> >> possibly provide a network namespace context ...
> > 
> > 
> > You can do in write hook
> > 
> >     if (!net_eq(current->nsproxy->net_ns, &init_net))
> >             return -EINVAL;
> 
> Right, I see. So we could actually make resizing work for all
> namespaces quite easily. Is there any reason not to do this?

Yes, but I think (2.6.34) there also needs to be a better way to expose
netns topology and visualize all the hashtables on a system - if you're
the admin you really want to be able to see all of them, not just for a
particular namespace you might be in, in addition to the perns views.

We already discussed 2.6.34, I'm only mentioning this "for the record".

Jon.


