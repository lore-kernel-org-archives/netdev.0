From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [janitor] remove casts in drivers/net/arm/
Date: Tue, 02 Mar 2004 14:29:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4044E07E.8000409@pobox.com>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>	<20040229143436.4bb884ee.rddunlap@osdl.org>	<20040302121042.A9931@flint.arm.linux.org.uk>	<4044D86C.70709@pobox.com>	<20040302110237.0f580736.rddunlap@osdl.org>	<4044DB78.7040309@pobox.com> <20040302111700.76c0b381.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20040302111700.76c0b381.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> On Tue, 02 Mar 2004 14:07:36 -0500 Jeff Garzik wrote:
> 
> | Randy.Dunlap wrote:
> | > On Tue, 02 Mar 2004 13:54:36 -0500 Jeff Garzik wrote:
> | > 
> | > | Russell King wrote:
> | > | > On Sun, Feb 29, 2004 at 02:34:36PM -0800, Randy.Dunlap wrote:
> | > | > 
> | > | >> drivers/net/arm/am79c961a.c |   18 +++++++++---------
> | > | >> drivers/net/arm/ether1.c    |   18 +++++++++---------
> | > | >> drivers/net/arm/ether3.c    |   18 +++++++++---------
> | > | >> drivers/net/arm/etherh.c    |    4 ++--
> | > | >> 4 files changed, 29 insertions(+), 29 deletions(-)
> | > | > 
> | > | > 
> | > | > I think we should really consider using netdev_priv() in all these places
> | > | > so the compiler knows that 'dev' and 'priv' are related.
> | > | 
> | > | 
> | > | Good point.
> | > 
> | > I respectfully disagree, but if the maintainter won't merge
> | > them as is, so be it.
> | > 
> | > I have trouble understanding why this:
> | > 	return (char *)dev + ((sizeof(struct net_device) + 31) & ~31);
> | > is better than using a structure->field, i.e.,
> | > 	dev->priv
> | > 
> | > Can one of you enlighten me?
> | 
> | 
> | One is an additional pointer load and dereference, and one is a constant 
> | offset from the beginning of the dev structure, calculated at compile 
> | time.  netdev_priv() provides the same results as dev->priv but at less 
> | cost.
> 
> OK, thanks, I see.
> I think it's ugly, but you'll get updated patches anyway.


I wasn't rejecting your patches.

In fact, I want to apply your cast patches separate from any 
netdev_priv() cleanup.

netdev_priv() should be a separate item on the janitor todo list.

RMK however is free to reject these patches for drivers/net/arm/ of 
course...

	Jeff
