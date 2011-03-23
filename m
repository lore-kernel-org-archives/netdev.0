From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 11:46:50 -0700
Message-ID: <20110323184650.GB21728@kroah.com>
References: <4D79F068.2080009@linaro.org>
 <201103231712.06184.arnd@arndb.de>
 <20110323162251.GA9367@kroah.com>
 <201103231756.39849.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy.green@linaro.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	Linux USB list <linux-usb@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	broonie@opensource.wolfsonmicro.com, roger.quadros@nokia.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201103231756.39849.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 05:56:39PM +0100, Arnd Bergmann wrote:
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
> it is not sure (e.g. cdc_ether), or just one of the two.
> The usbnet framework only looks at the MAC address for device
> naming if both flags are set, otherwise it trusts the flag.
> 
> Signed-off-by: Arnd Bergmann <arnd.bergmann@linaro.org>
> Cc: Andy Green <andy.green@linaro.org>

Looks good to me, but some questions:

>  drivers/usb/serial/usb_wwan.c |    2 +-

You don't modify this file in the diff, what caused this to show up in
the diffstat?

> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -97,6 +97,8 @@ struct driver_info {
>  
>  #define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
>  
> +#define FLAG_PTP	0x1000		/* maybe use "usb%d" names */

"PTP"?  What does that stand for?

curious,

greg k-h
