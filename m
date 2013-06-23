From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: allow large number of tx queues
Date: Sun, 23 Jun 2013 13:29:51 +0300
Message-ID: <20130623102951.GC17316@redhat.com>
References: <1371623518.3252.267.camel@edumazet-glaptop>
 <20130619091132.GA2816@redhat.com>
 <1371635763.3252.289.camel@edumazet-glaptop>
 <20130619154059.GA13735@redhat.com>
 <1371657511.3252.324.camel@edumazet-glaptop>
 <20130619180709.GA15017@redhat.com>
 <1371716151.3252.390.camel@edumazet-glaptop>
 <20130620083530.GA23909@redhat.com>
 <51C3F5AC.2090008@redhat.com>
 <1371798750.3252.431.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	hkchu@google.com, netdev <netdev@vger.kernel.org>,
	dwmw2@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982Ab3FWK3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jun 2013 06:29:33 -0400
Content-Disposition: inline
In-Reply-To: <1371798750.3252.431.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 12:12:30AM -0700, Eric Dumazet wrote:
> On Fri, 2013-06-21 at 14:41 +0800, Jason Wang wrote:
> 
> > 1K queues (about 80 pages) looks a little bit aggressive which means we
> > may always fall back to vmalloc()?
> 
> 1K queues looks like you should use 0 queue (LLTX) in fact, so that you
> design the minimal percpu structure in the driver to fit the needs.
> 
> Using Qdisc, qith MQ, pfifo_fast, on 1000 'queues' is adding a fair
> amount of overhead and memory usage.
> 
> For example, loopback driver only needs small percpu structure (16
> bytes), as it immediately forward the packet into netif_rx() [ Which
> also use a percpu area called softnet_data ]
> 
> 

I agree it's worth considering for tun.

But the same number of queues will be there for virtio net,
and that's much more like a regular network device.

-- 
MST
