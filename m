From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 3 Feb 2010 21:09:48 +0200
Message-ID: <20100203190948.GA5182@x200>
References: <1265108690.2861.118.camel@tonnant>
 <1265110504.2861.135.camel@tonnant>
 <1265129192.2861.141.camel@tonnant>
 <4B685756.8010107@trash.net>
 <1265130426.2861.158.camel@tonnant>
 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
 <1265134598.2861.191.camel@tonnant>
 <4B6870AF.6060109@trash.net>
 <4B6967BC.600@trash.net>
 <1265222289.2861.290.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1265222289.2861.290.camel@tonnant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 03, 2010 at 01:38:09PM -0500, Jon Masters wrote:
> *). Per namespace cacheing allocation (the cachep bits). We know it's
> still possible for weirdness to happen in the SLAB cache here.

Tiny race, needs reproducer.

> *). Per namespace hashsize tracking. Existing code corrupts hashtables
> if the global size is changed when there is more than one netns

I think, no.
Changing hash size will change hashsize for all netns, current and future.

> *). Per namespace expectations. This is for similar reasons to the need
> for multiple hashtables, though I haven't poked at that.

Expectation cache is not SLAB_DESTROY_BY_RCU, so the logic doesn't
apply, I hope.

> I also think it is necessary to expose net namespace layout

Not necessary. Why?

> and configuration via sysfs

Which configuration?

> or some other interface, add a net->id parameter (and may even an optional name),

No name, please :-)
->id is more or less required for per-netns conntrack cache.

> etc. Where does netns discussion happen, on netdev I would presume?

Yep. And containters@, I think.
