From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 8 Jan 2009 11:27:16 -0800
Message-ID: <20090108192716.GA19863@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu>
	<20090108.111610.132149837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090108.111610.132149837.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2009 at 11:16:10AM -0800, David Miller wrote:
> From: Ira Snyder <iws@ovro.caltech.edu>
> Date: Wed, 7 Jan 2009 11:50:52 -0800
> 
> > This adds support to Linux for a virtual ethernet interface which uses the
> > PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> > method of communication for two devices connected by a PCI interface.
> 
> Well, it looks like much more than that to me.
> 
> What is this UART thing in here for?
> 
> I can only assume it's meant to be used as a console port between the
> x86 host and the powerpc nodes.
> 

Exactly right. I needed it to tell the U-Boot bootloader to tftp the
kernel and boot the board. These boards don't keep their PCI settings
(assigned by the BIOS at boot) over a soft or hard reset.

I couldn't think of a better way to get them started.

> You haven't even mentioned this UART aspect even indirectly in the
> commit message.
> 

Sorry, I'll add something about it.

> This just looks like yet another set of virtualization drivers
> to me.  You could have just have easily built this using your
> own PCI backplane framework, and using the virtio stuff on top.
> 
> And the virtio stuff has all kinds of snazzy optimizations that
> will likely improve your throughput, it has console drivers that
> distributions already probe for and attach appropriately, etc.
> 
> In short I really don't like this conceptually, it can be done
> so much better using facilities we already have that are
> heavily optimized and userland understands already.

I've had a really hard time understanding the virtio code. I haven't
been able to find much in the way of documentation for it. Can you point
me to some code that does anything vaguely similar to what you are
suggesting?

Arnd Bergmann said that there is a similar driver (for different
hardware) that uses virtio, but it is very slow, because it doesn't use
the DMA controller to transfer data. I need at very minimum 40MB/sec of
client -> host data transfer.

Thanks for the comments,
Ira

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
