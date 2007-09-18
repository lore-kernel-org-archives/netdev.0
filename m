From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 7/7] CAN: Add documentation
Date: Tue, 18 Sep 2007 02:51:44 -0400
Message-ID: <20070918025144.71dcb85b.billfink@mindspring.com>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100441.18347.7@janus.isnogud.escape.de>
	<20070917103003.109ae665.randy.dunlap@oracle.com>
	<ygfps0hrqj5.fsf@janus.isnogud.escape.de>
	<1190061421.2995.44.camel@chaos>
	<ygflkb5rp9d.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Randy Dunlap <randy.dunlap@oracle.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:35817 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753986AbXIRGwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 02:52:36 -0400
In-Reply-To: <ygflkb5rp9d.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 Sep 2007, Urs Thuermann wrote:

> Thomas Gleixner <tglx@linutronix.de> writes:
> 
> > Please do, having the patch in mail makes it easier to review and to
> > comment.
> 
> OK, here it is:

One more typo.

> This patch adds documentation for the PF_CAN protocol family.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> 
> ---
>  Documentation/networking/00-INDEX |    2 
>  Documentation/networking/can.txt  |  635 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 637 insertions(+)
> 
> Index: net-2.6.24/Documentation/networking/can.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ net-2.6.24/Documentation/networking/can.txt	2007-09-17 21:57:29.000000000 +0200
> @@ -0,0 +1,635 @@
> +============================================================================
> +
> +can.txt
> +
> +Readme file for the Controller Area Network Protocol Family (aka Socket CAN)
> +
> +This file contains
> +
> +  1 Overview / What is Socket CAN
> +
> +  2 Motivation / Why using the socket API
> +

...

> +============================================================================
> +
> +1. Overview / What is Socket CAN
> +--------------------------------
> +
> +The socketcan package is an implementation of CAN protocols
> +(Controller Area Network) for Linux.  CAN is a networking technology
> +which has widespread use in automation, embedded devices, and
> +automotive fields.  While there have been other CAN implementations
> +for Linux based on character devices, Socket CAN uses the Berkeley
> +socket API, the Linux network stack and implements the CAN device
> +drivers as network interfaces.  The CAN socket API has been designed
> +as similar as possible to the TCP/IP protocols to allow programmers,
> +familiar with network programming, to easily learn how to use CAN
> +sockets.
> +
> +2. Motivation / Why using the socket API
> +----------------------------------------
> +
> +There have been CAN implementations for Linux before Socket CAN so the
> +question arises, why we have started another project.  Most existing
> +implementations come as a device driver for some CAN hardware, they
> +are based on character devices and provide comparatively little
> +functionality.  Usually, there is only a hardware-specific device
> +driver which provides a character device interface to send and
> +receive raw CAN frames, directly to/from the controller hardware.
> +Queueing of frames and higher-level transport protocols like ISO-TP
> +have to be implemented in user space applications.  Also, most
> +character-device implementations support only one single process to
> +open the device at a time, similar to a serial interface.  Exchanging
> +the CAN controller requires employment of another device driver and
> +often the need for adaption of large parts of the application to the
> +new driver's API.
> +
> +Socket CAN was designed to overcome all of these limitations.  A new
> +protocol family has been implemented which provides a socket interface
> +to user space applications and which builds upon the Linux network
> +layer, so to use all of the provided queueing functionality.  A device
> +driver for CAN controller hardware registers itself with the Linux
> +network layer as a network device, so that CAN frames from the
> +controller can be passed up to the network layer and on to the CAN
> +protocol family module and also vice-versa.  Also, the protocol family
> +module provides an API for transport protocol modules to register, so
> +that any number of transport protocols can be loaded or unloaded
> +dynamically.  In fact, the can core module alone does not provide any
> +protocol and cannot be used without loading at least one additional
> +protocol module.  Multiple sockets can be opened at the same time,
> +on different or the same protocol module and they can listen/send
> +frames on different or the same CAN IDs.  Several sockets listening on
> +the same interface for frames with the same CAN ID are all passed the
> +same received matching CAN frames.  An application wishing to
> +communicate using a specific transport protocol, e.g. ISO-TP, just
> +selects that protocol when opening the socket, and then can read and
> +write application data byte streams, without having to deal with
> +CAN-IDs, frames, etc.
> +
> +Similar functionality visible from user-space could be provided by a
> +character decive, too, but this would lead to a technically inelegant
> +solution for a couple of reasons:

"decive" -> "device" above.

						-Bill
