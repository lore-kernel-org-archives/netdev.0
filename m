From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 19:08:06 -0200
Message-ID: <41F01DB6.3070605@conectiva.com.br>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com> <41EF29BE.2020807@conectiva.com.br> <20050120085454.GA31160@infradead.org> <41EFC671.6000706@conectiva.com.br> <41EFCC51.8030700@conectiva.com.br> <20050120172522.GF6839@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20050120172522.GF6839@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes escreveu:
> On Thu, Jan 20, 2005 at 01:20:49PM -0200, Arnaldo Carvalho de Melo wrote:
  >>Take a look at this patch, it shows how I think the transitional
>>stage should be, the protocols will just use (IRDA for the example):
> 
> 
> 	Can't we just transition IrDA sockets to "future", rather than
> "transitional". This way we are done, and no longer need to worry
> about it. I mean, you already did the patch, so what's the reason of
> holding back ?

No, no reason, this latest scheme is good to balance the needs of
performance protocols critical protocols (tcp, etc) and the ones
where the overhead of a private slabcache is too much, the transitional
solution is just to keep the "old protocols", i.e. the ones not
converted yet, working for the time being. IRDA, from what we
discussed, will be converted today to its final form, that is,
without an slab cache, aggregate kmalloc at sk_alloc time, not using
anymore the generic "sock" slab.

- Arnaldo
