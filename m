From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH net-next-2.6 v2 0/2] can: add driver for Softing card
Date: Tue, 4 Jan 2011 16:05:13 +0100
Message-ID: <20110104150513.GA321@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
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

This series will add a driver for Softing PCMCIA CAN card.

This core CAN networking code exists for a few years in the
socketCAN repository.
The updates since the latest socketCAN version:
* PCMCIA interfacing changed
* seperation between the two drivers via a platform:softing device
* added conditional bus-error reporting

About the platform_device ...
Softing Gmbh has PCMCIA & PCI cards. Both share the same
Dual Port RAM (DPRAM) interface. Therefore, the driver is split in 2 stages:

[1/2] softing.ko: Generic platform bus device driver
It expects a platform:softing device with an IO range that contains
the DPRAM, and an IRQ line.

[2/2] softing_cs.ko: PCMCIA driver
This driver will create a platform:softing device on top of the
pcmcia device.

The 2 driver are not linked in a way that softing.ko depends
on softing_cs.ko or vice versa. The reason for doing so is that
the DPRAM interface takes quite some code, and building it directly
on the PCMCIA or PCI device was difficult to follow.
The present design eliminates the need for exotic sysfs API's since
all sysfs attributes know they are attached to a platform_device.

Differences since v1 of this series:
* whitespace issues
* use of time_after() to measure elapsed time.
* don't copy data for RTR frames (see commit since v1)
* use usleep_range(), not schedule().
* threaded irq
* fix iomem access (verify with sparse)
* totally 'endian-safe'
* drop error frame detection again. It's not right that when
  bus 1 enables error frames, bus 2 would get error frames too.
* drop the Kconfig dependency between softingcs.ko & softing.ko

Kurt
