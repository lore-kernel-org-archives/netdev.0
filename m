From: David Miller <davem@davemloft.net>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Mon, 27 Jun 2011 15:49:21 -0700 (PDT)
Message-ID: <20110627.154921.1544030815492828408.davem@davemloft.net>
References: <4E04C961.9010302@goop.org>
	<1308938183.2532.8.camel@edumazet-laptop>
	<1309185724.32717.241.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, xen-devel@lists.xensource.com,
	eric.dumazet@gmail.com, rusty@rustcorp.com.au
To: Ian.Campbell@eu.citrix.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1309185724.32717.241.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 27 Jun 2011 15:42:04 +0100

> However it seems like this might still have a problem if your SKBs are
> ever cloned. What happens in this case, e.g if a user of AF_PACKET sends
> a broadcast via a device associated with a bridge[1] (where it would be
> flooded)?

You don't need a bridge to get a clone on transmit, the packet
scheduler can do clones.  Just grep for skb_clone in the packet
action handlers net/sched/act_*.c
