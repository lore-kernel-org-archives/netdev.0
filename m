From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: [PATCH 0/3] add support for Janz MODULbus devices
Date: Mon, 29 Mar 2010 09:58:49 -0700
Message-ID: <1269881932-3803-1-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <>
References: <>
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

This patch series adds support for the Janz CMOD-IO carrier board, as well
as the Janz VMOD-ICAN3 Intelligent CAN controller and the Janz VMOD-TTL
Digital IO controller. The CMOD-IO carrier board is a PCI to MODULbus
bridge, into which plug MODULbus daughterboards.  I only have access to two
types of daughtercards, the VMOD-ICAN3 and VMOD-TTL boards mentioned above.

The CAN driver has been tested under high loads. I am able to generate ~60%
bus utilization. With two VMOD-ICAN3 boards looped back to each other,
neither one loses any packets when only a single board is generating
packets at maximum speed. Once both boards start generating packets, one
board will sometimes loose arbitration, and cause some lost packets.

After much review from the last posting of the series, I believe that this
should be ready for mainline. Many thanks to everyone that helped!

RFCv4 -> RFCv5:
- removed some dev_dbg() statements
- change default MODULbus modules to "none"
- accept both "empty" and "" in the MODULbus modules parameter
- print an error message when no MODULbus modules are specified
- add sysfs support to get/set CAN bus termination
- fix error-active and error-passive state reporting
- add support for netlink bus-error messages
- fixed sparse warnings
- used mfd-core API for multifunction device probing

RFCv3 -> RFCv4:
- addressed many review comments
- switch to NAPI
- add TX flow control
- mark functions with __devinit and __devexit
- add sysfs readout of MODULbus number (hex switch)
- implement GPIO driver for VMOD-TTL

RFCv2 -> RFCv3:
- addressed many review comments
- correct CAN bus error handling
- use struct device to track subdevices
- use structures for register layout
- add lots of #defines for register values
- use better function prefixes

RFCv1 -> RFCv2:
- converted to a multi-driver model
- addressed many review comments
- added CAN bus error handling
- use a work function only instead of work + NAPI
- use SJA1000 bittiming calculation code

Thanks,
Ira
