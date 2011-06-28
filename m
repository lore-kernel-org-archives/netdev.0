From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Tue, 28 Jun 2011 11:24:22 +0100
Message-ID: <1309256662.32717.311.camel@zakaz.uk.xensource.com>
References: <4E04C961.9010302@goop.org>
	<1308938183.2532.8.camel@edumazet-laptop>
	<1309185724.32717.241.camel@zakaz.uk.xensource.com>
	<20110627.154921.1544030815492828408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20110627.154921.1544030815492828408.davem@davemloft.net>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, 2011-06-27 at 23:49 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Mon, 27 Jun 2011 15:42:04 +0100
> 
> > However it seems like this might still have a problem if your SKBs are
> > ever cloned. What happens in this case, e.g if a user of AF_PACKET sends
> > a broadcast via a device associated with a bridge[1] (where it would be
> > flooded)?
> 
> You don't need a bridge to get a clone on transmit, the packet
> scheduler can do clones.  Just grep for skb_clone in the packet
> action handlers net/sched/act_*.c

Are you sure? I only see skb_cloned() and skb_clone_writeable() under
there )(3.0-rc4) and not any actual skb_clone()s.

The only actual clone I see under there is in net/sched/sch_netem.c.

However it sounds like it is expected that a clone can happen on pretty
any skb which makes the frag lifecycle issue seem like one which could
effect anything which sends a page to the network without relinquishing
complete control of it (common in any kind of zero-copy scenario).

Ian.
