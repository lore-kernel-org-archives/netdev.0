From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Tue, 17 May 2005 19:57:03 -0700 (PDT)
Message-ID: <20050517.195703.104034854.davem@davemloft.net>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<20050517190343.2e57fdd7.akpm@osdl.org>
	<Pine.LNX.4.62.0505171941340.21153@graphe.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: christoph@lameter.com
In-Reply-To: <Pine.LNX.4.62.0505171941340.21153@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers for e1000
Date: Tue, 17 May 2005 19:52:38 -0700 (PDT)

> > > -	txdr->buffer_info = vmalloc(size);
> > > +	txdr->buffer_info = kmalloc_node(size, GFP_KERNEL, node);
> > 
> > How come that this is safe to do
> 
> Because physically contiguous memory is usually better than virtually 
> contiguous memory? Any reason that physically contiguous memory will 
> break the driver?

The issue is whether size can end up being too large for
kmalloc() to satisfy, whereas vmalloc() would be able to
handle it.
