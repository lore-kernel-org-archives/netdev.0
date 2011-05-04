From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 4 May 2011 17:57:50 +0200
Message-ID: <20110504155750.GC322@e-circ.dyndns.org>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<201104271525.28512.arnd@arndb.de>
	<15AD189F851849F69A011B6F4D1DDB6C@subhasishg>
	<201105041511.54095.arnd@arndb.de>
	<4DC163D7.9010309@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
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

> 
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
ack.
> 
> > Is that something that Subhasish or someone else could to as a prerequisite
> > to merging the driver?
> 
> Any ideas on how to handle hardware filtering in a generic way are
> welcome. I will try to come up with a proposal sooner than later.

When doing so, I'd vote for an unlimited(by software) list of hardware filters (id/mask).
The hardware must abort when no more filters are available.
I think that when using hardware filters, knowing the actual device
with it's amount of hardware filters is the least of your problems.
Userspace applications that suddenly stop working properly due to
hw filters (i.e. some traffic not coming in anymore) will be a major
source of bugreports.

Kurt
