From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Wed, 26 May 2010 12:15:09 +0200
Message-ID: <4BFCF4AD.6030000@grandegger.com>
References: <201005261114.03214.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201005261114.03214.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
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

Hi Matthias,

On 05/26/2010 11:14 AM, Matthias Fuchs wrote:
> This patch adds a driver for esd's USB high speed
> CAN interface. The driver supports devices with
> multiple CAN interfaces.
> 
> Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
> ---
> version 3: 
>  - remove bus-error reporting feature because 
>    it cannot be controlled by user on demand
>    with current device's firmware
>  - rebased against current net-next-2.6 tree
> 
> version 2: 
>  - use bus-error reporting and counters
>  - minor cleanup
>  - rebased against current net-next-2.6 tree
>  - initial post to linux-usb list for review

I get the following compiler warnings when compiling the kernel:

 CC      drivers/net/can/usb/esd_usb2.o
drivers/net/can/usb/esd_usb2.c: In function 'esd_usb2_write_bulk_callback':
drivers/net/can/usb/esd_usb2.c:466: error: implicit declaration of function 'usb_buffer_free'
drivers/net/can/usb/esd_usb2.c: In function 'esd_usb2_setup_rx_urbs':
drivers/net/can/usb/esd_usb2.c:562: error: implicit declaration of function 'usb_buffer_alloc'
drivers/net/can/usb/esd_usb2.c:563: warning: assignment makes pointer from integer without a cast
drivers/net/can/usb/esd_usb2.c: In function 'esd_usb2_start_xmit':
drivers/net/can/usb/esd_usb2.c:732: warning: assignment makes pointer from integer without a cast
make[4]: *** [drivers/net/can/usb/esd_usb2.o] Error 1

This is due to commit e26bcf37234c67624f62d9fc95f922b8dbda1363.
You need a similar fix like for ems_usb.c. Are you using a recent
version of the net-next-2.6 tree?

Wolfgang.
