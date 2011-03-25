From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Fri, 25 Mar 2011 12:57:32 +0100
Message-ID: <201103251257.32714.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <201103241415.45115.arnd@arndb.de> <AANLkTikZ76VXdPf46FHxhCyf3n4rNZOQW4Rp2yUZWP2h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
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
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	patches@linaro.org
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikZ76VXdPf46FHxhCyf3n4rNZOQW4Rp2yUZWP2h@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 March 2011, Alexey Orishko wrote:
> On Thu, Mar 24, 2011 at 2:15 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> 
> >
> > The approach taken here is to flag whether a device might be a
> > point-to-point link with the new FLAG_PTP setting in the usbnet
> > driver_info. A driver can set both FLAG_PTP and FLAG_ETHER if
> > it is not sure (e.g. cdc_ether), or just one of the two.
> 
> > The usbnet framework only looks at the MAC address for device
> > naming if both flags are set, otherwise it trusts the flag.
> 
> Should this paragraph above be a clue for the flag name?
> Sorry for late comment, but having flag called FLAG_POINTTOPOINT is really
> confusing. ptp, p2p terms are heavily used and will mislead folks.
> 
> Would it be better to call it something like IGNORE_MAC_ADDRESS if this is the
> feature you are targeting?

That would be a different way of looking at it.  FLAG_POINTTOPOINT
describes what the device is (a USB cable connecting two hosts), and
that flag can be used for various things, where the only thing
we currently do is the netif naming.

FLAG_IGNORE_MAC_ADDRESS as you suggest describes the implementation
of the device naming, not why that is done.

The intent here was to some something that makes sense next to
FLAG_ETHER, FLAG_WWAN and FLAG_WLAN. I think FLAG_POINTTOPOINT
describes this best, although I'd also be happy with FLAG_PTP,
FLAG_P2P, FLAG_CABLE or FLAG_USBCABLE.

	Arnd
