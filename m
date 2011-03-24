From: Andy Green <andy@warmcat.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 13:44:28 +0000
Message-ID: <4D8B4ABC.9090203@linaro.org>
References: <4D79F068.2080009@linaro.org> <1300924878.2638.38.camel@bwh-desktop> <201103241413.54599.arnd@arndb.de> <201103241415.45115.arnd@arndb.de>
Reply-To: andy.green@linaro.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Steve Calfee <stevecalfee@gmail.com>,
	Michal Nazarewicz <mnazarewicz@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	patches@linaro.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103241415.45115.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/24/2011 01:15 PM, Somebody in the thread at some point said:
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
> Signed-off-by: Arnd Bergmann<arnd.bergmann@linaro.org>
> Cc: Andy Green<andy.green@linaro.org>
> Cc: patches@linaro.org

For Panda case at least,

Tested-by: Andy Green <andy.green@linaro.org>

-Andy
