From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100,
 xircom_tulip_cb, iph5526
Date: Thu, 27 Jan 2005 16:48:43 -0800
Message-ID: <20050127164843.08bdb307.davem@davemloft.net>
References: <41F952F4.7040804@pobox.com>
	<20050127225725.F3036@flint.arm.linux.org.uk>
	<20050127153114.72be03e2.davem@davemloft.net>
	<20050128001430.C22695@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        greg@kroah.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20050128001430.C22695@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 00:14:30 +0000
Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> The fact of the matter is that eepro100.c works on ARM, e100.c doesn't.
> There's a message from me back on 30th June 2004 at about 10:30 BST on
> this very list which generated almost no interest from anyone...

I see.  Since eepro100 just uses a fixed set of RX buffers in the
ring (ie. the DMA links are never changed) it works.

This adapter was definitely developed for a system that has to have
PCI device DMA and CPU cached data accesses in the same coherency
space in order to use their weird RX chaining thing.

So essentially, e100 needs to have it's RX logic rewritten so that
it uses a static RX descriptor set of buffers and skb_copy()'s them
to push the packets into the stack.
