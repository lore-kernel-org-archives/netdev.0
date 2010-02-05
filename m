From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize
 modifications
Date: Sat, 6 Feb 2010 00:04:07 +0200
Message-ID: <20100205220407.GA27953@x200>
References: <20100203203929.GA6168@x200>
 <4B6AF36A.3050402@trash.net>
 <4B6AFE22.20304@trash.net>
 <20100204194744.GA4185@x200>
 <4B6BEC23.8020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B6BEC23.8020101@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 05, 2010 at 11:00:03AM +0100, Patrick McHardy wrote:
> Actually it doesn't seem like much more work to allow changing
> table size, the main problem is that sysfs module parameters
> don't seem to fit into the network namespace model at all.

Well, they "fit" as they're global because modules are global.
So we can make every netns hashtable size equals to module param,
or make it bounded by module param
or make initial hashtable size and not bounded
or million other things.

> Please be more specific about your suspected slowdowns.

I meant net->ct.htable_size in hash functions _if_ you're not allowing
changing it from inside netns.

> What's "everything"? What's different about the hashsize
> compared to the many members we already moved to per-netns
> structs?

But whatever. I think per-netns hashtable size shouldn't be done
that late.
