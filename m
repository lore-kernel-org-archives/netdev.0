From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 4 May 2011 16:48:36 +0200
Message-ID: <201105041648.37199.arnd@arndb.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<201105041511.54095.arnd@arndb.de>
	<4DC163D7.9010309@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DC163D7.9010309-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 04 May 2011, Wolfgang Grandegger wrote:
> On 05/04/2011 03:11 PM, Arnd Bergmann wrote:

> > Wolfgang, I'm a bit worried by the API being split between sockets and sysfs.
> > The problem is that once the sysfs API is established, users will start
> > relying on it, and you can no longer migrate away from it, even when
> > a later version of the Socket CAN also supports setting through a different
> > interface. What is the current interface to set mail box IDs in software?
> 
> Note that this CAN controller is *very* special. It cannot handle all
> CAN id's due to a lack or resources. The PRUSS firmware is able to
> manage just up to 8 different CAN identifiers out of the usual 4096
> (12-bit) or even more for the extended CAN ids using 29 bits. 

So for other controllers, they can simply access every ID within
the range (12 or 29 bits), but there is no need to configure?

What are these IDs for? Do they identify a local port, a remote address,
a connection, or something else?

> There is
> no other CAN controller with such rather serious limitations and
> therefore there exists also no appropriate interface. I think using
> sysfs is OK for such device-specific parameters, at least for the time
> being.

It sounds like it's not very scalable, especially since the implementation
is done completely in firmware. Imagine a new firmware version suddenly
supporting 256 ids instead of 8 -- you'd then have to create 256 sysfs
files to be compatible if I understand you correctly.

> > How hard would it be to implement that feature in Socket CAN?
> 
> CAN controllers usually provide some kind of hardware CAN id filtering,
> but in a very hardware dependent way. A generic interface may be able to
> handle the PRUSS restrictions as well. CAN devices are usually
> configured through the netlink interface. e.g.
> 
>   $ ip link set can0 up type can bitrate 125000
> 
> and such a common interface would be netlink based as well.

Agreed.

> > Is that something that Subhasish or someone else could to as a prerequisite
> > to merging the driver?
> 
> Any ideas on how to handle hardware filtering in a generic way are
> welcome. I will try to come up with a proposal sooner than later.

It sounds to me like the best solution would be change the firmware
to lift that restriction and simply allow all IDs, in case it's not
actually a hardware limitation (which sounds unlikely).

If that's not possible, maybe it's possible to define a generic
filtering interface using netlink, and then either do it completely
in the kernel, or using the hardware support.

	Arnd
