From: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [RFC][PATCH 0/3] net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 14:16:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
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

NAK.  ->base_addr casting is a Bad Idea(tm) and natsemi "solution" isn't
(thanks for spotting that crap in natsemi, though; will fix...)

Note that there is no such thing as "generic IO base address" - it _is_
private and in the best case current ->base_addr is a scratch register
probably used for something vaguely connected with some IO, but it's
really up to driver...
