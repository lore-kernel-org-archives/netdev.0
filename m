From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Wed, 26 Jan 2005 14:25:12 +0100
Message-ID: <20050126132512.GA18220@xi.wantstofly.org>
References: <20050103171227.GD7370@esmail.cup.hp.com> <1104812294.1085.53.camel@jzny.localdomain> <20050119144711.3fdd3d93.davem@davemloft.net> <20050119151853.259de49a@dxpl.pdx.osdl.net> <20050119164640.6c67bdfa.davem@davemloft.net> <52r7kgu5n5.fsf@topspin.com> <20050119230526.393a5184.davem@davemloft.net> <20050120085611.33f9485e@dxpl.pdx.osdl.net> <20050121105452.GA12988@xi.wantstofly.org> <20050125222705.1ee878fd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, roland@topspin.com, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050125222705.1ee878fd.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2005 at 10:27:05PM -0800, David S. Miller wrote:

> > If multiple CPUs can call into the tunneling drivers without taking
> > any locks, we'd need some extra locking in there, or just do what
> > Alexey describes and keep track of recursion in the skb.
> 
> Another idea is that, just like how loopback made it's statistics
> per-cpu for LLTX support, this recursion variable could be per-cpu
> as well.

I've thought about this a bit, and the only sane way of doing recursion
detection that doesn't involve 'struct net_device' would be to keep track
of the recursion depth (perhaps per-CPU as you suggest) and tossing the
packet when it exceeds some random value, right?

To reproduce the current behaviour more closely you'd have to keep a
small per-CPU array of 'struct net_device *' pointers as a kind of
recursion stack, and toss the packet when you hit a net_device that's
already on the list.  But that seems like slight overkill.


--L
