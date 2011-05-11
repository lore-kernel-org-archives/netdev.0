From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 11 May 2011 23:31:47 +0200
Message-ID: <201105112331.47954.arnd@arndb.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<20110510112734.54160824@lxorguk.ukuu.org.uk>
	<2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
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
In-Reply-To: <2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
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

On Tuesday 10 May 2011, Subhasish Ghosh wrote:
> 
> >> Yes, In case if we allow the ALL implementation, it hogs the CPU.
> >> In that case we do not need the PRU. The whole purpose of the PRU
> >> is to offload the processor for any such implementations. 
> > 
> > So the kernel presumably needs to switch between using the PRU and native
> > according to the number of ids being requested at the time ?
> 
> All the IDs are programmed into the PRU data RAM.
> The Kernel receives interrupts based upon these IDs.
> I could not clearly follow "PRU and native", could you please elaborate.

We would really like all CAN drivers to behave the same way. All other
drivers are able to work without filters, so pruss_can should allow that
too, even if it becomes a CPU hog at that time.

It seems to me that the pruss can implementation has one thing backwards:
it assumes a specific usage model for CAN that it is trying to do offload
for. However, that usage model is currently not even supported by Socket
CAN. If I understand Wolfgang correctly, it is in fact considered an
unwanted limitation of the pruss can driver, instead of a useful feature.

If that interpretation is right, I would seriously recommend rethinking
the design of the CAN firmware for pruss, so you can start doing something
useful with the offload engine that fits into the Socket CAN API, or that
would be a useful extension to Socket CAN that is also implementable in
the kernel for all other drivers in a meaningful way.

	Arnd
