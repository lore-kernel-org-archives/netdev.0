From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Fri, 19 Nov 2004 10:26:31 +1100
Message-ID: <1100820391.25521.14.camel@gaston>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
	 <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jason.mcmullan@timesys.com, netdev@oss.sgi.com,
        Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-18 at 11:52 -0600, Andy Fleming wrote:

> 1) How should we pass initialization information from the system to the 
> bus.  Information like which irq to use for each PHY, and what the 
> address space for the bus's controls is.  I would like to enforce 
> encapsulation so that the ethernet drivers don't need to know this 
> information, or pass it to the bus.

Unfortunately, this is all quite platform specific and the ethernet
driver may be the only one to know what to do here... add to that
various special cases of the way the PHY is wired or controlled, I think
we can't completely avoid special casing...

> 2) How should we reflect the dependency of the ethernet driver on the 
> mii bus driver?

The ethernet driver can instanciate the PHYs at it's childs, though the
case of several MACs sharing PHYs will be difficult to represent...

> 3) How should we bind ethernet drivers to PHY drivers?

I would have them instanciated by the ethernet driver. Besides, the PHY
driver will need to be able to identify it's "parent" driver in some
ways to deal with special cases. It would be nice to have a library of
utility code to independently deal with link tracking (basically what
drivers like sungem do independently), with a callback to the ethernet
driver to inform it of actual changes (notifier ?). MACs often have
autopoll features and PHY often have interrupts, but from experience,
that's not very useful and a good old timer based polling tend to do a
better job most of the time.

> Oh, and a 4th side-issue:
> Should each PHY have its own file?  Or should we dump all the PHY 
> drivers in one file?  And if so, should THAT file be separate from the 
> mii bus implementation file?

I'd put all bcm5xxx in the same file ... they can be put together by
families...

Also, 
