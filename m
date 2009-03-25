From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH] net: Add support for the OpenCores 10/100 Mbps
	Ethernet MAC.
Date: Wed, 25 Mar 2009 15:52:43 +0100
Message-ID: <20090325145243.GB11710@avionic-design.de>
References: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de> <20090324111359.GA6859@ports.donpac.ru> <20090324.163630.226102764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pazke@donpac.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760987AbZCYOxn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090324.163630.226102764.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller wrote:
> From: Andrey Panin <pazke@donpac.ru>
> Date: Tue, 24 Mar 2009 14:13:59 +0300
> 
> > On 083, 03 24, 2009 at 11:18:43AM +0100, Thierry Reding wrote:
> > > +static void ethoc_copy_to_io(void __iomem *dest, struct sk_buff *src)
> > > +{
> > > +	size_t size = (src->len & 0x3) ? (src->len & ~0x3) + 4 : src->len;
> > > +	u8 buffer[ETHOC_BUFSIZ];
> > 
> > Using 1536 bytes of stack is not very nice.
> 
> Agreed, this stuff must be fixed.
> 
> You could use skb_copy_and_csum_dev() directly into your buffer, then
> pad out the end of the buffer with a memset() call, if necessary.
>-
> Actually, no you can't...
> 
> You should not be using memcpy() to store things into I/O memory.
> That's what memcpy_io() is for.
> 
> I think because of all of these special padding cases and the use
> of I/O memory instead of DMA, there is no real gain by using
> skb_copy_and_csum_dev() in this driver.

Actually these special padding cases are only necessary for the FPGA interface
we use and have nothing to do with the OpenCores Ethernet MAC itself. The ARM
memcpy_{to,from}io() functions don't work correctly with my setup because our
VLIO bridge implementation apparently doesn't handle byte-wise accesses very
well.

I can work around that by implementing the memcpy_{to,from}io() functions
differently, though. That may however break anything else using those
functions.

> Just let the network stack checksum the packet, and use memcpy_io() here
> which is the currect interface for copying data into I/O memory.

See follow-up patch in reply to the first patch.

Cheers,
Thierry
