From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 10:48:19 -0700
Message-ID: <1369158499.3301.236.camel@edumazet-glaptop>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	   <20130520101601.14133.874.stgit@ladj378.jer.intel.com>
	  <1369063764.3301.182.camel@edumazet-glaptop>
	  <519B2237.20204@linux.intel.com>
	 <1369142926.3301.213.camel@edumazet-glaptop>
	 <alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Dave Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Pekka Riikonen <priikone@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 19:02 +0200, Pekka Riikonen wrote:

> Maybe even that's not needed.  Couldn't skb->queue_mapping give the 
> correct NAPI instance in multiqueue nics?  The NAPI instance could be made 
> easily available from skb->dev.  In any case an index is much better than 
> a new pointer.

We do not keep skb->dev information once a packet leaves the rcu
protected region.

Once packet is queued to tcp input queues, skb->dev is NULL.
