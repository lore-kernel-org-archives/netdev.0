From: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
Subject: Re: net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 20:38:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029193827.GV24336@parcelfarce.linux.theplanet.co.uk>
References: <1099044244.9566.0.camel@localhost> <20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk> <courier.418290EC.00002E85@courier.cs.helsinki.fi> <m3y8hpbaf9.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, davem@davemloft.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3y8hpbaf9.fsf@defiant.pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 09:18:18PM +0200, Krzysztof Halasa wrote:
> "Pekka J Enberg" <penberg@cs.helsinki.fi> writes:
> 
> > Yup, I thought about that after I sent the patch. However, as it
> > stands now, many network drivers use netdev->base_addr for just that.
> > Perhaps it should be nuked completely instead?
> 
> I thinks so. With ifmap, SIOCSIFMAP, ifr_map, mem_end etc.,
> irq, if_port, dma.

SIOCSIFMAP is unfortunate, but legitimate - it passes more or less
opaque structure to driver and lets driver interpret it.

SIOCGIFMAP, OTOH, is really bad - among other things, for many drivers
it leaks ioremapped addresses to userland.  And *that* is a LARTable
offense - it's an information that makes no sense whatsoever for userland
code and should never be exposed, just as with any kernel pointers.

What uses ->base_addr from the data returned by SIOCGIFMAP?
