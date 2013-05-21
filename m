From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 11:49:21 -0700 (PDT)
Message-ID: <20130521.114921.460497085402760002.davem@davemloft.net>
References: <519B2237.20204@linux.intel.com>
	<1369142926.3301.213.camel@edumazet-glaptop>
	<alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eliezer.tamir@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: priikone@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Riikonen <priikone@iki.fi>
Date: Tue, 21 May 2013 19:02:19 +0200 (CEST)

> On Tue, 21 May 2013, Eric Dumazet wrote:
> 
> : > > Alternatively, use a napi_id instead of a pointer.
> : > 
> : > I'm not sure I understand what you propose.
> : 
> : Oh well.
> : 
> : To get a pointer to a struct net_device, we can use ifindex, and do a
> : rcu lookup into a hash table to get the net_device. We do not need
> : {pointer,ifindex} but {ifindex} is enough
> : 
> : My suggestion is to not have skb->skb_ref but skb->napi_index : Its safe
> : to copy its value from skb->napi_index to sk->napi_index without
> : refcounting.
> : 
> : All NAPI need to get a unique napi_index, and be inserted in a hash
> : table for immediate/fast lookup.
> : 
> Maybe even that's not needed.  Couldn't skb->queue_mapping give the 
> correct NAPI instance in multiqueue nics?  The NAPI instance could be made 
> easily available from skb->dev.  In any case an index is much better than 
> a new pointer.

Queue mapping is more volatile, and consider layered devices.
