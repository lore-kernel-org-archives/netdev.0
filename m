From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 0/3] net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 12:52:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029115233.GA11391@infradead.org>
References: <1099044244.9566.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Disposition: inline
In-Reply-To: <1099044244.9566.0.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 01:04:04PM +0300, Pekka Enberg wrote:
> Hi,
> 
> This patch introduces a generic netdev_ioaddr and converts natsemi and
> 8139too drivers to use it.
> 
> With the recent __iomem annotations, the network drivers need to either
> invent this wrapper (like natsemi has done) or duplicate the IO base
> address in their private data (similar to 8139too).  Therefore, lets
> make netdev_ioaddr generic before it is all over the place.

This casting around sounds like a bad idea.  Either add another

	void __iomem *mmioaddr;

member to struct net_device, or better move that completely into the
driver-private structure which seems the better level of abstraction.
