From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 11 May 2011 23:44:43 +0200
Message-ID: <201105112344.44171.arnd@arndb.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
	<201105112331.47954.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nsekhar-l0cyMroinI0@public.gmane.org, open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201105112331.47954.arnd-r2nGTMty4D4@public.gmane.org>
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

On Wednesday 11 May 2011, Arnd Bergmann wrote:
> If that interpretation is right, I would seriously recommend rethinking
> the design of the CAN firmware for pruss, so you can start doing something
> useful with the offload engine that fits into the Socket CAN API, or that
> would be a useful extension to Socket CAN that is also implementable in
> the kernel for all other drivers in a meaningful way.

I've looked some more into the CAN socket implementation, and I suppose that
the idea of the pruss driver was really to help do the work from the
can_rcv_filter function in hardware.

Doing this right would really mean supporting both a mode where any new
filter that gets added to socket can ends up being added to the hardware
as long as it fits, similar to how we can add additional unicast mac
addresses to an ethernet NIC. However, when the filters from all user
sockets combined can not be represented in the hardware driver, the hardware
needs to be put into a less efficient mode where all packets are returned
to the kernel and processed in software.

	Arnd
