From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 09:56:32 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1103240955450.2006-100000@iolanthe.rowland.org>
References: <201103241415.45115.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Steve Calfee <stevecalfee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michal Nazarewicz <mnazarewicz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	<broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nicolas Pitre <nicolas.pitre-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	<grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Linux USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	<roger.quadros-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Jaswinder Singh <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201103241415.45115.arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Mar 2011, Arnd Bergmann wrote:

> The documentation for the USB ethernet devices suggests that
> only some devices are supposed to use usb0 as the network interface
> name instead of eth0. The logic used there, and documented in
> Kconfig for CDC is that eth0 will be used when the mac address
> is a globally assigned one, but usb0 is used for the locally
> managed range that is typically used on point-to-point links.
> 
> Unfortunately, this has caused a lot of pain on the smsc95xx
> device that is used on the popular pandaboard without an
> EEPROM to store the MAC address, which causes the driver to
> call random_ether_address().
> 
> Obviously, there should be a proper MAC addressed assigned to
> the device, and discussions are ongoing about how to solve
> this, but this patch at least makes sure that the default
> interface naming gets a little saner and matches what the
> user can expect based on the documentation, including for
> new devices.
> 
> The approach taken here is to flag whether a device might be a 
> point-to-point link with the new FLAG_PTP setting in the usbnet
> driver_info. A driver can set both FLAG_PTP and FLAG_ETHER if

You updated the flag name in the patch but not in the description.

> it is not sure (e.g. cdc_ether), or just one of the two.
> The usbnet framework only looks at the MAC address for device
> naming if both flags are set, otherwise it trusts the flag.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
