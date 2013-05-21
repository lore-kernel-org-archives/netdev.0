From: Pekka Riikonen <priikone@iki.fi>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 19:02:19 +0200 (CEST)
Message-ID: <alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>   <20130520101601.14133.874.stgit@ladj378.jer.intel.com>  <1369063764.3301.182.camel@edumazet-glaptop>  <519B2237.20204@linux.intel.com> <1369142926.3301.213.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Dave Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369142926.3301.213.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 May 2013, Eric Dumazet wrote:

: > > Alternatively, use a napi_id instead of a pointer.
: > 
: > I'm not sure I understand what you propose.
: 
: Oh well.
: 
: To get a pointer to a struct net_device, we can use ifindex, and do a
: rcu lookup into a hash table to get the net_device. We do not need
: {pointer,ifindex} but {ifindex} is enough
: 
: My suggestion is to not have skb->skb_ref but skb->napi_index : Its safe
: to copy its value from skb->napi_index to sk->napi_index without
: refcounting.
: 
: All NAPI need to get a unique napi_index, and be inserted in a hash
: table for immediate/fast lookup.
: 
Maybe even that's not needed.  Couldn't skb->queue_mapping give the 
correct NAPI instance in multiqueue nics?  The NAPI instance could be made 
easily available from skb->dev.  In any case an index is much better than 
a new pointer.

	Pekka
